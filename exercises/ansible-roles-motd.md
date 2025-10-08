# Exercise: Creating and Working with Ansible Roles (MOTD Example)

This exercise teaches you how to create, structure, and deploy Ansible roles by building a custom Message of the Day (MOTD) system. You'll learn the fundamental concepts of roles - Ansible's way of organizing and reusing automation code.

## 🎯 Learning Objectives
- Understand what Ansible roles are and why they're important
- Create a complete role directory structure
- Write tasks, templates, and variables for a role
- Deploy roles using playbooks
- Learn role best practices and reusability concepts

## ✅ Prerequisites
- Completed the SSH setup exercise (`apache-ssh-local.md`)
- SSH connectivity working to localhost (127.0.0.1)
- Basic understanding of Ansible playbooks and tasks

## 🧩 What Are Ansible Roles?

**Think of roles like recipes in cooking:**
- A recipe has ingredients (variables), steps (tasks), and templates (Jinja2 files)
- You can reuse the same recipe in different meals (playbooks)
- Roles make your automation organized, reusable, and shareable

**Role benefits:**
- **Organization**: Keep related tasks, files, and variables together
- **Reusability**: Use the same role across multiple playbooks
- **Sharing**: Share roles with teams or the community
- **Testing**: Test roles independently
- **Maintenance**: Easier to update and debug

### Ansible Role Directory Structure
```
role_name/
├── tasks/          # Main automation tasks
│   └── main.yml
├── templates/      # Jinja2 template files  
│   └── file.j2
├── defaults/       # Default variable values
│   └── main.yml
├── vars/          # Role-specific variables (higher priority)
│   └── main.yml
├── handlers/      # Event-driven tasks (restart services, etc.)
│   └── main.yml
├── files/         # Static files to copy
├── meta/          # Role metadata and dependencies
│   └── main.yml
└── README.md      # Role documentation
```

## 🚀 Step 1: Project Setup and SSH Verification

### 1.1 Create Project Directory
```bash
# Create a project directory for our role work
mkdir -p ~/ansible-roles-project
cd ~/ansible-roles-project

# Verify we can still SSH to localhost
ssh -o StrictHostKeyChecking=no 127.0.0.1 "whoami"
```

### 1.2 Test Ansible Connectivity
```bash
# Copy the SSH inventory from previous exercise
cp ~/ansible-01/examples/inventory-ssh-local.ini .

# Replace YOUR_USERNAME if needed
sed -i "s/YOUR_USERNAME/$(whoami)/g" inventory-ssh-local.ini

# Test Ansible can connect
ansible ssh_local -i inventory-ssh-local.ini -m ping
```

**Expected output:**
```
127.0.0.1 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
```

## 🏗️ Step 2: Create Ansible Role Structure

### 2.1 Understanding ansible-galaxy init

The `ansible-galaxy init` command creates a standard role directory structure automatically.

```bash
# Create roles directory
mkdir -p roles
cd roles

# Generate role structure (motd = Message of the Day)
ansible-galaxy init motd
```

**What this creates:**
```bash
# Explore the generated structure
cd motd
find . -type f
```

**Expected output:**
```
./README.md
./defaults/main.yml
./handlers/main.yml
./meta/main.yml
./tasks/main.yml
./tests/inventory
./tests/test.yml
./vars/main.yml
```

### 2.2 Understand Each Directory

```bash
# Look at the directory structure
tree . 2>/dev/null || find . -type d | sort
```

Let's examine what each directory is for:

```bash
# Tasks directory - the main automation logic
ls -la tasks/
echo "Tasks contain the actual work the role does"

# Templates directory - dynamic file templates  
ls -la templates/ 2>/dev/null || echo "Templates directory will be created when needed"

# Defaults directory - default variable values
ls -la defaults/
echo "Defaults contain variables with default values"

# Meta directory - role information and dependencies
ls -la meta/
echo "Meta contains role metadata and dependencies"
```

## 📝 Step 3: Create Ansible Tasks

### 3.1 Understanding the Tasks File

Tasks are the "doing" part of a role - the actual automation steps.

```bash
# Look at the default tasks file
cd ~/ansible-roles-project/roles/motd/tasks
cat main.yml
```

**Default content (mostly empty):**
```yaml
---
# tasks file for motd
```

### 3.2 Write Our MOTD Tasks

We'll create tasks that:
1. Create a custom MOTD file from a template
2. Ensure proper ownership and permissions

```bash
# Edit the tasks file
cat > main.yml << 'EOF'
---
# tasks file for motd
- name: Create custom MOTD from template
  template:
    src: motd.j2
    dest: /etc/motd
    owner: root
    group: root
    mode: '0644'
    backup: yes
  notify: display motd change

- name: Ensure MOTD is readable by all users
  file:
    path: /etc/motd
    state: file
    mode: '0644'
EOF
```

**Understanding each task:**
- **template module**: Creates files from Jinja2 templates with variables
- **src: motd.j2**: Template file in templates/ directory
- **dest: /etc/motd**: Where to create the file on target system
- **owner/group/mode**: File ownership and permissions
- **backup: yes**: Keep a backup of the original file
- **notify**: Trigger a handler (we'll create this next)

### 3.3 Create a Handler (Optional but Good Practice)

Handlers run only when notified by tasks, typically for service restarts or notifications.

```bash
# Create a simple handler
cd ../handlers
cat > main.yml << 'EOF'
---
# handlers file for motd
- name: display motd change
  debug:
    msg: "MOTD file has been updated on {{ inventory_hostname }}"
EOF
```

## 📄 Step 4: Create Ansible Template

### 4.1 Understanding Jinja2 Templates

Templates let you create dynamic files with variables. Think of them as "fill-in-the-blank" files.

**Template syntax:**
- `{{ variable_name }}` - Insert variable value
- `{% if condition %}` - Conditional logic  
- `{% for item in list %}` - Loops
- `{{ ansible_facts.hostname }}` - System information

### 4.2 Create the Templates Directory and File

```bash
# Create templates directory (ansible-galaxy init doesn't create it)
cd ~/ansible-roles-project/roles/motd
mkdir -p templates
cd templates
```

### 4.3 Write the MOTD Template

```bash
cat > motd.j2 << 'EOF'
================================================================================
                        Welcome to {{ ansible_facts.hostname }}
================================================================================

System Information:
  - Operating System: {{ ansible_facts.distribution }} {{ ansible_facts.distribution_version }}
  - Architecture: {{ ansible_facts.architecture }}
  - Kernel: {{ ansible_facts.kernel }}
  - Memory: {{ (ansible_facts.memtotal_mb/1024)|round(1) }}GB RAM
  - CPU Cores: {{ ansible_facts.processor_vcpus }}

Network Information:
  - Hostname: {{ ansible_facts.fqdn }}
  - IP Address: {{ ansible_facts.default_ipv4.address | default('Not available') }}

Last Updated: {{ ansible_date_time.date }} at {{ ansible_date_time.time }}
Generated by: Ansible Role 'motd'

{% if environment is defined %}
Environment: {{ environment | upper }}
{% endif %}

{% if system_manager is defined %}
System Administrator: {{ system_manager }}
{% endif %}

{% if maintenance_window is defined %}
Maintenance Window: {{ maintenance_window }}
{% endif %}

NOTICE: {{ motd_notice | default('This system is managed by Ansible') }}

================================================================================
Unauthorized access is prohibited. All activities are logged and monitored.
================================================================================
EOF
```

**Template features explained:**
- **System facts**: `ansible_facts.*` variables collected automatically
- **Date/time**: `ansible_date_time.*` for timestamps
- **Filters**: `|round(1)`, `|upper`, `|default()` for formatting
- **Conditionals**: `{% if %}` blocks for optional content
- **Variables**: Custom variables we'll define in defaults

## 📊 Step 5: Create Ansible Variables

### 5.1 Understanding Variable Precedence

Ansible has a hierarchy for variables:
1. **Extra vars** (highest priority)
2. **vars/** in roles
3. **defaults/** in roles (lowest priority)

We'll use defaults for flexibility.

### 5.2 Define Default Variables

```bash
cd ~/ansible-roles-project/roles/motd/defaults
cat > main.yml << 'EOF'
---
# defaults file for motd
system_manager: "admin@company.com"
environment: "development"
maintenance_window: "Sundays 2:00-4:00 AM UTC"
motd_notice: "This system is managed by Ansible automation"

# Role configuration
motd_backup_original: yes
motd_file_permissions: "0644"
EOF
```

### 5.3 Add Role Metadata

```bash
cd ../meta
cat > main.yml << 'EOF'
---
# meta file for motd
galaxy_info:
  author: "Your Name"
  description: "Ansible role for managing Message of the Day (MOTD)"
  license: MIT
  min_ansible_version: 2.9
  
  platforms:
    - name: Ubuntu
      versions:
        - focal
        - jammy
    - name: Debian
      versions:
        - buster
        - bullseye

  galaxy_tags:
    - system
    - motd
    - banner
    - security

dependencies: []
EOF
```

## 🗂️ Step 6: Clean Up Unwanted Directories (Optional)

### 6.1 Remove Unused Directories

```bash
cd ~/ansible-roles-project/roles/motd

# Remove directories we're not using in this exercise
rm -rf tests vars files

# Verify our role structure
echo "=== Final Role Structure ==="
find . -type f | sort
```

**Expected output:**
```
./README.md
./defaults/main.yml
./handlers/main.yml
./meta/main.yml
./tasks/main.yml
./templates/motd.j2
```

### 6.2 Update Role Documentation

```bash
cat > README.md << 'EOF'
# MOTD Role

This Ansible role manages the Message of the Day (MOTD) displayed when users log into the system.

## Features
- Dynamic MOTD with system information
- Customizable variables for environment details
- Automatic backup of original MOTD
- Proper file permissions and ownership

## Variables
- `system_manager`: Contact email (default: admin@company.com)
- `environment`: Environment name (default: development)  
- `maintenance_window`: Maintenance schedule info
- `motd_notice`: Custom notice message

## Example Playbook
```yaml
- hosts: servers
  roles:
    - role: motd
      system_manager: "ops@mycompany.com"
      environment: "production"
```
EOF
```

## 📋 Step 7: Create Role Deployment Playbook

### 7.1 Create the Main Playbook

```bash
cd ~/ansible-roles-project

cat > motd-role.yml << 'EOF'
---
- name: Deploy MOTD role to managed hosts
  hosts: ssh_local
  become: yes
  gather_facts: yes

  roles:
    - role: motd
      system_manager: "ansible-admin@localhost.local"
      environment: "testing"
      maintenance_window: "Weekends 1:00-3:00 AM"
      motd_notice: "Learning Ansible roles - SSH localhost setup"
EOF
```

### 7.2 Create a Playbook with Multiple Configurations

```bash
# Create an advanced playbook showing different variable usage
cat > motd-environments.yml << 'EOF'
---
- name: Deploy MOTD for development environment
  hosts: ssh_local
  become: yes
  gather_facts: yes
  vars:
    env_type: "dev"

  roles:
    - role: motd
      system_manager: "dev-team@company.com"
      environment: "{{ env_type }}"
      maintenance_window: "Daily 3:00-4:00 AM"
      motd_notice: "Development system - frequent changes expected"

- name: Show current MOTD content (verification task)
  hosts: ssh_local
  gather_facts: no
  tasks:
    - name: Display current MOTD
      command: cat /etc/motd
      register: current_motd
      
    - name: Show MOTD content
      debug:
        msg: "{{ current_motd.stdout_lines }}"
EOF
```

## 🚀 Step 8: Deploy and Test the Ansible Role

### 8.1 Basic Role Deployment

```bash
# Run the basic role deployment
ansible-playbook -i inventory-ssh-local.ini motd-role.yml -K
```

### 8.2 Advanced Deployment with Variables

```bash
# Run with custom variables
ansible-playbook -i inventory-ssh-local.ini motd-environments.yml -K

# Run with extra variables (highest priority)
ansible-playbook -i inventory-ssh-local.ini motd-role.yml -K \
  --extra-vars "system_manager=custom-admin@example.com environment=production"
```

### 8.3 Verify the Results

```bash
# Check the MOTD file was created
cat /etc/motd

# Test SSH login to see MOTD in action
ssh -o StrictHostKeyChecking=no 127.0.0.1

# Check backup was created
ls -la /etc/motd*
```

### 8.4 Test Role Idempotency

```bash
# Run the playbook again - should show no changes
ansible-playbook -i inventory-ssh-local.ini motd-role.yml -K

# The output should show "changed=0" for all tasks
```

## 🧪 Advanced Testing and Variations

### Test Different Variable Combinations

```bash
# Test with minimal variables
ansible-playbook -i inventory-ssh-local.ini motd-role.yml -K \
  --extra-vars "system_manager=minimal@test.com"

# Test with all variables
ansible-playbook -i inventory-ssh-local.ini motd-role.yml -K \
  --extra-vars '{
    "system_manager": "full-test@company.com",
    "environment": "staging", 
    "maintenance_window": "Never - 24/7 system",
    "motd_notice": "High-availability production system"
  }'
```

### Check Mode (Dry Run)

```bash
# See what would change without making changes
ansible-playbook -i inventory-ssh-local.ini motd-role.yml -K --check --diff
```

### Verbose Mode for Debugging

```bash
# Run with detailed output
ansible-playbook -i inventory-ssh-local.ini motd-role.yml -K -vv
```

## 🏆 Role Best Practices Learned

1. **Organization**: All related automation in one directory
2. **Flexibility**: Variables make roles reusable across environments
3. **Documentation**: README.md explains usage and variables
4. **Idempotency**: Roles can run multiple times safely
5. **Templates**: Dynamic file generation with system facts
6. **Handlers**: Event-driven tasks for efficient automation
7. **Metadata**: Proper role information for sharing/maintenance

## 🔧 Troubleshooting Common Issues

**Permission errors:**
```bash
# Ensure you're using -K for sudo password
ansible-playbook -i inventory-ssh-local.ini motd-role.yml -K
```

**Template errors:**
```bash
# Check template syntax
ansible-playbook -i inventory-ssh-local.ini motd-role.yml -K --syntax-check
```

**Variable not found:**
```bash
# List all facts and variables available
ansible ssh_local -i inventory-ssh-local.ini -m setup
```

**Role not found:**
```bash
# Ensure you're in the right directory with roles/ subdirectory
ls -la roles/motd/
```

---

🎉 **Congratulations!** You've created, deployed, and tested a complete Ansible role. This same pattern works for any automation task - web servers, databases, security configurations, and more!