# Example Configuration Files

This directory contains example configuration files and code snippets used throughout the course.

## 📁 Directory Structure

```
examples/
├── ansible.cfg              # Basic Ansible configuration
├── inventory.ini            # Sample inventory file  
├── inventory.yml            # YAML inventory example
├── group_vars/              # Group variable examples
│   ├── web.yml
│   └── db.yml
├── playbooks/               # Complete playbook examples
│   ├── hello.yml
│   ├── web.yml
│   ├── lamp.yml
│   └── site.yml
├── templates/               # Jinja2 templates
│   ├── nginx-site.conf.j2
│   ├── index.html.j2
│   └── app.php.j2
└── roles/                   # Example role structure
    └── webserver/
        ├── tasks/main.yml
        ├── handlers/main.yml
        ├── templates/
        └── defaults/main.yml
```

## 🚀 Quick Usage

Copy any example to your working directory:
```bash
cp examples/ansible.cfg ~/ansible-course/
cp examples/inventory.ini ~/ansible-course/
```

All examples are tested and ready to use with Ubuntu systems.