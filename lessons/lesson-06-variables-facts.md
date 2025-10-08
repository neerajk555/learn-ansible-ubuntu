# Lesson 6: Using Variables and Facts

## Learning Objectives
- Define and use variables.
- Leverage Ansible facts.
- Use `group_vars` and `host_vars`.

## Understanding Variables and Facts (Detailed Explanation)

### What are Variables? 🏷️
**Variables** are like labeled containers that hold values you can reuse throughout your playbooks. Think of them as:
- **Recipe ingredients** that can change (like "2 cups flour" vs "3 cups flour")
- **Settings** that adapt to different environments (like "development" vs "production")  
- **Values** that make your playbooks flexible instead of hardcoded

### What are Facts? 📊
**Facts** are information Ansible automatically discovers about your systems:
- Operating system and version
- Network interfaces and IP addresses
- Memory and CPU information  
- Installed software and services
- Hardware details

### Real-World Analogy 🏥
Think of Ansible like a smart doctor:
- **Facts** = Medical tests and measurements (blood pressure, temperature, weight)
- **Variables** = Treatment dosages and preferences (medication amounts, patient allergies)
- **Playbooks** = Treatment plans that adapt based on test results and patient needs

### Variable Types and Sources
1. **Playbook variables** - Defined directly in your YAML
2. **Group variables** - Apply to all hosts in a group  
3. **Host variables** - Specific to individual hosts
4. **Command-line variables** - Passed when running playbooks
5. **Facts** - Automatically gathered system information

## Step-by-Step Tutorial (Ubuntu)

### Step 1: Create Your Variable Directory Structure

```bash
# Navigate to your Ansible workspace
cd ~/ansible-course

# Create directories for different types of variables
mkdir -p group_vars host_vars

# Verify the structure  
ls -la
```

**Directory purposes:**
- `group_vars/` - Variables that apply to entire groups (like all web servers)
- `host_vars/` - Variables specific to individual hosts

### Step 2: Create Group Variables for Local Testing

Since we're working with localhost, let's create variables for our local group:

```bash
# Create variables for the local group
nano group_vars/local.yml
```

**Paste this comprehensive variable example:**
```yaml
---
# Variables for the 'local' group (localhost testing)

# Web server configuration
web_packages:
  - nginx
  - curl
  - wget
web_port: 8080
web_user: www-data
web_root: /var/www/html

# Development tools  
dev_packages:
  - git
  - htop
  - tree
  - vim
  - build-essential

# System settings
server_timezone: America/New_York
max_file_descriptors: 65536

# Application settings
app_name: "my-ansible-app"
app_version: "1.0.0"
app_environment: "development"

# Custom messages
welcome_message: "Welcome to my Ansible-managed Ubuntu system!"
```

### Step 3: Create Host-Specific Variables

```bash
# Create variables specific to localhost
nano host_vars/localhost.yml
```

**Paste host-specific settings:**
```yaml
---
# Variables specific to localhost only

# Override the web port for localhost testing
web_port: 8080

# Localhost-specific settings
local_user: "{{ ansible_env.USER }}"
home_directory: "{{ ansible_env.HOME }}"

# Custom directories for localhost
custom_directories:
  - "{{ home_directory }}/ansible-projects"
  - "{{ home_directory }}/web-development"
  - "{{ home_directory }}/backups"

# Development mode settings
debug_mode: true
verbose_logging: true
```

### Step 4: Create a Comprehensive Variables Demo Playbook

```bash
# Create a playbook that demonstrates variables and facts
nano playbooks/variables-demo.yml
```

**Paste this educational example:**
```yaml
---
- name: Variables and Facts Demonstration
  hosts: local
  become: yes
  gather_facts: yes  # This is crucial for facts to work
  
  # Playbook-level variables (highest precedence in this play)
  vars:
    playbook_variable: "I'm defined in the playbook itself"
    temporary_file: "/tmp/ansible-variables-demo.txt"
  
  tasks:
    # === FACTS EXPLORATION ===
    - name: Display basic system facts
      ansible.builtin.debug:
        msg: |
          === SYSTEM FACTS ===
          Hostname: {{ ansible_hostname }}
          Operating System: {{ ansible_distribution }} {{ ansible_distribution_version }}
          Architecture: {{ ansible_architecture }}
          CPU Cores: {{ ansible_processor_vcpus }}
          Total Memory: {{ (ansible_memtotal_mb / 1024) | round(1) }} GB
          
    - name: Show network facts
      ansible.builtin.debug:
        msg: |
          === NETWORK FACTS ===
          Primary IP: {{ ansible_default_ipv4.address | default('Not available') }}
          All Interfaces: {{ ansible_interfaces | join(', ') }}
          
    - name: Display user and environment facts
      ansible.builtin.debug:
        msg: |
          === USER & ENVIRONMENT FACTS ===
          Current User: {{ ansible_env.USER }}
          Home Directory: {{ ansible_env.HOME }}
          Shell: {{ ansible_env.SHELL }}
          
    # === VARIABLE SOURCES DEMONSTRATION ===
    - name: Show variables from different sources
      ansible.builtin.debug:
        msg: |
          === VARIABLE SOURCES ===
          From group_vars: {{ web_packages | default('Not defined') }}
          From host_vars: {{ local_user | default('Not defined') }}
          From playbook vars: {{ playbook_variable }}
          Web port (host_vars override): {{ web_port }}
          
    # === VARIABLE MANIPULATION ===  
    - name: Demonstrate variable manipulation
      ansible.builtin.debug:
        msg: |
          === VARIABLE MANIPULATION ===
          App name uppercase: {{ app_name | upper }}
          Current date: {{ ansible_date_time.date }}
          Server uptime: {{ (ansible_uptime_seconds / 3600) | round(1) }} hours
          
    # === USING VARIABLES IN TASKS ===
    - name: Install packages defined in variables
      ansible.builtin.apt:
        name: "{{ web_packages }}"
        state: present
        update_cache: yes
      when: web_packages is defined
      
    - name: Create directories from variables
      ansible.builtin.file:
        path: "{{ item }}"
        state: directory
        mode: '0755'
        owner: "{{ ansible_env.USER }}"
      loop: "{{ custom_directories }}"
      become: no  # Don't use sudo for user directories
      
    - name: Create a file with variable content
      ansible.builtin.copy:
        dest: "{{ temporary_file }}"
        content: |
          === Ansible Variables Demo File ===
          Generated on: {{ ansible_date_time.iso8601 }}
          System: {{ ansible_distribution }} {{ ansible_distribution_version }}
          Application: {{ app_name }} v{{ app_version }}
          Environment: {{ app_environment }}
          
          {{ welcome_message }}
          
          This file demonstrates how variables can be used to create
          dynamic content that adapts to different systems and environments.
        mode: '0644'
        
    - name: Display the created file content
      ansible.builtin.debug:
        msg: "File created at {{ temporary_file }}"
```

### Step 5: Create a Web Server Playbook Using Variables

```bash
# Update your web server playbook to use variables
nano playbooks/web-with-variables.yml
```

**Paste this variable-driven web server setup:**
```yaml
---
- name: Web Server with Variables
  hosts: local
  become: yes
  gather_facts: yes
  
  tasks:
    - name: Install web server packages (from variables)
      ansible.builtin.apt:
        name: "{{ web_packages }}"
        state: present
        update_cache: yes
        cache_valid_time: 3600
        
    - name: Create custom web content using variables
      ansible.builtin.copy:
        dest: "{{ web_root }}/index.html"
        content: |
          <!DOCTYPE html>
          <html>
          <head>
              <title>{{ app_name }}</title>
              <style>
                  body { font-family: sans-serif; margin: 2rem; background: #f5f5f5; }
                  .container { max-width: 800px; margin: 0 auto; background: white; padding: 2rem; border-radius: 8px; }
                  .info { background: #e8f4fd; padding: 1rem; border-radius: 4px; margin: 1rem 0; }
              </style>
          </head>
          <body>
              <div class="container">
                  <h1>{{ welcome_message }}</h1>
                  <div class="info">
                      <h3>System Information</h3>
                      <p><strong>Hostname:</strong> {{ ansible_hostname }}</p>
                      <p><strong>OS:</strong> {{ ansible_distribution }} {{ ansible_distribution_version }}</p>
                      <p><strong>App Version:</strong> {{ app_name }} v{{ app_version }}</p>
                      <p><strong>Environment:</strong> {{ app_environment }}</p>
                      <p><strong>Port:</strong> {{ web_port }}</p>
                  </div>
                  <p>This page was generated using Ansible variables and facts!</p>
                  <small>Generated on {{ ansible_date_time.iso8601 }}</small>
              </div>
          </body>
          </html>
        owner: "{{ web_user }}"
        group: "{{ web_user }}"
        mode: '0644'
        
    - name: Configure Nginx to use custom port
      ansible.builtin.copy:
        dest: /etc/nginx/sites-available/default
        content: |
          server {
              listen {{ web_port }};
              listen [::]:{{ web_port }};
              
              root {{ web_root }};
              index index.html;
              
              server_name {{ ansible_hostname }};
              
              location / {
                  try_files $uri $uri/ =404;
              }
          }
        backup: yes  # Keep a backup of the original
      notify: reload nginx
      
    - name: Start Nginx service
      ansible.builtin.service:
        name: nginx
        state: started
        enabled: yes
        
  handlers:
    - name: reload nginx
      ansible.builtin.service:
        name: nginx
        state: reloaded
```

### Step 6: Test Everything Works

```bash
# Run the variables demonstration
ansible-playbook playbooks/variables-demo.yml

# Run the web server with variables
ansible-playbook playbooks/web-with-variables.yml

# Test the web server
curl http://localhost:8080

# Check what files were created
cat /tmp/ansible-variables-demo.txt
ls -la ~/ansible-projects ~/web-development ~/backups
```

### Step 7: Command-Line Variables Override

You can override variables from the command line:

```bash
# Override variables when running playbooks
ansible-playbook playbooks/web-with-variables.yml -e "web_port=9000"
ansible-playbook playbooks/variables-demo.yml -e "app_name=MyCustomApp app_version=2.0"

# Test the new port
curl http://localhost:9000
```

## Code Examples
- `group_vars/web.yml` and the updated `playbooks/web.yml`.

## Hands-On Exercise

**Complete these exercises to master variables and facts:**

### Exercise 1: Create Your Own Variable Files
Create variables for different environments:

```bash
# Create staging environment variables
nano group_vars/staging.yml
```

```yaml
---
app_environment: "staging"
web_port: 8081
debug_mode: true
db_name: "myapp_staging"
```

```bash  
# Create production environment variables
nano group_vars/production.yml
```

```yaml
---
app_environment: "production"
web_port: 80
debug_mode: false
db_name: "myapp_production"
```

### Exercise 2: Facts Exploration Playbook
Create `playbooks/facts-explorer.yml`:

```yaml
---
- name: Explore All Available Facts
  hosts: local
  gather_facts: yes
  
  tasks:
    - name: Show ALL facts (warning: lots of output!)
      ansible.builtin.debug:
        var: ansible_facts
      tags: ['all_facts']  # Use tags to run selectively
        
    - name: Show memory details
      ansible.builtin.debug:
        msg: |
          Memory Total: {{ ansible_memtotal_mb }} MB
          Memory Free: {{ ansible_memfree_mb }} MB
          Swap Total: {{ ansible_swaptotal_mb }} MB
          
    - name: Show disk information
      ansible.builtin.debug:
        msg: |
          Mount Point: {{ item.mount }}
          Total Size: {{ (item.size_total / 1024 / 1024 / 1024) | round(2) }} GB
          Available: {{ (item.size_available / 1024 / 1024 / 1024) | round(2) }} GB
          Filesystem: {{ item.fstype }}
      loop: "{{ ansible_mounts }}"
      when: item.mount == "/"
        
    - name: Show network details  
      ansible.builtin.debug:
        msg: |
          Interface: {{ item }}
          IP Address: {{ hostvars[inventory_hostname]['ansible_' + item].get('ipv4', {}).get('address', 'No IP') }}
      loop: "{{ ansible_interfaces }}"
      when: 
        - item != "lo"  # Skip loopback
        - hostvars[inventory_hostname]['ansible_' + item] is defined
```

Run with specific tags:
```bash
# Run without showing all facts
ansible-playbook playbooks/facts-explorer.yml --skip-tags all_facts

# Run with all facts (lots of output!)
ansible-playbook playbooks/facts-explorer.yml
```

### Exercise 3: Variable Precedence Testing
Create `playbooks/precedence-test.yml`:

```yaml
---
- name: Variable Precedence Testing
  hosts: local
  vars:
    test_variable: "playbook_level"
    web_port: 7777  # This should override group_vars
    
  tasks:
    - name: Show variable precedence
      ansible.builtin.debug:
        msg: |
          test_variable: {{ test_variable }}
          web_port: {{ web_port }}
          Source priority: playbook vars > host_vars > group_vars
          
    - name: Test command line override
      ansible.builtin.debug:
        msg: "Command line variable: {{ cli_var | default('Not provided') }}"
```

Test precedence:
```bash
# Normal run
ansible-playbook playbooks/precedence-test.yml

# Override with command line (highest precedence)
ansible-playbook playbooks/precedence-test.yml -e "web_port=9999 cli_var=hello"
```

### Exercise 4: Dynamic Configuration Based on Facts
Create `playbooks/adaptive-config.yml`:

```yaml
---
- name: Adaptive Configuration Based on System Facts
  hosts: local
  become: yes
  gather_facts: yes
  
  vars:
    # Adapt settings based on available memory
    web_workers: "{{ (ansible_memtotal_mb / 1024) | round(0, 'floor') | int }}"
    
  tasks:
    - name: Show adaptive settings
      ansible.builtin.debug:
        msg: |
          System has {{ (ansible_memtotal_mb / 1024) | round(1) }} GB RAM
          Will configure {{ web_workers }} web workers
          
    - name: Install packages based on system architecture
      ansible.builtin.apt:
        name: "{{ item }}"
        state: present
      loop: "{{ architecture_packages[ansible_architecture] | default([]) }}"
      vars:
        architecture_packages:
          x86_64:
            - htop
            - iotop
          aarch64:  # ARM64
            - htop
            
    - name: Configure swap if system has low memory
      ansible.builtin.debug:
        msg: "Would configure swap file - system has only {{ (ansible_memtotal_mb / 1024) | round(1) }} GB"
      when: ansible_memtotal_mb < 2048
      
    - name: Create performance tuning config
      ansible.builtin.copy:
        dest: /tmp/system-tuning.conf
        content: |
          # Auto-generated system tuning configuration
          # Generated on: {{ ansible_date_time.iso8601 }}
          
          [system]
          hostname={{ ansible_hostname }}
          architecture={{ ansible_architecture }}
          cpu_cores={{ ansible_processor_vcpus }}
          memory_gb={{ (ansible_memtotal_mb / 1024) | round(1) }}
          
          [tuning]
          web_workers={{ web_workers }}
          max_connections={{ ansible_processor_vcpus * 100 }}
          {% if ansible_memtotal_mb > 4096 %}
          enable_caching=true
          cache_size={{ (ansible_memtotal_mb * 0.1) | round(0) }}MB
          {% else %}
          enable_caching=false
          {% endif %}
```

### Exercise 5: Custom Facts Creation
Create a custom fact script:

```bash
# Create custom facts directory
sudo mkdir -p /etc/ansible/facts.d

# Create a custom fact script
sudo nano /etc/ansible/facts.d/custom.fact
```

```bash
#!/bin/bash
# Custom facts script

echo "{"
echo "  \"custom_info\": {"
echo "    \"installation_date\": \"$(date -I)\","
echo "    \"purpose\": \"Ansible Learning Lab\","
echo "    \"installed_by\": \"$USER\","
echo "    \"disk_usage_percent\": \"$(df / | tail -1 | awk '{print $5}' | sed 's/%//')\""
echo "  }"
echo "}"
```

```bash
# Make it executable
sudo chmod +x /etc/ansible/facts.d/custom.fact

# Test the custom fact
/etc/ansible/facts.d/custom.fact
```

Create a playbook to use custom facts:
```bash
nano playbooks/custom-facts.yml
```

```yaml
---
- name: Using Custom Facts
  hosts: local
  gather_facts: yes
  
  tasks:
    - name: Show custom facts
      ansible.builtin.debug:
        msg: |
          Installation Date: {{ ansible_local.custom.custom_info.installation_date }}
          Purpose: {{ ansible_local.custom.custom_info.purpose }}
          Installed By: {{ ansible_local.custom.custom_info.installed_by }}
          Disk Usage: {{ ansible_local.custom.custom_info.disk_usage_percent }}%
```

## Troubleshooting Tips

### Variable Issues

**Problem:** Variables not found or undefined
```bash
# Check variable precedence and values
ansible-playbook playbook.yml -e "debug=true" --extra-vars "variable_name=test_value"

# Show all variables for a host
ansible-inventory --host localhost --vars

# Debug specific variables in playbook
- debug:
    var: variable_name
- debug:  
    msg: "Variable value is: {{ variable_name | default('UNDEFINED') }}"
```

**Problem:** Variable precedence confusion
```yaml
# Test precedence with a debug task
- name: Show variable sources
  debug:
    msg: |
      From command line: {{ cli_var | default('Not set') }}
      From host_vars: {{ host_specific_var | default('Not set') }}
      From group_vars: {{ group_specific_var | default('Not set') }}
      From playbook: {{ playbook_var | default('Not set') }}
```

**Order of precedence (highest to lowest):**
1. Command line `-e` variables
2. `host_vars/hostname.yml` 
3. `group_vars/groupname.yml`
4. Playbook `vars:` section
5. Role defaults

### Facts Issues

**Problem:** Facts not available or empty
```bash
# Force fact gathering
- name: Gather facts manually
  setup:

# Check if facts are being gathered
- debug:
    msg: "Facts gathered: {{ ansible_facts is defined }}"
    
# Refresh facts during playbook
- setup:
  tags: always
```

**Problem:** Specific fact not found
```yaml
# Use default values and check availability
- debug:
    msg: "IP Address: {{ ansible_default_ipv4.address | default('No IP found') }}"

# Check if fact exists before using
- debug:
    msg: "Network info available"
  when: ansible_default_ipv4 is defined

# Show available network facts  
- debug:
    var: ansible_all_ipv4_addresses
```

### File Path and Permission Issues

**Problem:** Variables files not being loaded
```bash
# Check file names and locations
ls -la group_vars/ host_vars/

# Verify YAML syntax
python3 -c "import yaml; print(yaml.safe_load(open('group_vars/local.yml')))"

# Test with specific inventory
ansible-playbook -i inventory.ini playbook.yml
```

**Problem:** Custom facts not working
```bash
# Check custom facts directory
ls -la /etc/ansible/facts.d/

# Test custom fact script manually
sudo /etc/ansible/facts.d/custom.fact

# Check permissions
ls -la /etc/ansible/facts.d/custom.fact
```

### Best Practices You've Learned

1. **Use descriptive variable names** - `web_port` not just `port`
2. **Group related variables** - Put web server vars in `web.yml`
3. **Provide defaults** - Use `| default('fallback')` for optional variables
4. **Document your variables** - Add comments explaining their purpose
5. **Test variable precedence** - Understand which values override others
6. **Use facts for dynamic behavior** - Adapt to different systems automatically

**Pro Tip:** Create a variables documentation template:
```yaml
---
# === WEB SERVER CONFIGURATION ===
# Purpose: Configure Nginx web server settings
# Used by: web-server.yml playbook

web_port: 8080          # Port for web server (default: 80)
web_user: www-data      # User to run web server
web_root: /var/www/html # Document root directory

# === DEVELOPMENT SETTINGS ===  
debug_mode: true        # Enable debug logging
app_environment: "dev"  # Environment name (dev/staging/prod)
```

## Summary / Key Takeaways
- Variables make playbooks reusable.
- Facts provide rich system info for dynamic behavior.

## Next Steps
- Add conditionals, loops, and handlers. 🔁

---

**Navigation:** [← Lesson 5](lesson-05-packages-services.md) | [Next: Lesson 7 →](lesson-07-conditionals-loops.md)