# Lesson 14: Best Practices, Directory Structure, and Version Control

## Learning Objectives
- Organize an Ansible project following best practices.
- Understand common files and folders.
- Use Git to version your automation.

## Concept Overview
As your automation grows, structure and version control matter. Keep your code readable, testable, and shareable.

## Step-by-Step Tutorial (Ubuntu)
1. **Suggested project structure:**
   ```
   ~/ansible-course/
   ├─ ansible.cfg                 # Configuration
   ├─ inventory.ini              # Host inventory
   ├─ group_vars/                # Group-specific variables
   │  ├─ web.yml
   │  └─ db.yml
   ├─ host_vars/                 # Host-specific variables
   │  └─ <hostname>.yml
   ├─ playbooks/                 # Main playbooks
   │  ├─ site.yml               # Master playbook
   │  ├─ web.yml                # Web-specific tasks
   │  └─ deploy_static.yml      # Deployment playbook
   ├─ roles/                     # Reusable roles
   │  ├─ webserver/
   │  │  ├─ tasks/main.yml
   │  │  ├─ handlers/main.yml
   │  │  ├─ templates/
   │  │  ├─ files/
   │  │  ├─ vars/main.yml
   │  │  └─ defaults/main.yml
   │  └─ database/
   ├─ templates/                 # Global templates
   │  ├─ nginx-site.conf.j2
   │  └─ index.html.j2
   ├─ files/                     # Static files to copy
   └─ vault/                     # Encrypted secrets (optional)
   ```

2. **Initialize Git and create .gitignore:**
   ```bash
   cd ~/ansible-course
   git init
   ```
   Create `.gitignore`:
   ```bash
   nano .gitignore
   ```
   Paste:
   ```
   # Ansible retry files
   *.retry

   # Python bytecode
   *.pyc
   __pycache__/

   # Temporary files
   .tmp/
   *.tmp

   # Logs
   *.log

   # IDE files
   .vscode/
   .idea/

   # OS files
   .DS_Store
   Thumbs.db

   # Secrets (if not using Ansible Vault)
   secrets.yml
   passwords.yml

   # Fetched files from remote hosts
   fetched/
   ```

3. **Commit initial structure:**
   ```bash
   git add .
   git commit -m "Initial Ansible course structure

   - Added basic project layout
   - Configured gitignore for Ansible projects
   - Set up roles and playbooks directory structure"
   ```

4. **Best practices checklist:**
   - ✅ Use meaningful names for plays, tasks, and variables
   - ✅ Keep secrets out of Git or use Ansible Vault for encryption
   - ✅ Use `group_vars`/`host_vars` for environment-specific settings
   - ✅ Prefer roles for reusable logic
   - ✅ Always test with `--check` and `--diff`:
     ```bash
     ansible-playbook playbooks/site.yml --check --diff
     ```
   - ✅ Use tags for selective execution:
     ```yaml
     - name: Install packages
       ansible.builtin.apt:
         name: nginx
         state: present
       tags: ['packages', 'web']
     ```
   - ✅ Document your playbooks with clear task names and comments

## Code Examples
- `.gitignore` and dry-run (`--check`) usage above.

## Hands-On Exercise
- Create a new Git branch `feature/security` and add a task to configure a basic firewall using `ufw` module.
- Solution:
  ```bash
  git checkout -b feature/security
  # Add UFW tasks to a security role or playbook
  git add .
  git commit -m "Add basic firewall configuration"
  git checkout main
  git merge feature/security
  ```

## Troubleshooting Tips
- Merge conflicts: commit often and branch for features.
- Ensure you don't commit private keys or secrets.
- Use `ansible-lint` to check playbook quality (install with `pip install ansible-lint`).

## Summary / Key Takeaways
- Good structure + Git = scalable, maintainable automation.
- Follow naming conventions and document your work.
- Use branches for feature development.

## Next Steps
- Final project: automate a full LAMP stack. 🎓

---

**Navigation:** [← Lesson 13](lesson-13-web-app.md) | [Next: Lesson 15 →](lesson-15-lamp-project.md)