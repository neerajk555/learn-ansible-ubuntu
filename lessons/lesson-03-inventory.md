# Lesson 3: Understanding Ansible Inventory and Host Management

## Learning Objectives
- Understand inventories (INI and YAML).
- Define hosts and groups.
- Test connectivity with `ansible -m ping`.

## What is an Inventory? (Detailed Explanation)

An **inventory** is like a phone book for servers - it tells Ansible:
- **WHO** to manage (which computers/IP addresses)
- **HOW** to group them (web servers, databases, etc.)  
- **WHAT** settings to use (usernames, connection methods)

### Think of it Like Managing a Restaurant Chain 🏪
If you owned multiple restaurants, you'd organize them by:
- **Location groups**: "Downtown", "Suburbs", "Airport"
- **Type groups**: "Fast Food", "Fine Dining", "Cafes"
- **Contact info**: Address, phone, manager name

Ansible inventories work the same way - organize your servers logically!

### Why Groups Matter
Instead of managing servers one by one:
```bash
# Without groups (tedious!)
ansible server1 -m ping
ansible server2 -m ping  
ansible server3 -m ping
```

You manage them as groups:
```bash
# With groups (efficient!)
ansible webservers -m ping    # Pings all web servers
ansible databases -m ping     # Pings all database servers
ansible all -m ping          # Pings everything
```

## Step-by-Step Tutorial (Ubuntu)

Since you might not have multiple servers yet, we'll start with **localhost examples** that work immediately on your Ubuntu machine.

### Step 1: Understanding Your Current Inventory

Let's look at the inventory file we created in Lesson 2:

```bash
# View your current inventory
cd ~/ansible-course
cat inventory.ini
```

### Step 2: Create a Beginner-Friendly Inventory

Let's replace the basic inventory with something more educational:

```bash
# Edit your inventory file
nano inventory.ini
```

**Replace the contents with this beginner example:**
```ini
# ===== ANSIBLE INVENTORY FILE =====
# This file tells Ansible which computers to manage

# ----- LOCAL TESTING GROUP -----
# Your own Ubuntu machine (perfect for learning!)
[local]
localhost ansible_connection=local

# ----- FUTURE WEB SERVERS -----  
# Uncomment these lines when you have actual web servers
[webservers]
# web1 ansible_host=192.168.1.10 ansible_user=ubuntu
# web2 ansible_host=192.168.1.11 ansible_user=ubuntu

# ----- FUTURE DATABASE SERVERS -----
# Uncomment these lines when you have database servers  
[databases]
# db1 ansible_host=192.168.1.20 ansible_user=ubuntu

# ----- DEVELOPMENT ENVIRONMENT -----
# For testing on your local machine
[development]
localhost ansible_connection=local

# ----- VARIABLES FOR ALL SERVERS -----
[all:vars]
# Use Python 3 (standard on Ubuntu 20.04+)
ansible_python_interpreter=/usr/bin/python3
# Set timezone (adjust for your location)
server_timezone=America/New_York
```

**Save and exit:** `Ctrl+X`, `Y`, `Enter`

### Step 3: Understanding Inventory Structure

Let's break down what each section means:

#### Groups (Sections in Square Brackets)
- `[local]` - Computers for local testing
- `[webservers]` - Servers that run websites  
- `[databases]` - Servers that run databases
- `[development]` - Development/testing environment

#### Host Definitions
```ini
# Format: hostname ansible_host=IP ansible_user=username
web1 ansible_host=192.168.1.10 ansible_user=ubuntu
```
- `web1` - Friendly name for the server
- `ansible_host=192.168.1.10` - Actual IP address  
- `ansible_user=ubuntu` - Username for SSH login

#### Special Connection Types
```ini
localhost ansible_connection=local
```
- `ansible_connection=local` - Don't use SSH, run commands directly on this machine

### Step 4: Create a YAML Inventory (Alternative Format)

Some people prefer YAML format. Let's create an example:

```bash
# Create a YAML version
nano inventory.yml
```

**Paste this YAML inventory:**
```yaml
---
# YAML format inventory (alternative to INI)

all:
  vars:
    ansible_python_interpreter: /usr/bin/python3
    server_timezone: America/New_York
  
  children:
    # Local testing group  
    local:
      hosts:
        localhost:
          ansible_connection: local
    
    # Web server group (currently empty)
    webservers:
      vars:
        web_port: 80
        web_user: www-data
      hosts:
        # Uncomment when you have real web servers:
        # web1:
        #   ansible_host: 192.168.1.10
        #   ansible_user: ubuntu
    
    # Database group (currently empty)  
    databases:
      vars:
        db_port: 3306
        db_user: mysql
      hosts:
        # Uncomment when you have real database servers:
        # db1:
        #   ansible_host: 192.168.1.20
        #   ansible_user: ubuntu

    # Development environment
    development:
      hosts:
        localhost:
          ansible_connection: local
```

**Save and exit:** `Ctrl+X`, `Y`, `Enter`

### Step 5: Test Both Inventory Formats

```bash
# Test INI format inventory
ansible-inventory --list -i inventory.ini

# Test YAML format inventory  
ansible-inventory --list -i inventory.yml

# Use the default inventory (inventory.ini)
ansible-inventory --list
```

### Step 6: Test Basic Connectivity

Since we're using localhost, these commands should work immediately:

```bash
# Ping your local machine using different group names
ansible local -m ping
ansible development -m ping  
ansible localhost -m ping

# Try to ping groups that don't have hosts (will show warnings)
ansible webservers -m ping
ansible databases -m ping
```

**Expected results:**
- `local` and `development` groups should respond with "SUCCESS"
- `webservers` and `databases` will show "No hosts matched" (that's normal!)

### Step 7: Explore Inventory Information

```bash
# See all groups
ansible-inventory --graph

# List hosts in specific groups  
ansible-inventory --list local
ansible-inventory --list development

# Show detailed host information
ansible-inventory --host localhost
```

## Code Examples
- INI and YAML inventories above.

## Hands-On Exercise

**Complete these tasks to master Ansible inventories:**

### Exercise 1: Inventory Exploration
```bash
# Show your inventory in different formats
ansible-inventory --graph
ansible-inventory --list
ansible-inventory --list --yaml

# Test specific groups
ansible local --list-hosts
ansible development --list-hosts
ansible all --list-hosts
```

### Exercise 2: Add a Pretend Server
Edit your `inventory.ini` and add a fictional server for practice:

```bash
nano inventory.ini
```

Add this to the `[webservers]` section:
```ini
[webservers]
testserver ansible_host=127.0.0.1 ansible_port=2222 ansible_user=$USER
```

Then test it:
```bash
# This will fail (no server on port 2222), but shows how Ansible tries to connect
ansible testserver -m ping
```

### Exercise 3: Create a Custom Group
Add a new group for your specific needs:

```ini
[myservers]
localhost ansible_connection=local
testbox ansible_host=127.0.0.1 ansible_user=$USER

[myservers:vars]
environment=learning
purpose=ansible-course
```

Test your custom group:
```bash
ansible myservers -m ping
ansible myservers -m setup -a "filter=ansible_hostname"
```

### Exercise 4: Compare INI vs YAML
```bash
# Switch between inventory formats
ansible-inventory --list -i inventory.ini | head -20
ansible-inventory --list -i inventory.yml | head -20

# Verify both produce the same result for localhost
ansible localhost -i inventory.ini -m ping
ansible localhost -i inventory.yml -m ping
```

## Troubleshooting Tips

### Common Inventory Issues

**Problem:** "No hosts matched" 
```bash
# Check if group exists
ansible-inventory --graph

# Check spelling and group names
ansible-inventory --list | grep -i "groupname"

# List all available groups
ansible-inventory --graph | grep -E "^\s*@"
```

**Problem:** "Failed to connect to the host via ssh"
```bash
# For localhost testing, always use local connection
ansible localhost -m ping -c local

# Check if you can SSH manually first
ssh username@hostname

# Use verbose mode to see connection details
ansible hostname -m ping -vvv
```

**Problem:** YAML inventory syntax errors
```bash
# Validate YAML syntax
python3 -c "import yaml; print(yaml.safe_load(open('inventory.yml')))"

# Check indentation (use spaces, not tabs!)
cat -A inventory.yml | head -10
```

**Problem:** Variables not working
```bash
# Debug variable values
ansible localhost -m debug -a "var=hostvars[inventory_hostname]"

# Show all variables for a host
ansible-inventory --host localhost

# Test specific variable
ansible localhost -m debug -a "msg='Timezone is {{ server_timezone }}'"
```

### Inventory Best Practices for Beginners

1. **Start Simple:** Begin with localhost, add complexity gradually
2. **Use Comments:** Document what each group is for
3. **Test Frequently:** Run `ansible-inventory --list` after changes  
4. **Consistent Naming:** Use clear, descriptive group and host names
5. **Backup Working Configs:** Copy `inventory.ini` before major changes

### Quick Reference Commands
```bash
# Essential inventory commands to remember:
ansible-inventory --list          # Show all hosts and groups
ansible-inventory --graph         # Tree view of groups
ansible-inventory --host HOST     # Show variables for specific host  
ansible GROUP --list-hosts        # List hosts in a group
ansible all -m ping              # Test connectivity to all hosts
```

**Pro Tip:** Create an alias for quick inventory checking:
```bash
# Add this to your ~/.bashrc
alias inv='ansible-inventory --graph'

# Reload your shell  
source ~/.bashrc

# Now just type 'inv' to see your inventory structure
inv
```

## Summary / Key Takeaways
- Inventory defines hosts and groups.
- You can use INI or YAML formats.

## Next Steps
- Write your first Ansible playbook. ✍️

---

**Navigation:** [← Lesson 2](lesson-02-installation.md) | [Next: Lesson 4 →](lesson-04-first-playbook.md)