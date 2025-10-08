# Lesson 9: File and User Management

## Learning Objectives
- Create and manage users and groups.
- Manage files, directories, and permissions.
- Use `copy`, `file`, `fetch` modules.

## Concept Overview
Typical server tasks: create service users, upload config/files, set permissions, and retrieve logs or artifacts.

## Step-by-Step Tutorial (Ubuntu)
1. **Create `playbooks/users_files.yml`:**
   ```bash
   nano playbooks/users_files.yml
   ```
   Paste:
   ```yaml
   ---
   - name: Manage users and files
     hosts: all
     become: true
     vars:
       app_user: "appuser"
       app_group: "appgroup"
       app_dir: "/opt/myapp"
     tasks:
       - name: Create group
         ansible.builtin.group:
           name: "{{ app_group }}"
           state: present

       - name: Create user
         ansible.builtin.user:
           name: "{{ app_user }}"
           group: "{{ app_group }}"
           create_home: yes
           shell: /bin/bash

       - name: Create application directory
         ansible.builtin.file:
           path: "{{ app_dir }}"
           state: directory
           owner: "{{ app_user }}"
           group: "{{ app_group }}"
           mode: '0755'

       - name: Upload config file
         ansible.builtin.copy:
           dest: "{{ app_dir }}/app.conf"
           content: |
             ENV=production
             DEBUG=false
           owner: "{{ app_user }}"
           group: "{{ app_group }}"
           mode: '0644'

       - name: Fetch remote file back to control node
         ansible.builtin.fetch:
           src: "{{ app_dir }}/app.conf"
           dest: "./fetched/{{ inventory_hostname }}/"
           flat: no
   ```
2. **Run:**
   ```bash
   ansible-playbook playbooks/users_files.yml
   ```

## Code Examples
- The playbook above.

## Hands-On Exercise
- Add a task to create `/var/log/myapp` with owner `appuser:appgroup`.
- Solution:
  ```yaml
  - name: Create log directory
    ansible.builtin.file:
      path: /var/log/myapp
      state: directory
      owner: "{{ app_user }}"
      group: "{{ app_group }}"
      mode: '0755'
  ```

## Troubleshooting Tips
- Permission denied: ensure `become: true`.
- "Destination directory not found" with `fetch`: make sure `dest` points to a valid local path (Ansible creates nested folders if `flat: no`).

## Summary / Key Takeaways
- Manage users, groups, files, and permissions via Ansible declaratively.

## Next Steps
- Spin up multiple nodes using Multipass for real multi-host practice. 🖧

---

**Navigation:** [← Lesson 8](lesson-08-templates.md) | [Next: Lesson 10 →](lesson-10-multi-node.md)