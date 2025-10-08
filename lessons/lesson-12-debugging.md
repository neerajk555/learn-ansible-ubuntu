# Lesson 12: Error Handling and Debugging in Ansible

## Learning Objectives
- Use `debug`, `assert`, and verbosity (`-vvv`).
- Handle errors with `ignore_errors`, `failed_when`, and `block/rescue/always`.
- Retry logic with `until`/`retries`/`delay`.

## Concept Overview
Sometimes tasks fail. You'll learn how to get good diagnostics and control failure behavior.

## Step-by-Step Tutorial (Ubuntu)
1. **Create `playbooks/debug_errors.yml`:**
   ```bash
   nano playbooks/debug_errors.yml
   ```
   Paste:
   ```yaml
   ---
   - name: Debug and error handling
     hosts: all
     become: true
     tasks:
       - name: Show a variable
         ansible.builtin.debug:
           var: ansible_facts['os_family']

       - name: Assert Debian family
         ansible.builtin.assert:
           that:
             - ansible_os_family == "Debian"
           fail_msg: "This playbook only supports Debian-family systems."

       - name: Try a command that may fail, but ignore
         ansible.builtin.command: /bin/false
         ignore_errors: yes

       - name: Custom failure condition
         ansible.builtin.shell: "echo OK && exit 0"
         register: result
         failed_when: "'OK' not in result.stdout"

       - name: Retry until condition met
         ansible.builtin.uri:
           url: "http://{{ inventory_hostname }}"
           return_content: yes
         register: web
         until: web.status == 200
         retries: 5
         delay: 2
         ignore_errors: yes

       - block:
           - name: This might fail
             ansible.builtin.command: /bin/false
         rescue:
           - name: Handle the failure
             ansible.builtin.debug:
               msg: "Recovered from failure in block."
         always:
           - name: Always run
             ansible.builtin.debug:
               msg: "This always runs regardless of success or failure."
   ```
2. **Run with more verbosity:**
   ```bash
   ansible-playbook -vvv playbooks/debug_errors.yml
   ```

## Code Examples
- `debug`, `assert`, `ignore_errors`, `failed_when`, `block/rescue/always`, and `until`.

## Hands-On Exercise
- Add a task that checks if a file exists using the `stat` module and only creates it if it doesn't exist.
- Solution:
  ```yaml
  - name: Check if file exists
    ansible.builtin.stat:
      path: /tmp/testfile
    register: file_stat

  - name: Create file if it doesn't exist
    ansible.builtin.file:
      path: /tmp/testfile
      state: touch
    when: not file_stat.stat.exists
  ```

## Troubleshooting Tips
- `uri` requires reachable URL; ensure web server is running or use `ignore_errors: yes`.
- Use `-vvv` for detailed logs, `-k` or `-K` for prompting passwords if needed.
- `--check` mode helps test without making changes.

## Summary / Key Takeaways
- You can gracefully handle failures and get deep insight using debugging and verbosity.
- Error handling makes playbooks more robust in real environments.

## Next Steps
- Deploy a simple web application with Ansible. 🌐

---

**Navigation:** [← Lesson 11](lesson-11-roles.md) | [Next: Lesson 13 →](lesson-13-web-app.md)