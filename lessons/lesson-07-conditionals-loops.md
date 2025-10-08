# Lesson 7: Conditionals, Loops, and Handlers

## Learning Objectives
- Use `when` for conditionals.
- Use `loop` for repeated tasks.
- Use handlers to restart services when needed.

## Concept Overview
- **Conditionals**: run a task only if a condition is true.
- **Loops**: repeat a task for each item in a list.
- **Handlers**: notify and run once at the end when something changes (e.g., restart a service).

## Step-by-Step Tutorial (Ubuntu)
1. **Create `playbooks/handlers.yml`:**
   ```bash
   nano playbooks/handlers.yml
   ```
   Paste:
   ```yaml
   ---
   - name: Conditionals, loops, and handlers demo
     hosts: web
     become: true
     vars:
       extra_tools:
         - htop
         - tree
     tasks:
       - name: Install extra tools on Debian-based systems
         ansible.builtin.apt:
           name: "{{ extra_tools }}"
           state: present
           update_cache: yes
         when: ansible_os_family == "Debian"

       - name: Place a config file
         ansible.builtin.copy:
           dest: /etc/demo.conf
           content: "hello=world\n"
         notify: Restart nginx

       - name: Create multiple files using loop
         ansible.builtin.file:
           path: "/tmp/file{{ item }}"
           state: touch
         loop:
           - 1
           - 2
           - 3

     handlers:
       - name: Restart nginx
         ansible.builtin.service:
           name: nginx
           state: restarted
   ```
2. **Run:**
   ```bash
   ansible-playbook playbooks/handlers.yml
   ```

## Code Examples
- `when`, `loop`, and `handlers` demonstrated above.

## Hands-On Exercise
- Add a loop to create user directories for a list of users: `alice`, `bob`, `charlie` under `/home/`.
- Solution:
  ```yaml
  - name: Create user directories
    ansible.builtin.file:
      path: "/home/{{ item }}"
      state: directory
      owner: "{{ item }}"
      group: "{{ item }}"
      mode: '0755'
    loop:
      - alice
      - bob
      - charlie
  ```

## Troubleshooting Tips
- Handler didn't run? Ensure a task changed and called `notify`.
- Loop errors: verify the list is a list (YAML `- item`)

## Summary / Key Takeaways
- Use conditionals and loops to simplify tasks.
- Handlers are efficient for service restarts.

## Next Steps
- Render dynamic config files using templates (Jinja2). 🧩

---

**Navigation:** [← Lesson 6](lesson-06-variables-facts.md) | [Next: Lesson 8 →](lesson-08-templates.md)