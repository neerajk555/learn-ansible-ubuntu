# Lesson 11: Creating and Using Roles

## Learning Objectives
- Understand roles and why they help.
- Create a role with `ansible-galaxy init`.
- Use roles in a site-level playbook.

## Concept Overview
Roles organize code into reusable components with a standard layout (tasks, handlers, templates, files, vars).

## Step-by-Step Tutorial (Ubuntu)
1. **Create a `roles` directory and initialize a role:**
   ```bash
   mkdir -p roles
   ansible-galaxy init roles/webserver
   ```
2. **Add tasks to `roles/webserver/tasks/main.yml`:**
   ```bash
   nano roles/webserver/tasks/main.yml
   ```
   Paste:
   ```yaml
   ---
   - name: Install nginx
     ansible.builtin.apt:
       name: nginx
       state: present
       update_cache: yes

   - name: Deploy index.html
     ansible.builtin.copy:
       dest: /var/www/html/index.html
       content: |
         <h1>Hello from {{ inventory_hostname }}</h1>
         <p>Managed by Ansible Role: webserver</p>
       owner: www-data
       group: www-data
       mode: '0644'
     notify: Reload nginx

   - name: Ensure nginx running and enabled
     ansible.builtin.service:
       name: nginx
       state: started
       enabled: yes
   ```
3. **Add handler to `roles/webserver/handlers/main.yml`:**
   ```bash
   nano roles/webserver/handlers/main.yml
   ```
   Paste:
   ```yaml
   ---
   - name: Reload nginx
     ansible.builtin.service:
       name: nginx
       state: reloaded
   ```
4. **Create a site playbook:**
   ```bash
   nano playbooks/site.yml
   ```
   Paste:
   ```yaml
   ---
   - name: Configure web servers
     hosts: web
     become: true
     roles:
       - webserver
   ```
5. **Run:**
   ```bash
   ansible-playbook playbooks/site.yml
   ```

## Code Examples
- Role structure under `roles/webserver` and `playbooks/site.yml`.

## Hands-On Exercise
- Create a `database` role that installs `mariadb-server` and ensures it's running.
- Solution structure:
  ```bash
  ansible-galaxy init roles/database
  # Edit roles/database/tasks/main.yml with mariadb tasks
  # Add database role to site.yml for db hosts
  ```

## Troubleshooting Tips
- Role not found: ensure the path is `roles/webserver` and referenced as `webserver`.
- YAML indentation errors are common—double-check.

## Summary / Key Takeaways
- Roles make your code structured and reusable.
- `site.yml` can orchestrate multiple roles.

## Next Steps
- Handle errors and debug playbooks. 🧯

---

**Navigation:** [← Lesson 10](lesson-10-multi-node.md) | [Next: Lesson 12 →](lesson-12-debugging.md)