# Lesson 5: Managing Packages and Services with Ansible

## Learning Objectives
- Use `apt` module to install packages.
- Use `service`/`systemd` to manage services.
- Ensure idempotent operations.

## Understanding Package and Service Management (Detailed Explanation)

Managing software on Linux involves two main concepts:
1. **Packages** - Software installation files (like .deb files on Ubuntu)
2. **Services** - Background programs that run continuously (like web servers)

### Real-World Analogy 🏠
Think of it like setting up a home security system:
- **Installing packages** = Buying and delivering the equipment to your house
- **Managing services** = Turning the system on/off and making sure it starts automatically

### Why Ansible is Perfect for This

**Without Ansible (manual way):**
```bash
# On every server, you'd type:
sudo apt update
sudo apt install nginx
sudo systemctl start nginx  
sudo systemctl enable nginx
# Repeat for 10, 50, 100+ servers... 😫
```

**With Ansible (automated way):**
```yaml
# Write once, run everywhere:
- name: Install and configure Nginx
  apt: name=nginx state=present
- name: Start Nginx
  service: name=nginx state=started enabled=yes
```

### Understanding Idempotency 🔄

**Idempotent** means "safe to run multiple times." Ansible checks current state before making changes:

- If nginx is already installed → Skip installation
- If nginx is already running → Skip starting  
- If nginx startup is already enabled → Skip enabling

This means you can run the same playbook 100 times safely!

## Step-by-Step Tutorial (Ubuntu)

### Step 1: Update Your Inventory for Local Testing

Since we're working on localhost, let's make sure our inventory is set up correctly:

```bash
cd ~/ansible-course
nano inventory.ini
```

**Ensure you have a local group:**
```ini
[local]
localhost ansible_connection=local

[web]
localhost ansible_connection=local

[all:vars]
ansible_python_interpreter=/usr/bin/python3
```

### Step 2: Create Your First Package Management Playbook

```bash
# Create the playbooks directory if it doesn't exist
mkdir -p playbooks

# Create the web server playbook
nano playbooks/web-server.yml
```

**Paste this comprehensive example:**
```yaml
---
- name: Install and Configure Nginx Web Server
  hosts: local  # Start with localhost for safe testing
  become: yes   # We need sudo privileges to install packages
  gather_facts: yes
  
  tasks:
    - name: Update apt package cache (like 'apt update')
      ansible.builtin.apt:
        update_cache: yes
        cache_valid_time: 3600  # Only update if cache is older than 1 hour
      register: apt_update_result
    
    - name: Show update results
      ansible.builtin.debug:
        msg: "Apt cache updated: {{ apt_update_result.changed }}"
    
    - name: Install Nginx web server
      ansible.builtin.apt:
        name: nginx
        state: present  # 'present' means 'installed'
      register: nginx_install_result
    
    - name: Show installation results  
      ansible.builtin.debug:
        msg: "Nginx installation changed system: {{ nginx_install_result.changed }}"
    
    - name: Ensure Nginx service is running and enabled
      ansible.builtin.service:
        name: nginx
        state: started    # Make sure it's running now
        enabled: yes      # Make sure it starts on boot
      register: nginx_service_result
    
    - name: Show service management results
      ansible.builtin.debug:
        msg: "Nginx service status changed: {{ nginx_service_result.changed }}"
    
    - name: Check if Nginx is responding
      ansible.builtin.uri:
        url: http://localhost
        method: GET
        return_content: yes
      register: nginx_response
    
    - name: Display Nginx response
      ansible.builtin.debug:
        msg: "Nginx is responding! Status: {{ nginx_response.status }}"
```

### Step 3: Run Your First Package Management Playbook

```bash
# Run the playbook
ansible-playbook playbooks/web-server.yml

# Verify Nginx is working
curl http://localhost
# OR open your web browser and go to http://localhost
```

**Expected Output for First Run:**
- `apt_update_result.changed` = true (cache was updated)
- `nginx_install_result.changed` = true (nginx was installed)
- `nginx_service_result.changed` = true (service was started/enabled)

**Expected Output for Second Run:**
```bash
# Run the same playbook again
ansible-playbook playbooks/web-server.yml
```
- `apt_update_result.changed` = false (cache still fresh)
- `nginx_install_result.changed` = false (nginx already installed)
- `nginx_service_result.changed` = false (service already running)

**This demonstrates idempotency in action!** 🎉

### Step 4: Create a More Complex Package Management Example

Let's install multiple packages that work together:

```bash
nano playbooks/dev-tools.yml
```

**Paste this development tools setup:**
```yaml
---
- name: Install Development Tools and Utilities
  hosts: local
  become: yes
  gather_facts: yes
  
  vars:
    # Define packages as variables for easy modification
    system_packages:
      - curl
      - wget
      - git
      - htop
      - tree
      - unzip
      - vim
    
    python_packages:
      - python3
      - python3-pip
      - python3-venv
    
    development_packages:
      - build-essential
      - nodejs
      - npm
  
  tasks:
    - name: Update package cache
      ansible.builtin.apt:
        update_cache: yes
        cache_valid_time: 1800  # 30 minutes
    
    - name: Install essential system utilities
      ansible.builtin.apt:
        name: "{{ system_packages }}"
        state: present
    
    - name: Install Python development tools
      ansible.builtin.apt:
        name: "{{ python_packages }}"  
        state: present
    
    - name: Install development packages
      ansible.builtin.apt:
        name: "{{ development_packages }}"
        state: present
    
    - name: Verify Git installation
      ansible.builtin.command: git --version
      register: git_version
      changed_when: false  # This command doesn't change anything
    
    - name: Show installed Git version
      ansible.builtin.debug:
        msg: "Installed {{ git_version.stdout }}"
    
    - name: Verify Node.js installation
      ansible.builtin.command: node --version
      register: node_version  
      changed_when: false
    
    - name: Show installed Node.js version
      ansible.builtin.debug:
        msg: "Installed Node.js {{ node_version.stdout }}"
    
    - name: Create a development workspace
      ansible.builtin.file:
        path: "{{ ansible_env.HOME }}/development"
        state: directory
        mode: '0755'
        owner: "{{ ansible_env.USER }}"
    
    - name: Create a sample project structure
      ansible.builtin.file:
        path: "{{ ansible_env.HOME }}/development/{{ item }}"
        state: directory
        mode: '0755'
        owner: "{{ ansible_env.USER }}"
      loop:
        - python-projects
        - web-projects
        - ansible-projects
```

### Step 5: Understanding Service Management

Let's create a playbook focused on service management:

```bash
nano playbooks/service-management.yml
```

**Paste this service-focused example:**
```yaml
---
- name: Service Management Examples
  hosts: local
  become: yes
  gather_facts: yes
  
  tasks:
    - name: Ensure SSH service is running (should already be)
      ansible.builtin.service:
        name: ssh
        state: started
        enabled: yes
    
    - name: Install Apache2 (alternative web server)
      ansible.builtin.apt:
        name: apache2
        state: present
    
    - name: Stop Apache2 (since we're using Nginx)
      ansible.builtin.service:
        name: apache2
        state: stopped
        enabled: no
      
    - name: Ensure Nginx is the active web server
      ansible.builtin.service:
        name: nginx
        state: started
        enabled: yes
    
    - name: Get status of all web-related services
      ansible.builtin.shell: systemctl status nginx apache2 --no-pager -l
      register: web_services_status
      changed_when: false
      failed_when: false  # Don't fail if Apache2 is stopped
    
    - name: Show web services status
      ansible.builtin.debug:
        msg: "{{ web_services_status.stdout_lines }}"
```

### Step 6: Package Removal and Cleanup

Sometimes you need to remove software:

```bash
nano playbooks/cleanup-example.yml  
```

**Paste this cleanup example:**
```yaml
---
- name: Package Cleanup Example
  hosts: local
  become: yes
  
  tasks:
    - name: Remove Apache2 (keeping Nginx)
      ansible.builtin.apt:
        name: apache2
        state: absent  # 'absent' means 'uninstalled'
    
    - name: Remove unused packages (autoremove)
      ansible.builtin.apt:
        autoremove: yes
    
    - name: Clean package cache
      ansible.builtin.apt:
        autoclean: yes
    
    - name: Show disk space after cleanup
      ansible.builtin.shell: df -h /
      register: disk_space
      changed_when: false
    
    - name: Display available disk space
      ansible.builtin.debug:
        msg: "{{ disk_space.stdout_lines }}"
```

## Code Examples
- `playbooks/web.yml` above.

## Hands-On Exercise

**Complete these tasks to master package and service management:**

### Exercise 1: Extend the Web Server Setup
Modify `playbooks/web-server.yml` to customize Nginx:

```yaml
    - name: Install additional web tools
      ansible.builtin.apt:
        name:
          - curl
          - wget
          - certbot  # For SSL certificates
        state: present
    
    - name: Create custom web content
      ansible.builtin.copy:
        dest: /var/www/html/index.html
        content: |
          <html>
            <head><title>My Ansible-Managed Server</title></head>
            <body>
              <h1>Welcome!</h1>
              <p>This server was configured by Ansible on {{ ansible_date_time.iso8601 }}</p>
              <p>Running on: {{ ansible_distribution }} {{ ansible_distribution_version }}</p>
            </body>
          </html>
        owner: www-data
        group: www-data
        mode: '0644'
      notify: restart nginx

  handlers:
    - name: restart nginx
      ansible.builtin.service:
        name: nginx
        state: restarted
```

### Exercise 2: Create a Database Server Playbook
Create `playbooks/database.yml`:

```yaml
---
- name: Install and Configure MySQL Database
  hosts: local
  become: yes
  
  tasks:
    - name: Install MySQL server
      ansible.builtin.apt:
        name:
          - mysql-server
          - python3-pymysql  # Required for Ansible MySQL modules
        state: present
    
    - name: Start MySQL service
      ansible.builtin.service:
        name: mysql
        state: started
        enabled: yes
    
    - name: Check MySQL is responding
      ansible.builtin.command: mysqladmin ping
      register: mysql_ping
      changed_when: false
      become_user: root
    
    - name: Show MySQL status
      ansible.builtin.debug:
        msg: "MySQL is responding: {{ mysql_ping.stdout }}"
```

### Exercise 3: Package State Management
Create `playbooks/package-states.yml` to practice different package states:

```yaml
---
- name: Practice Package State Management
  hosts: local
  become: yes
  
  tasks:
    - name: Ensure specific version of a package (if available)
      ansible.builtin.apt:
        name: htop=3.*
        state: present
      ignore_errors: yes  # In case specific version isn't available
    
    - name: Ensure package is at latest version
      ansible.builtin.apt:
        name: curl
        state: latest
    
    - name: Install package only if not present
      ansible.builtin.apt:
        name: tree
        state: present
    
    - name: Conditionally install package based on OS version
      ansible.builtin.apt:
        name: snapd
        state: present
      when: ansible_distribution_version is version('18.04', '>=')
```

### Exercise 4: Service Timing and Dependencies
Create `playbooks/service-dependencies.yml`:

```yaml
---
- name: Manage Service Dependencies and Timing
  hosts: local
  become: yes
  
  tasks:
    - name: Install services with dependencies
      ansible.builtin.apt:
        name:
          - nginx
          - mysql-server
        state: present
    
    - name: Start database first (dependency)
      ansible.builtin.service:
        name: mysql
        state: started
        enabled: yes
    
    - name: Wait for MySQL to be fully ready
      ansible.builtin.wait_for:
        port: 3306
        host: localhost
        delay: 10
        timeout: 30
    
    - name: Then start web server
      ansible.builtin.service:
        name: nginx
        state: started
        enabled: yes
    
    - name: Verify both services are running
      ansible.builtin.shell: systemctl is-active mysql nginx
      register: services_status
      changed_when: false
    
    - name: Show services status
      ansible.builtin.debug:
        msg: "Services status: {{ services_status.stdout_lines }}"
```

### Exercise 5: Test Your Knowledge
Run all your playbooks and answer these questions:

```bash
# Run each playbook
ansible-playbook playbooks/web-server.yml
ansible-playbook playbooks/dev-tools.yml  
ansible-playbook playbooks/database.yml

# Check what's installed
dpkg -l | grep nginx
systemctl status nginx mysql

# Test web server
curl http://localhost

# Check your development environment
ls -la ~/development/
```

**Questions to verify your understanding:**
1. What happens when you run the same playbook twice?
2. Which tasks show "changed" vs "ok" on the second run?
3. How can you verify a service is both running and enabled?

## Troubleshooting Tips

### Package Installation Issues

**Problem:** "Unable to locate package"
```bash
# Update package cache manually first
sudo apt update

# Check if package name is correct
apt search package-name

# Use exact package names in playbooks
- name: Install with correct name
  apt:
    name: nginx  # Correct
    # NOT: name: nginx-server (wrong name)
```

**Problem:** "dpkg: error processing package"
```bash
# Fix broken packages
sudo dpkg --configure -a
sudo apt-get install -f

# Then retry Ansible playbook
ansible-playbook playbooks/web-server.yml
```

**Problem:** Permission denied errors
```bash
# Ensure you're using become: yes
- name: Install packages
  apt:
    name: nginx
    state: present
  become: yes  # Required for package installation
```

### Service Management Issues

**Problem:** Service fails to start
```bash
# Check service status manually
sudo systemctl status nginx

# Check service logs
sudo journalctl -u nginx -f

# Test configuration files
sudo nginx -t  # For nginx specifically
```

**Problem:** Service starts but stops immediately
```bash
# Check for port conflicts
sudo netstat -tlnp | grep :80

# Check if another service is using the same port
sudo systemctl stop apache2  # Stop conflicting service
sudo systemctl start nginx   # Start desired service
```

**Problem:** Service not enabling on boot
```bash
# Check systemd unit file
systemctl cat nginx

# Manually enable if needed
sudo systemctl enable nginx

# Verify it's enabled
systemctl is-enabled nginx
```

### Ansible-Specific Issues

**Problem:** Tasks hanging or timing out
```bash
# Increase timeout in ansible.cfg
timeout = 60

# Use async for long-running tasks
- name: Long package installation
  apt:
    name: large-package
    state: present
  async: 300  # 5 minutes
  poll: 10    # Check every 10 seconds
```

**Problem:** "Package not found" in Ansible but exists in apt
```bash
# Update cache in playbook
- name: Update apt cache first
  apt:
    update_cache: yes
    cache_valid_time: 3600

# Or run apt update manually
sudo apt update
```

### Verification and Validation

**Essential commands for checking your work:**
```bash
# Check installed packages
dpkg -l | grep -E "(nginx|mysql|git)"

# Check running services
systemctl list-units --type=service --state=running

# Check enabled services  
systemctl list-unit-files --type=service --state=enabled

# Check open ports
sudo netstat -tlnp

# Test web server
curl -I http://localhost

# Check disk space after installations
df -h
```

### Best Practices You've Learned

1. **Always update cache first** - Prevents "package not found" errors
2. **Use descriptive task names** - Makes troubleshooting easier
3. **Check service status** - Don't assume it started successfully
4. **Use variables for package lists** - Makes playbooks more maintainable
5. **Test manually first** - If it doesn't work manually, Ansible won't fix it
6. **Use become judiciously** - Only when needed for security

**Pro Tip:** Create a "system status" playbook for troubleshooting:
```yaml
---
- name: System Status Check
  hosts: local
  gather_facts: yes
  
  tasks:
    - name: Show installed packages count
      shell: dpkg -l | wc -l
      register: package_count
      changed_when: false
    
    - name: Show running services
      shell: systemctl list-units --type=service --state=running --no-pager
      register: running_services  
      changed_when: false
    
    - name: Display system summary
      debug:
        msg: |
          === SYSTEM STATUS ===
          Packages installed: {{ package_count.stdout }}
          Services running: {{ running_services.stdout_lines | length }}
          Uptime: {{ ansible_uptime_seconds // 3600 }} hours
```

## Summary / Key Takeaways
- Use `apt` for packages, `service` for services.
- Idempotency is built in when using modules.

## Next Steps
- Use variables and facts to make playbooks flexible. 🔧

---

**Navigation:** [← Lesson 4](lesson-04-first-playbook.md) | [Next: Lesson 6 →](lesson-06-variables-facts.md)