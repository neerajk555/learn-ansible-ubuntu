# Exercis## ✅ Prerequisites
- Ubuntu/Debian (or a Linux with package manager) on the same machine
- Ansible installed on the controller (this machine)
- SSH server (sshd) running locally and accepting connections
- A user with sudo privileges (passwordless sudo recommended for smoother runs)

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
Create `examples/apache-ssh.yml`:

```yaml
---
- name: Install and start Apache over SSH (localhost)
  hosts: ssh_local
  become: yes
  gather_facts: yes

  tasks:
    - name: Update apt cache (Debian/Ubuntu)
      ansible.builtin.apt:
        update_cache: yes
      when: ansible_facts.os_family == 'Debian'

    - name: Install Apache (Debian/Ubuntu)
      ansible.builtin.apt:
        name: apache2
        state: present
      when: ansible_facts.os_family == 'Debian'

    - name: Start and enable Apache (systemd)
      ansible.builtin.service:
        name: apache2
        state: started
        enabled: yes
      when: ansible_facts.os_family == 'Debian'

    - name: Create a simple index.html
      ansible.builtin.copy:
        dest: /var/www/html/index.html
        content: |
          <h1>Apache installed via Ansible over SSH 🎉</h1>
          <p>Host: {{ inventory_hostname }}</p>
          <p>Date: {{ ansible_date_time.date }} {{ ansible_date_time.time }}</p>
        mode: '0644'
```

### 4.1 Run the Apache Installation Playbook
```bash
# Run with sudo password prompt
ansible-playbook -i examples/inventory-ssh-local.ini examples/apache-ssh.yml -K

# Run with verbose output to see each step
ansible-playbook -i examples/inventory-ssh-local.ini examples/apache-ssh.yml -K -v

# Dry run (check mode) to see what would be changed
ansible-playbook -i examples/inventory-ssh-local.ini examples/apache-ssh.yml -K --check
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
# Test with curl (command line)
curl -I http://127.0.0.1
curl http://127.0.0.1

# Check the custom page created by Ansible
curl -s http://127.0.0.1 | grep "Apache installed via Ansible"
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

## 🧪 Advanced Variations and Troubleshooting

### Common Ansible/Apache Issues

#### Issue: "Failed to update apt cache: unknown reason"

This is a common error when running the Apache installation playbook.

**Immediate Diagnostic Steps:**
```bash
# Step 1: Check if you can SSH and run basic commands
ssh 127.0.0.1 "whoami && date"

# Step 2: Check current apt status
ssh 127.0.0.1 "sudo apt list --upgradable | head -5"

# Step 3: Check for apt locks
ssh 127.0.0.1 "sudo lsof /var/lib/dpkg/lock* 2>/dev/null || echo 'No locks found'"

# Step 4: Test manual apt update
ssh 127.0.0.1 "sudo apt update"
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

### Passwordless Sudo Setup (Optional)
```bash
# Add your user to sudoers for passwordless sudo
echo "$USER ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/$USER

# Then run without -K flag
ansible-playbook -i examples/inventory-ssh-local.ini examples/apache-ssh.yml
```

## 💡 Note for WSL Users (Windows Subsystem for Linux)
- You can run Ansible inside WSL (Ubuntu) and manage the same WSL distro via SSH
- You must install and start `sshd` in WSL and allow connections
- If managing Windows outside WSL, use WinRM instead of SSH (not covered here)

---
This pattern mirrors real-world remote automation while staying on a single machine. Perfect for practicing SSH-based workflows safely.