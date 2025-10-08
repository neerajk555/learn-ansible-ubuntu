# Lesson 8: Working with Templates (Jinja2)

## Learning Objectives
- Use Jinja2 templates to generate configuration files.
- Reference variables in templates.
- Safely apply and test templates.

## Concept Overview
Templates let you create "smart" files. Instead of a static file, you create a template with placeholders that Ansible fills in with variables.

## Step-by-Step Tutorial (Ubuntu)
1. **Create a template for Nginx:**
   ```bash
   mkdir -p templates
   nano templates/nginx-site.conf.j2
   ```
   Paste:
   ```
   server {
       listen {{ web_port }};
       server_name {{ inventory_hostname }};

       root /var/www/html;
       index index.html;

       location / {
           try_files $uri $uri/ =404;
       }
   }
   ```
2. **Create a playbook to deploy the template:**
   ```bash
   nano playbooks/template.yml
   ```
   Paste:
   ```yaml
   ---
   - name: Deploy Nginx template
     hosts: web
     become: true
     vars:
       web_port: 80
     tasks:
       - name: Ensure nginx is installed
         ansible.builtin.apt:
           name: nginx
           state: present
           update_cache: yes

       - name: Deploy site config
         ansible.builtin.template:
           src: templates/nginx-site.conf.j2
           dest: /etc/nginx/sites-available/default
           owner: root
           group: root
           mode: '0644'
         notify: Reload nginx

     handlers:
       - name: Reload nginx
         ansible.builtin.service:
           name: nginx
           state: reloaded
   ```
3. **Run:**
   ```bash
   ansible-playbook playbooks/template.yml
   ```

## Code Examples
- `templates/nginx-site.conf.j2` and `playbooks/template.yml`.

## Hands-On Exercise
- Add a variable `site_root` and update the template and playbook to use `/var/www/html` or a custom directory.
- Solution - add to vars:
  ```yaml
  site_root: /var/www/html
  ```
  Update template:
  ```
  root {{ site_root }};
  ```

## Troubleshooting Tips
- Template syntax errors: use `{{ variable }}` and watch for missing braces.
- Nginx reload errors: run `sudo nginx -t` on the remote to validate configuration.

## Summary / Key Takeaways
- Templates enable dynamic configuration files using variables.
- Always reload or restart services after config changes.

## Next Steps
- Manage files and users across servers. 👤📁

---

**Navigation:** [← Lesson 7](lesson-07-conditionals-loops.md) | [Next: Lesson 9 →](lesson-09-files-users.md)