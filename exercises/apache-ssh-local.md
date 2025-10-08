# Exercise: Install Apache over SSH to Localhost (127.0.0.1) - REVISED

## ✅ Prerequisites
- Ubuntu/Debian (or a Linux with package manager) on the same machine
- Ansible installed on the controller (this machine)
- SSH server (sshd) running locally and accepting connections
- A user with sudo privileges (passwordless sudo recommended for smoother runs)
- Internet connection for package downloads

## 🔑 Step 1: Establish SSH Connectivity to Localhost

### What is SSH and Why Do We Need It?

**SSH (Secure Shell)** is like a secure tunnel that lets you control one computer from another computer. Think of it like remote desktop, but for command-line access.

**In this exercise:**
- **Controller** = Your Ubuntu machine running Ansible
- **Node** = The same Ubuntu machine, but accessed via SSH (127.0.0.1)

**Why practice with localhost?**
- Same skills work on real remote servers
- Safe environment - can't break other people's computers
- No network issues to troubleshoot
- Learn SSH concepts without complexity

### 1.1 Install and Start SSH Server

**What we're doing:** Installing the SSH server so your machine can accept SSH connections (even from itself).

```bash
# Step 1: Update package list (like refreshing an app store)
sudo apt update

# Step 2: Install SSH server (the program that accepts SSH connections)
sudo apt install -y openssh-server

# Step 3: Enable SSH to start automatically when computer boots
sudo systemctl enable ssh

# Step 4: Start SSH service right now
sudo systemctl start ssh

# Step 5: Check if SSH is running (should show "active (running)")
sudo systemctl status ssh
```

**Expected output for status check:**
```
● ssh.service - OpenBSD Secure Shell server
   Loaded: loaded (/lib/systemd/system/ssh.service; enabled; vendor preset: enabled)
   Active: active (running) since [date/time]
```

**Verification step:**
```bash
# Check if SSH is listening on port 22 (the standard SSH port)
sudo ss -tlnp | grep :22
```

**Expected output:**
```
LISTEN   0   128   0.0.0.0:22   0.0.0.0:*   users:(("sshd",pid=1234,fd=3))
```

**🚨 Troubleshooting:**
- If `systemctl status ssh` shows "failed", try: `sudo systemctl restart ssh`
- If port 22 isn't listening, check firewall: `sudo ufw status`

### 1.2 Generate SSH Key Pair

**What are SSH keys?**
Think of SSH keys like a special lock and key system:
- **Private key** (`id_rsa`) = Your secret key (like your house key)
- **Public key** (`id_rsa.pub`) = The lock you install on servers (like your door lock)

**Why use keys instead of passwords?**
- More secure than passwords
- No typing passwords every time
- Required for production servers
- Ansible works better with keys

**Step-by-step key generation:**

```bash
# Generate SSH key pair
ssh-keygen -t rsa -b 4096 -C "ansible-controller-$(whoami)"
```

**What each part means:**
- `ssh-keygen` = The command to create SSH keys
- `-t rsa` = Type of encryption (RSA is widely supported)
- `-b 4096` = Key length in bits (longer = more secure)
- `-C "comment"` = A label to identify this key

**Interactive prompts you'll see:**

1. **File location prompt:**
   ```
   Enter file in which to save the key (/home/username/.ssh/id_rsa):
   ```
   **Just press Enter** (uses default location)

2. **Passphrase prompt:**
   ```
   Enter passphrase (empty for no passphrase):
   ```
   **For learning, press Enter twice** (no passphrase)
   
   *Note: In production, use a passphrase for extra security*

**What gets created:**
```bash
# Private key (keep this SECRET!)
~/.ssh/id_rsa

# Public key (safe to share)
~/.ssh/id_rsa.pub
```

**View your new public key:**
```bash
cat ~/.ssh/id_rsa.pub
```

**Expected output (yours will be different):**
```
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC... ansible-controller-username
```

### 1.3 Add Public Key to Authorized Keys

**What is authorized_keys?**
The `authorized_keys` file is like a list of "approved keys" that can access your account via SSH. It's like having multiple copies of your house key for trusted people.

**Why are we adding our own key?**
We're essentially giving ourselves permission to SSH into our own machine. This simulates what you'd do on a real server.

**Step-by-step setup:**

```bash
# Step 1: Copy your public key to the authorized_keys file
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
```

**What this command does:**
- `cat` = Display file contents
- `~/.ssh/id_rsa.pub` = Your public key file
- `>>` = Append to file (don't overwrite)
- `~/.ssh/authorized_keys` = File that lists allowed keys

**Step 2: Set correct permissions (CRITICAL for security):**
```bash
# Make authorized_keys readable/writable only by you
chmod 600 ~/.ssh/authorized_keys

# Make .ssh directory accessible only by you
chmod 700 ~/.ssh
```

**Why permissions matter:**
- SSH refuses to work if permissions are too open
- `600` = owner can read/write, nobody else can access
- `700` = owner can read/write/execute, nobody else can access

**Verify everything is set up correctly:**
```bash
# Check permissions (should show 700 for .ssh, 600 for files)
ls -la ~/.ssh/
```

**Expected output:**
```
drwx------  2 username username 4096 [date] .
drwxr-xr-x 15 username username 4096 [date] ..
-rw-------  1 username username  xxx [date] authorized_keys
-rw-------  1 username username  xxx [date] id_rsa
-rw-r--r--  1 username username  xxx [date] id_rsa.pub
```

**🚨 Common Permission Errors:**
- If you see `drwxrwxrwx` or similar, run the chmod commands again
- SSH will fail silently if permissions are wrong

### 1.4 Test SSH Connectivity

**What we're testing:**
Can we SSH into our own machine using the keys we just set up?

**Understanding the test command:**
```bash
ssh -o StrictHostKeyChecking=no 127.0.0.1 "whoami"
```

**Breaking down the command:**
- `ssh` = Connect via SSH
- `-o StrictHostKeyChecking=no` = Don't ask about host fingerprints (safe for localhost)
- `127.0.0.1` = IP address for localhost (your own machine)
- `"whoami"` = Command to run on the remote system (shows current username)

**Run the test:**
```bash
ssh -o StrictHostKeyChecking=no 127.0.0.1 "whoami"
```

**✅ SUCCESS - Expected output:**
```
username
```
(Your actual username should appear)

**❌ FAILURE - Possible outputs and solutions:**

**Problem 1: Password prompt appears**
```
username@127.0.0.1's password:
```
**Solution:** Key setup didn't work. Check:
- Did `authorized_keys` file get created? `ls ~/.ssh/authorized_keys`
- Are permissions correct? `ls -la ~/.ssh/`
- Is SSH server running? `sudo systemctl status ssh`

**Problem 2: Connection refused**
```
ssh: connect to host 127.0.0.1 port 22: Connection refused
```
**Solution:** SSH server isn't running
```bash
sudo systemctl start ssh
sudo systemctl status ssh
```

**Problem 3: Permission denied**
```
Permission denied (publickey).
```
**Solution:** Key or permission issues
```bash
# Check if private key exists and has correct permissions
ls -la ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa

# Check if public key is in authorized_keys
grep "$(cat ~/.ssh/id_rsa.pub)" ~/.ssh/authorized_keys
```

**Interactive SSH test (optional):**
```bash
# Connect interactively (you can run commands and then 'exit')
ssh 127.0.0.1

# You should get a shell prompt like:
# username@hostname:~$
# Type 'exit' to disconnect
```

### 1.5 Troubleshooting SSH Issues

**If SSH still doesn't work, here's how to diagnose and fix it:**

#### Check SSH Server Configuration

```bash
# View SSH server configuration
sudo nano /etc/ssh/sshd_config
```

**Look for these settings (use Ctrl+W to search in nano):**
```
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
PasswordAuthentication yes
```

**If any are commented out (have # at the start) or set to 'no':**
1. Remove the `#` at the beginning of the line
2. Change `no` to `yes`
3. Save with `Ctrl+X`, then `Y`, then `Enter`

**Restart SSH after configuration changes:**
```bash
sudo systemctl restart ssh
sudo systemctl status ssh
```

#### Detailed SSH Connection Test

```bash
# Test with verbose output to see what's happening
ssh -vvv 127.0.0.1
```

**What to look for in verbose output:**
- `debug1: Authentications that can continue: publickey,password` (good)
- `debug1: Offering public key` (trying to use your key)
- `debug1: Authentication succeeded (publickey)` (success!)

#### Check SSH Logs

```bash
# Monitor SSH logs in real-time (run in another terminal)
sudo journalctl -u ssh -f

# Then try SSH connection in your main terminal
# Watch for error messages in the log terminal
```

#### Permission Check Script

```bash
# Run this comprehensive check
echo "=== SSH Setup Verification ==="
echo "SSH service status:"
systemctl is-active ssh

echo "SSH listening on port 22:"
ss -tlnp | grep :22

echo "SSH directory permissions:"
ls -ld ~/.ssh

echo "Key file permissions:"
ls -l ~/.ssh/

echo "Authorized keys content:"
wc -l ~/.ssh/authorized_keys
echo "Your key in authorized_keys:"
grep -c "$(cat ~/.ssh/id_rsa.pub | cut -d' ' -f2)" ~/.ssh/authorized_keys
```

**Expected output from verification script:**
```
=== SSH Setup Verification ===
SSH service status:
active

SSH listening on port 22:
LISTEN   0   128   0.0.0.0:22   0.0.0.0:*

SSH directory permissions:
drwx------ 2 username username 4096 [date] /home/username/.ssh

Key file permissions:
-rw------- 1 username username [size] [date] authorized_keys
-rw------- 1 username username [size] [date] id_rsa
-rw-r--r-- 1 username username [size] [date] id_rsa.pub

Your key in authorized_keys:
1
```

#### Reset SSH Setup (Last Resort)

```bash
# If all else fails, start over:
# 1. Remove existing keys
rm -f ~/.ssh/id_rsa ~/.ssh/id_rsa.pub ~/.ssh/authorized_keys

# 2. Regenerate keys
ssh-keygen -t rsa -b 4096 -C "ansible-$(whoami)" -f ~/.ssh/id_rsa -N ""

# 3. Add to authorized keys
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

# 4. Set permissions
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub

# 5. Test again
ssh -o StrictHostKeyChecking=no 127.0.0.1 "whoami"
```ache over SSH to Localhost (127.0.0.1)

This exercise demonstrates using SSH (not ansible_connection=local) to manage a node. We’ll treat your own machine (127.0.0.1) as a remote host and connect via SSH, then install and start Apache (httpd on RHEL, apache2 on Debian/Ubuntu).

## 🎯 Objectives
- Establish SSH connectivity between the Ansible controller and a target node (localhost)
- Write and run an Ansible playbook to install Apache
- Verify Apache is running and serving a page

## ✅ Prerequisites
- Ubuntu/Debian (or a Linux with package manager) on the same machine
- Ansible installed on the controller (this machine)
- SSH server (sshd) running locally and accepting connections
- A user with sudo privileges (passwordless sudo recommended for smoother runs)

If SSH isn’t installed/running locally:
```bash
sudo apt update
sudo apt install -y openssh-server
sudo systemctl enable --now ssh
sudo systemctl status ssh
```

## 🧭 Step 2: Create Inventory for SSH to Localhost

### What is an Ansible Inventory?

**Think of inventory as:**
- A phone book of servers Ansible can manage
- A list telling Ansible "how to connect to what"
- Configuration for each server (IP, username, SSH keys, etc.)

**In this exercise:**
We're creating an inventory that treats localhost (127.0.0.1) as a remote server accessed via SSH.

### 2.1 Understanding Inventory Structure

**Basic inventory format:**
```ini
[group_name]
hostname_or_ip ansible_variable=value

[group_name:vars]
variable_for_all_hosts_in_group=value
```

**Our SSH localhost inventory:**
```ini
[ssh_local]                                    # Group name
127.0.0.1 ansible_connection=ssh ansible_user=YOUR_USERNAME

[ssh_local:vars]                               # Variables for ssh_local group
ansible_ssh_private_key_file=~/.ssh/id_rsa    # Which key file to use
ansible_ssh_common_args='-o StrictHostKeyChecking=no'  # SSH options
ansible_python_interpreter=/usr/bin/python3   # Python location on target
```

### 2.2 Create Your Inventory File

**Step 1: Create the inventory file**
```bash
# Create the examples directory if it doesn't exist
mkdir -p examples

# Create the inventory file
cat > examples/inventory-ssh-local.ini << 'EOF'
# Manage localhost over SSH as if it were remote
[ssh_local]
127.0.0.1 ansible_connection=ssh ansible_user=YOUR_USERNAME ansible_port=22

[ssh_local:vars]
# Use SSH key authentication (recommended)
ansible_ssh_private_key_file=~/.ssh/id_rsa
# Disable host key checking for localhost  
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
ansible_python_interpreter=/usr/bin/python3
EOF
```

**Step 2: Replace YOUR_USERNAME with your actual username**
```bash
# Check your username first
echo "Your username is: $(whoami)"

# Replace YOUR_USERNAME in the file with your actual username
sed -i "s/YOUR_USERNAME/$(whoami)/g" examples/inventory-ssh-local.ini

# Alternative method if sed doesn't work:
USERNAME=$(whoami)
sed -i "s/YOUR_USERNAME/$USERNAME/g" examples/inventory-ssh-local.ini
```

**Step 3: Verify the inventory looks correct**
```bash
cat examples/inventory-ssh-local.ini
```

**Expected output (with your username):**
```ini
# Manage localhost over SSH as if it were remote
[ssh_local]
127.0.0.1 ansible_connection=ssh ansible_user=yourusername ansible_port=22

[ssh_local:vars]
# Use SSH key authentication (recommended)
ansible_ssh_private_key_file=~/.ssh/id_rsa
# Disable host key checking for localhost
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
ansible_python_interpreter=/usr/bin/python3
```

### 2.3 Understanding Each Inventory Setting

**Host-specific settings:**
- `127.0.0.1` = The IP address (localhost)
- `ansible_connection=ssh` = Use SSH instead of local connection
- `ansible_user=yourusername` = SSH username to connect as
- `ansible_port=22` = SSH port (22 is default)

**Group variables (apply to all hosts in [ssh_local] group):**
- `ansible_ssh_private_key_file=~/.ssh/id_rsa` = Path to your SSH private key
- `ansible_ssh_common_args='-o StrictHostKeyChecking=no'` = SSH options
- `ansible_python_interpreter=/usr/bin/python3` = Which Python to use on target

**Why StrictHostKeyChecking=no?**
- Normally SSH asks "Are you sure you want to connect?" for new hosts
- This disables that prompt for localhost (safe in this case)
- In production, you'd properly manage host keys

## 🔗 Step 3: Test Ansible Connectivity 

### What Are We Testing?

Before running complex playbooks, we need to verify:
1. **Ansible can connect** to the host via SSH
2. **Ansible can gather information** about the system
3. **Our inventory configuration** is correct

**The `ping` module:**
- Not a network ping (ICMP)
- Tests if Ansible can connect and run Python on the target
- Returns "pong" if successful

### 3.1 Create Connectivity Test Playbook

**Understanding playbook structure:**
```yaml
---                              # YAML document start
- name: Human-readable description
  hosts: group_from_inventory    # Which hosts to target
  gather_facts: yes              # Collect system information
  tasks:                         # List of things to do
    - name: Task description
      module.name:               # Ansible module to use
        parameter: value
```

**Create the connectivity test:**
```bash
# Create the ping test playbook
cat > examples/ping-ssh-local.yml << 'EOF'
---
- name: Test SSH connectivity to localhost
  hosts: ssh_local
  gather_facts: yes
  tasks:
    - name: Ping the host over SSH
      ansible.builtin.ping:
      
    - name: Display connection info
      ansible.builtin.debug:
        msg: |
          Connected to: {{ inventory_hostname }}
          OS Family: {{ ansible_facts.os_family }}
          User: {{ ansible_facts.user_id }}
          Python: {{ ansible_facts.python_version }}
          
    - name: Show we can run commands
      ansible.builtin.command: whoami
      register: whoami_result
      
    - name: Display command result
      ansible.builtin.debug:
        msg: "Command 'whoami' returned: {{ whoami_result.stdout }}"
EOF
```

**What each task does:**
1. **Ping:** Tests basic connectivity and Python availability
2. **Display connection info:** Shows system facts Ansible gathered
3. **Run whoami command:** Proves we can execute commands on target
4. **Display result:** Shows the command output

### 3.2 Run Connectivity Test
```bash
# Test with SSH key (recommended)
ansible-playbook -i examples/inventory-ssh-local.ini examples/ping-ssh-local.yml

# If you get permission errors, add sudo password prompt
ansible-playbook -i examples/inventory-ssh-local.ini examples/ping-ssh-local.yml -K

# For detailed output
ansible-playbook -i examples/inventory-ssh-local.ini examples/ping-ssh-local.yml -v
```

### 3.3 Expected Output
```
PLAY [Test SSH connectivity to localhost] ****

TASK [Ping the host over SSH] ****
ok: [127.0.0.1]

TASK [Display connection info] ****
ok: [127.0.0.1] => {
    "msg": "Connected to: 127.0.0.1\nOS Family: Debian\nUser: your-username\nPython: 3.x.x"
}

PLAY RECAP ****
127.0.0.1 : ok=2 changed=0 unreachable=0 failed=0
```

## 📄 Step 4: Write Apache Installation Playbook

### 4.1 Simple Playbook (Recommended First Approach)

Create `examples/apache-ssh-simple.yml`:

```bash
cat > examples/apache-ssh-simple.yml << 'EOF'
---
- name: Install Apache via SSH (Simple Method)
  hosts: ssh_local
  become: yes
  gather_facts: yes

  tasks:
    - name: Ensure apt is unlocked and clean
      shell: |
        pkill apt || true
        pkill apt-get || true
        pkill dpkg || true
        rm -f /var/lib/dpkg/lock*
        rm -f /var/cache/apt/archives/lock
        rm -f /var/lib/apt/lists/lock
        dpkg --configure -a || true
        apt clean
      changed_when: false
      failed_when: false

    - name: Update package cache manually
      shell: apt update
      retries: 3
      delay: 5
      register: apt_update_result
      until: apt_update_result.rc == 0

    - name: Install Apache manually
      shell: apt install -y apache2
      register: apache_install
      retries: 2
      delay: 3

    - name: Start and enable Apache
      systemd:
        name: apache2
        state: started
        enabled: yes
        daemon_reload: yes

    - name: Verify Apache is running
      shell: systemctl is-active apache2
      register: apache_status
      failed_when: apache_status.rc != 0

    - name: Create custom index.html
      copy:
        dest: /var/www/html/index.html
        content: |
          <!DOCTYPE html>
          <html>
          <head><title>Ansible Success!</title></head>
          <body>
            <h1>🎉 Apache installed via Ansible over SSH!</h1>
            <p><strong>Host:</strong> {{ inventory_hostname }}</p>
            <p><strong>User:</strong> {{ ansible_facts.user_id }}</p>
            <p><strong>OS:</strong> {{ ansible_facts.distribution }} {{ ansible_facts.distribution_version }}</p>
            <p><strong>Date:</strong> {{ ansible_date_time.date }} {{ ansible_date_time.time }}</p>
            <p><strong>Apache Version:</strong> {{ ansible_facts.packages['apache2'][0].version | default('Unknown') }}</p>
          </body>
          </html>
        mode: '0644'

    - name: Test Apache is responding
      uri:
        url: http://127.0.0.1
        method: GET
        status_code: 200
      register: web_test

    - name: Display success message
      debug:
        msg: |
          ✅ Apache installation completed successfully!
          🌐 Web server is accessible at: http://127.0.0.1
          📊 HTTP Response: {{ web_test.status }}
EOF
```

### 4.2 Advanced Playbook (If Simple Method Works)

Create `examples/apache-ssh-advanced.yml`:

```bash
cat > examples/apache-ssh-advanced.yml << 'EOF'
---
- name: Install Apache with advanced error handling
  hosts: ssh_local
  become: yes
  gather_facts: yes
  vars:
    apache_packages:
      - apache2
      - apache2-utils
    apache_mods:
      - rewrite
      - ssl

  tasks:
    - name: Pre-flight system check
      block:
        - name: Check system resources
          shell: |
            echo "Disk space: $(df -h / | tail -1 | awk '{print $4}')"
            echo "Memory: $(free -h | grep '^Mem:' | awk '{print $7}')"
            echo "Network: $(ping -c1 8.8.8.8 >/dev/null 2>&1 && echo 'OK' || echo 'FAIL')"
          register: system_check

        - name: Display system status
          debug:
            msg: "{{ system_check.stdout_lines }}"

    - name: Clean package management system
      block:
        - name: Kill stuck processes
          shell: pkill {{ item }} || true
          loop: [apt, apt-get, dpkg, unattended-upgrades]
          changed_when: false
          failed_when: false

        - name: Remove lock files
          file:
            path: "{{ item }}"
            state: absent
          loop:
            - /var/lib/dpkg/lock
            - /var/lib/dpkg/lock-frontend
            - /var/cache/apt/archives/lock
            - /var/lib/apt/lists/lock
          failed_when: false

        - name: Configure interrupted packages
          command: dpkg --configure -a
          failed_when: false
          changed_when: false

    - name: Update and install packages
      block:
        - name: Update apt cache with timeout
          apt:
            update_cache: yes
            cache_valid_time: 0
          timeout: 300
          retries: 3
          delay: 10
          register: apt_result
          until: apt_result is succeeded

        - name: Install Apache packages
          apt:
            name: "{{ apache_packages }}"
            state: present
            update_cache: no
          retries: 3
          delay: 5

        - name: Enable Apache modules
          apache2_module:
            name: "{{ item }}"
            state: present
          loop: "{{ apache_mods }}"
          notify: restart apache

    - name: Configure and start Apache
      block:
        - name: Ensure Apache is started and enabled
          systemd:
            name: apache2
            state: started
            enabled: yes
            daemon_reload: yes

        - name: Wait for Apache to be ready
          wait_for:
            port: 80
            host: 127.0.0.1
            delay: 2
            timeout: 30

        - name: Create enhanced index page
          template:
            dest: /var/www/html/index.html
            content: |
              <!DOCTYPE html>
              <html lang="en">
              <head>
                  <meta charset="UTF-8">
                  <meta name="viewport" content="width=device-width, initial-scale=1.0">
                  <title>Ansible Apache Deployment</title>
                  <style>
                      body { font-family: Arial, sans-serif; margin: 40px; background: #f4f4f4; }
                      .container { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
                      .success { color: #28a745; }
                      .info { background: #e9f4ff; padding: 10px; border-left: 4px solid #007bff; margin: 10px 0; }
                  </style>
              </head>
              <body>
                  <div class="container">
                      <h1 class="success">🎉 Apache Successfully Deployed via Ansible SSH!</h1>
                      
                      <div class="info">
                          <h3>📊 System Information</h3>
                          <p><strong>Target Host:</strong> {{ inventory_hostname }}</p>
                          <p><strong>Connected User:</strong> {{ ansible_facts.user_id }}</p>
                          <p><strong>Operating System:</strong> {{ ansible_facts.distribution }} {{ ansible_facts.distribution_version }}</p>
                          <p><strong>Kernel:</strong> {{ ansible_facts.kernel }}</p>
                          <p><strong>Architecture:</strong> {{ ansible_facts.architecture }}</p>
                      </div>

                      <div class="info">
                          <h3>🕒 Deployment Details</h3>
                          <p><strong>Date:</strong> {{ ansible_date_time.date }}</p>
                          <p><strong>Time:</strong> {{ ansible_date_time.time }}</p>
                          <p><strong>Timezone:</strong> {{ ansible_date_time.tz }}</p>
                          <p><strong>Ansible Version:</strong> {{ ansible_version.full }}</p>
                      </div>

                      <div class="info">
                          <h3>🔧 Apache Configuration</h3>
                          <p><strong>Document Root:</strong> /var/www/html</p>
                          <p><strong>Configuration:</strong> /etc/apache2/apache2.conf</p>
                          <p><strong>Enabled Modules:</strong> {{ apache_mods | join(', ') }}</p>
                      </div>

                      <h3>✅ Deployment Status: SUCCESS</h3>
                      <p>This page was generated automatically by Ansible playbook execution.</p>
                  </div>
              </body>
              </html>
            mode: '0644'
          notify: restart apache

    - name: Final verification
      block:
        - name: Test HTTP response
          uri:
            url: http://127.0.0.1
            method: GET
            status_code: 200
            return_content: yes
          register: http_test

        - name: Verify Apache configuration
          command: apache2ctl configtest
          register: config_test
          changed_when: false

        - name: Display deployment summary
          debug:
            msg: |
              🎉 APACHE DEPLOYMENT COMPLETED SUCCESSFULLY! 🎉
              
              📍 Access your web server: http://127.0.0.1
              📊 HTTP Status: {{ http_test.status }}
              ⚙️  Config Test: {{ config_test.stdout }}
              📁 Document Root: /var/www/html
              📋 Log Files: /var/log/apache2/
              
              🔧 Management Commands:
              - sudo systemctl status apache2
              - sudo systemctl restart apache2
              - sudo apache2ctl configtest

  handlers:
    - name: restart apache
      systemd:
        name: apache2
        state: restarted
EOF
```

### 4.3 Run the Apache Installation Playbook

**Start with the simple method:**

```bash
# Run the simple playbook first
ansible-playbook -i examples/inventory-ssh-local.ini examples/apache-ssh-simple.yml -K

# If you want to see detailed output
ansible-playbook -i examples/inventory-ssh-local.ini examples/apache-ssh-simple.yml -K -v

# For troubleshooting, use extra verbose output
ansible-playbook -i examples/inventory-ssh-local.ini examples/apache-ssh-simple.yml -K -vvv
```

**If the simple method works, try the advanced version:**

```bash
# Run the advanced playbook
ansible-playbook -i examples/inventory-ssh-local.ini examples/apache-ssh-advanced.yml -K

# Dry run to see what would be changed (recommended first)
ansible-playbook -i examples/inventory-ssh-local.ini examples/apache-ssh-advanced.yml -K --check
```

**Expected Output (Simple Method):**
```
PLAY [Install Apache via SSH (Simple Method)] ****

TASK [Gathering Facts] ****
ok: [127.0.0.1]

TASK [Ensure apt is unlocked and clean] ****
ok: [127.0.0.1]

TASK [Update package cache manually] ****
changed: [127.0.0.1]

TASK [Install Apache manually] ****
changed: [127.0.0.1]

TASK [Start and enable Apache] ****
changed: [127.0.0.1]

TASK [Verify Apache is running] ****
ok: [127.0.0.1]

TASK [Create custom index.html] ****
changed: [127.0.0.1]

TASK [Test Apache is responding] ****
ok: [127.0.0.1]

TASK [Display success message] ****
ok: [127.0.0.1] => {
    "msg": "✅ Apache installation completed successfully!\n🌐 Web server is accessible at: http://127.0.0.1\n📊 HTTP Response: 200"
}

PLAY RECAP ****
127.0.0.1 : ok=9 changed=4 unreachable=0 failed=0
```

## 🔎 Step 5: Verify Apache Installation

### 5.1 Check Apache Service Status
```bash
# Check if Apache is running
systemctl status apache2

# Check if Apache is listening on port 80
sudo netstat -tlnp | grep :80

# Check Apache process
ps aux | grep apache2
```

### 5.2 Test Web Server
```bash
# Quick HTTP status check
curl -I http://127.0.0.1

# View the full page
curl http://127.0.0.1

# Check specific content
curl -s http://127.0.0.1 | grep -i "apache.*ansible"

# Test with wget (alternative)
wget -qO- http://127.0.0.1 | head -10

# Advanced testing
curl -w "Response Time: %{time_total}s\nHTTP Code: %{http_code}\n" -s -o /dev/null http://127.0.0.1
```

**Expected curl output:**
```
HTTP/1.1 200 OK
Date: [current date]
Server: Apache/2.4.xx (Ubuntu)
Content-Type: text/html
```

### 5.3 Browser Test
- Open http://127.0.0.1 in your web browser
- You should see: "Apache installed via Ansible over SSH 🎉"

### 5.4 Apache Configuration Files
```bash
# Main Apache configuration
sudo nano /etc/apache2/apache2.conf

# Document root (where web files are served from)
ls -la /var/www/html/

# Apache logs
sudo tail -f /var/log/apache2/access.log
sudo tail -f /var/log/apache2/error.log
```

## 🧪 Troubleshooting and Advanced Options

### Quick Diagnostic Script

Create a comprehensive diagnostic script:

```bash
cat > examples/diagnose-system.sh << 'EOF'
#!/bin/bash
echo "=== ANSIBLE SSH APACHE DIAGNOSTIC SCRIPT ==="
echo "Date: $(date)"
echo "User: $(whoami)"
echo

echo "1. SSH Connectivity Test:"
ssh -o ConnectTimeout=5 127.0.0.1 "echo 'SSH: ✅ Connected'" 2>/dev/null || echo "SSH: ❌ Failed"
echo

echo "2. System Resources:"
echo "Disk Space: $(df -h / | tail -1 | awk '{print $4}') available"
echo "Memory: $(free -h | grep '^Mem:' | awk '{print $7}') available"
echo "Load: $(uptime | awk -F'load average:' '{print $2}')"
echo

echo "3. Network Connectivity:"
ping -c1 8.8.8.8 >/dev/null 2>&1 && echo "Internet: ✅ Connected" || echo "Internet: ❌ No connection"
nslookup archive.ubuntu.com >/dev/null 2>&1 && echo "DNS: ✅ Working" || echo "DNS: ❌ Failed"
echo

echo "4. Package Management Status:"
ps aux | grep -E "(apt|dpkg)" | grep -v grep | wc -l | awk '{if($1>0) print "Apt processes: ❌ " $1 " running"; else print "Apt processes: ✅ None running"}'
ls /var/lib/dpkg/lock* 2>/dev/null | wc -l | awk '{if($1>0) print "Lock files: ❌ " $1 " present"; else print "Lock files: ✅ None found"}'
echo

echo "5. Apache Status:"
if systemctl is-active apache2 >/dev/null 2>&1; then
    echo "Apache: ✅ Running"
    echo "Port 80: $(ss -tlnp | grep :80 >/dev/null && echo '✅ Listening' || echo '❌ Not listening')"
else
    echo "Apache: ❌ Not running"
fi
echo

echo "6. Suggested Actions:"
if ! ssh -o ConnectTimeout=5 127.0.0.1 "exit" >/dev/null 2>&1; then
    echo "- Fix SSH connectivity first"
fi

if ps aux | grep -E "(apt|dpkg)" | grep -v grep >/dev/null; then
    echo "- Kill stuck package management processes: sudo pkill apt; sudo pkill dpkg"
fi

if ls /var/lib/dpkg/lock* >/dev/null 2>&1; then
    echo "- Remove lock files: sudo rm /var/lib/dpkg/lock*"
fi

if ! ping -c1 8.8.8.8 >/dev/null 2>&1; then
    echo "- Check internet connection"
fi

echo "=== END DIAGNOSTIC ==="
EOF

chmod +x examples/diagnose-system.sh
./examples/diagnose-system.sh
```

### Emergency Fix Script

Create an automated fix script for common issues:

```bash
cat > examples/emergency-fix.sh << 'EOF'
#!/bin/bash
echo "=== EMERGENCY ANSIBLE/APACHE FIX SCRIPT ==="
echo "This script will attempt to fix common issues..."
echo

# Function to run commands with error handling
safe_run() {
    echo "Running: $1"
    eval "$1" && echo "✅ Success" || echo "❌ Failed (continuing...)"
    echo
}

echo "1. Killing stuck processes..."
safe_run "sudo pkill apt"
safe_run "sudo pkill apt-get" 
safe_run "sudo pkill dpkg"
safe_run "sudo pkill unattended-upgrades"

echo "2. Removing lock files..."
safe_run "sudo rm -f /var/lib/dpkg/lock*"
safe_run "sudo rm -f /var/cache/apt/archives/lock"
safe_run "sudo rm -f /var/lib/apt/lists/lock"

echo "3. Configuring interrupted packages..."
safe_run "sudo dpkg --configure -a"

echo "4. Cleaning package cache..."
safe_run "sudo apt clean"
safe_run "sudo apt autoclean"

echo "5. Updating package lists..."
safe_run "sudo apt update"

echo "6. Testing SSH connectivity..."
safe_run "ssh -o ConnectTimeout=5 127.0.0.1 'echo SSH test successful'"

echo "7. Checking if Apache is installed..."
if dpkg -l | grep apache2 >/dev/null 2>&1; then
    echo "Apache2 is already installed"
    safe_run "sudo systemctl start apache2"
    safe_run "sudo systemctl enable apache2"
else
    echo "Apache2 not installed - will be installed by playbook"
fi

echo "=== FIX SCRIPT COMPLETED ==="
echo "You can now try running your Ansible playbook again."
EOF

chmod +x examples/emergency-fix.sh
```

### Common Issues and Solutions

#### Issue 1: "Failed to update apt cache"

**Quick Fix:**
```bash
# Run the emergency fix script
./examples/emergency-fix.sh

# Then retry with the simple playbook
ansible-playbook -i examples/inventory-ssh-local.ini examples/apache-ssh-simple.yml -K
```

#### Issue 2: SSH Connection Problems

**Diagnosis:**
```bash
# Test SSH directly
ssh -vvv 127.0.0.1

# Check SSH service
sudo systemctl status ssh

# Check SSH configuration
sudo sshd -T | grep -E "(pubkey|password|auth)"
```

**Fix:**
```bash
# Restart SSH service
sudo systemctl restart ssh

# Reset SSH keys if needed
rm -f ~/.ssh/id_rsa ~/.ssh/id_rsa.pub ~/.ssh/authorized_keys
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys ~/.ssh/id_rsa
```

#### Issue 3: Package Installation Failures

**Manual Installation Test:**
```bash
# Test manual installation
ssh 127.0.0.1 "sudo apt update && sudo apt install -y apache2"

# If that fails, try:
ssh 127.0.0.1 "sudo apt-get update && sudo apt-get install -y apache2"
```

#### Issue 4: Apache Won't Start

**Diagnosis and Fix:**
```bash
# Check Apache status and logs
sudo systemctl status apache2
sudo journalctl -u apache2 --no-pager -l

# Test Apache configuration
sudo apache2ctl configtest

# Check for port conflicts
sudo netstat -tlnp | grep :80

# Manual start
sudo systemctl start apache2
```

**Quick Fix Methods:**
```bash
# Method 1: Clean and update apt manually first
ssh 127.0.0.1 "sudo apt clean && sudo apt update"

# Method 2: Kill stuck processes and retry
ssh 127.0.0.1 "sudo pkill apt; sudo pkill dpkg; sudo apt update" 

# Method 3: Use the robust playbook (handles errors automatically)
ansible-playbook -i examples/inventory-ssh-local.ini examples/apache-ssh-robust.yml -K
```

**Root Causes and Solutions:**

**1. Repository Connection Issues:**
```bash
# Check internet connectivity
ping -c 3 8.8.8.8

# Check DNS resolution
nslookup archive.ubuntu.com

# Test repository access
curl -I http://archive.ubuntu.com/ubuntu/
```

**2. Locked apt Database:**
```bash
# Check for running apt processes
ps aux | grep apt

# Kill stuck apt processes (be careful!)
sudo pkill apt
sudo pkill apt-get
sudo pkill dpkg

# Remove lock files if necessary
sudo rm /var/lib/apt/lists/lock
sudo rm /var/cache/apt/archives/lock
sudo rm /var/lib/dpkg/lock*

# Reconfigure dpkg if corrupted
sudo dpkg --configure -a
```

**3. Repository List Issues:**
```bash
# Check repository sources
cat /etc/apt/sources.list
ls /etc/apt/sources.list.d/

# Reset to default Ubuntu repositories
sudo cp /etc/apt/sources.list /etc/apt/sources.list.backup
sudo sed -i 's/^deb-src/#deb-src/' /etc/apt/sources.list
sudo apt update
```

**Improved Apache Playbook (with error handling):**

Create `examples/apache-ssh-robust.yml`:
```yaml
---
- name: Install Apache with robust error handling
  hosts: ssh_local
  become: yes
  gather_facts: yes

  tasks:
    - name: Kill any stuck apt processes
      shell: |
        pkill apt || true
        pkill apt-get || true
        pkill dpkg || true
      changed_when: false
      failed_when: false

    - name: Remove apt lock files if they exist
      file:
        path: "{{ item }}"
        state: absent
      loop:
        - /var/lib/apt/lists/lock
        - /var/cache/apt/archives/lock
        - /var/lib/dpkg/lock
        - /var/lib/dpkg/lock-frontend
      failed_when: false

    - name: Configure dpkg if needed
      command: dpkg --configure -a
      failed_when: false
      changed_when: false

    - name: Update apt cache with retry
      apt:
        update_cache: yes
        cache_valid_time: 0
      retries: 3
      delay: 5
      register: apt_update_result
      until: apt_update_result is succeeded

    - name: Install Apache with retry
      apt:
        name: apache2
        state: present
        update_cache: no
      retries: 3
      delay: 5

    - name: Start and enable Apache
      service:
        name: apache2
        state: started
        enabled: yes

    - name: Wait for Apache to be ready
      wait_for:
        port: 80
        host: 127.0.0.1
        timeout: 30

    - name: Create custom index.html
      copy:
        dest: /var/www/html/index.html
        content: |
          <h1>Apache installed via Ansible (Robust Version) 🎉</h1>
          <p>Host: {{ inventory_hostname }}</p>
          <p>OS: {{ ansible_facts.distribution }} {{ ansible_facts.distribution_version }}</p>
          <p>Date: {{ ansible_date_time.date }} {{ ansible_date_time.time }}</p>
          <p>Apache Status: Running ✅</p>
        mode: '0644'
      notify: restart apache

  handlers:
    - name: restart apache
      service:
        name: apache2
        state: restarted
```

**Run the robust version:**
```bash
ansible-playbook -i examples/inventory-ssh-local.ini examples/apache-ssh-robust.yml -K
```

**Automated Troubleshooting Scripts:**

We've included helper scripts to diagnose and fix common issues:

```bash
# Make scripts executable
chmod +x exercises/troubleshoot-apache.sh exercises/fix-apt-cache.sh

# Run diagnostic script
./exercises/troubleshoot-apache.sh

# Run automatic fix script
./exercises/fix-apt-cache.sh
```

### Common SSH Issues
```bash
# Issue: SSH connection refused
sudo systemctl status ssh
sudo systemctl start ssh

# Issue: Permission denied (publickey)
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub
chmod 700 ~/.ssh

# Issue: Host key verification failed
ssh-keyscan -H 127.0.0.1 >> ~/.ssh/known_hosts

# Test direct SSH connection
ssh -vvv 127.0.0.1
```

### Alternative Configurations
```bash
# Use password authentication instead of keys
ansible-playbook -i examples/inventory-ssh-local.ini examples/apache-ssh.yml -k -K

# Use different SSH port (if you changed default)
# Edit inventory: ansible_port=2222

# Run on specific host only
ansible-playbook -i examples/inventory-ssh-local.ini examples/apache-ssh.yml -K --limit 127.0.0.1
```

### Ultimate Fallback Method

If all else fails, here's a minimal working playbook:

```bash
cat > examples/apache-ssh-minimal.yml << 'EOF'
---
- name: Minimal Apache installation (Fallback)
  hosts: ssh_local
  become: yes
  gather_facts: no

  tasks:
    - name: Install Apache using raw commands
      raw: |
        pkill apt || true
        rm -f /var/lib/dpkg/lock* /var/cache/apt/archives/lock /var/lib/apt/lists/lock
        apt clean
        apt update -y
        apt install -y apache2
        systemctl enable apache2
        systemctl start apache2
        echo '<h1>Apache installed via Ansible (Minimal Method)</h1>' > /var/www/html/index.html

    - name: Verify installation
      raw: systemctl is-active apache2 && curl -s http://127.0.0.1 | head -1
      register: verify_result

    - name: Show result
      debug:
        msg: "{{ verify_result.stdout_lines }}"
EOF

# Run the minimal playbook
ansible-playbook -i examples/inventory-ssh-local.ini examples/apache-ssh-minimal.yml -K
```

### Passwordless Sudo Setup (Recommended)

```bash
# Add your user to sudoers for passwordless sudo
echo "$USER ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/$USER

# Verify the setting
sudo -n whoami 2>/dev/null && echo "Passwordless sudo: ✅ Working" || echo "Passwordless sudo: ❌ Not working"

# Then run without -K flag
ansible-playbook -i examples/inventory-ssh-local.ini examples/apache-ssh-simple.yml
```

### Complete Test and Verification Script

```bash
cat > examples/complete-test.sh << 'EOF'
#!/bin/bash
echo "=== COMPLETE APACHE ANSIBLE TEST ==="

# Step 1: Run diagnostics
echo "🔍 Running diagnostics..."
./examples/diagnose-system.sh

# Step 2: Run emergency fixes if needed
read -p "Run emergency fixes? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🛠️ Running emergency fixes..."
    ./examples/emergency-fix.sh
fi

# Step 3: Test SSH connectivity
echo "🔗 Testing SSH connectivity..."
if ssh -o ConnectTimeout=5 127.0.0.1 "whoami" >/dev/null 2>&1; then
    echo "✅ SSH connectivity working"
else
    echo "❌ SSH connectivity failed - fix SSH first!"
    exit 1
fi

# Step 4: Run Ansible playbook
echo "🚀 Running Ansible playbook..."
echo "Trying simple method first..."
if ansible-playbook -i examples/inventory-ssh-local.ini examples/apache-ssh-simple.yml -K; then
    echo "✅ Simple method successful!"
else
    echo "❌ Simple method failed, trying minimal method..."
    ansible-playbook -i examples/inventory-ssh-local.ini examples/apache-ssh-minimal.yml -K
fi

# Step 5: Verify installation
echo "🧪 Testing Apache installation..."
if curl -s http://127.0.0.1 >/dev/null 2>&1; then
    echo "✅ Apache is responding on http://127.0.0.1"
    echo "📄 Page content preview:"
    curl -s http://127.0.0.1 | head -5
else
    echo "❌ Apache is not responding"
fi

echo "=== TEST COMPLETED ==="
EOF

chmod +x examples/complete-test.sh
```

## 💡 Note for WSL Users (Windows Subsystem for Linux)
- You can run Ansible inside WSL (Ubuntu) and manage the same WSL distro via SSH
- You must install and start `sshd` in WSL and allow connections
- If managing Windows outside WSL, use WinRM instead of SSH (not covered here)

---

## 📋 Quick Start Summary (TL;DR)

**If you just want to get it working fast:**

```bash
# 1. Make scripts executable
chmod +x examples/*.sh

# 2. Run the complete automated test
./examples/complete-test.sh

# 3. Or run individual steps:
./examples/diagnose-system.sh        # Check system status
./examples/emergency-fix.sh          # Fix common issues
ansible-playbook -i examples/inventory-ssh-local.ini examples/apache-ssh-simple.yml -K
```

**Expected Success Indicators:**
- ✅ SSH connectivity working
- ✅ Apache service running
- ✅ HTTP 200 response from http://127.0.0.1
- ✅ Custom HTML page displaying system information

**If Simple Method Fails:**
```bash
# Try the minimal fallback method
ansible-playbook -i examples/inventory-ssh-local.ini examples/apache-ssh-minimal.yml -K
```

**Manual Verification:**
```bash
# Check Apache is running
sudo systemctl status apache2

# Test web server
curl http://127.0.0.1

# View logs if problems occur
sudo journalctl -u apache2 --no-pager -l
```

---

This revised exercise provides multiple approaches:
1. **Simple Method**: Uses shell commands to bypass apt module issues
2. **Advanced Method**: Full-featured with proper error handling  
3. **Minimal Method**: Raw commands as ultimate fallback
4. **Diagnostic Tools**: Scripts to identify and fix common problems

Perfect for practicing SSH-based Ansible workflows with Ubuntu systems!