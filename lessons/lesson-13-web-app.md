# Lesson 13: Deploying a Simple Web Application

## Learning Objectives
- Install and configure Nginx with Ansible.
- Deploy a static website using a template.
- Validate deployment end-to-end.

## Concept Overview
We'll deploy a simple static site—great for understanding deployment flow without application runtime complexity.

## Step-by-Step Tutorial (Ubuntu)
1. **Create `templates/index.html.j2`:**
   ```bash
   nano templates/index.html.j2
   ```
   Paste:
   ```html
   <!doctype html>
   <html>
   <head>
     <meta charset="utf-8">
     <title>Welcome {{ inventory_hostname }}</title>
     <style>
       body { font-family: sans-serif; margin: 3rem; background: #f5f5f5; }
       .container { max-width: 800px; margin: 0 auto; background: white; padding: 2rem; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
       .host { color: #2c7; font-weight: bold; }
       .info { background: #e8f4fd; padding: 1rem; border-radius: 4px; margin: 1rem 0; }
     </style>
   </head>
   <body>
     <div class="container">
       <h1>🚀 Deployed by Ansible on <span class="host">{{ inventory_hostname }}</span></h1>
       <div class="info">
         <p><strong>OS:</strong> {{ ansible_distribution }} {{ ansible_distribution_version }}</p>
         <p><strong>Architecture:</strong> {{ ansible_architecture }}</p>
         <p><strong>Deployment Time:</strong> {{ ansible_date_time.iso8601 }}</p>
       </div>
       <p>This website was automatically deployed using Ansible automation. 💫</p>
     </div>
   </body>
   </html>
   ```
2. **Create `playbooks/deploy_static.yml`:**
   ```bash
   nano playbooks/deploy_static.yml
   ```
   Paste:
   ```yaml
   ---
   - name: Deploy static site
     hosts: web
     become: true
     vars:
       web_root: /var/www/html
       site_name: "ansible-demo"
     tasks:
       - name: Install nginx
         ansible.builtin.apt:
           name: nginx
           state: present
           update_cache: yes

       - name: Deploy index.html
         ansible.builtin.template:
           src: templates/index.html.j2
           dest: "{{ web_root }}/index.html"
           owner: www-data
           group: www-data
           mode: '0644'
         notify: Reload nginx

       - name: Create about page
         ansible.builtin.copy:
           dest: "{{ web_root }}/about.html"
           content: |
             <h1>About {{ site_name }}</h1>
             <p>This is a demo site deployed with Ansible on {{ inventory_hostname }}</p>
             <a href="/">← Back to Home</a>
           owner: www-data
           group: www-data
           mode: '0644'

       - name: Ensure nginx is running and enabled
         ansible.builtin.service:
           name: nginx
           state: started
           enabled: yes

     handlers:
       - name: Reload nginx
         ansible.builtin.service:
           name: nginx
           state: reloaded
   ```
3. **Run:**
   ```bash
   ansible-playbook playbooks/deploy_static.yml
   ```
4. **Test from your control node:**
   ```bash
   curl http://<WEB1_IP>/
   curl http://<WEB1_IP>/about.html
   ```

## Code Examples
- Template + playbook above.

## Hands-On Exercise
- Add a CSS file as a separate template and link it in the HTML template.
- Create `templates/style.css.j2`:
  ```css
  body { background: {{ site_bg_color | default('#f0f0f0') }}; }
  ```
- Add deployment task and link in HTML `<head>`.

## Troubleshooting Tips
- If Nginx is not serving, check `systemctl status nginx` on the managed node (use `ansible web -a "systemctl status nginx"`).
- SELinux/AppArmor is usually not blocking on Ubuntu; firewall rarely blocks local Multipass networking.

## Summary / Key Takeaways
- You've deployed a site via Ansible—templates + services = deployment.
- Templates make content dynamic based on host facts and variables.

## Next Steps
- Learn best practices, directory structure, and use Git for version control. ✅

---

**Navigation:** [← Lesson 12](lesson-12-debugging.md) | [Next: Lesson 14 →](lesson-14-best-practices.md)