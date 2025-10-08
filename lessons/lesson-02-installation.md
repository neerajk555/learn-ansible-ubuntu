# Lesson 2: Installing and Verifying Ansible on Ubuntu

## Learning Objectives
- Install Ansible using apt.
- Verify installation and version.
- Create your first project folder structure.

## Concept Overview

**Ansible runs entirely on your Ubuntu machine** - this is called the "control node." You don't need to install anything special on the servers you want to manage. Think of it like having a universal remote control for all your computers.

### What We'll Install
- **Ansible Core**: The main automation engine
- **Python 3**: Required for Ansible (usually pre-installed on Ubuntu)
- **SSH**: For connecting to other machines (also pre-installed)

### Why These Specific Settings?
We'll create a configuration file that makes Ansible easier to use for beginners by setting sensible defaults.

## Step-by-Step Tutorial (Ubuntu)

### Step 1: Prepare Your Ubuntu System
First, let's make sure your Ubuntu system is up to date:

```bash
# Update the package list (like refreshing an app store)
sudo apt update
```

**What's happening:** Ubuntu checks for the latest versions of all available software.

### Step 2: Install Ansible
```bash
# Install Ansible from Ubuntu's official repositories
sudo apt install -y ansible
```

**What's happening:** This installs Ansible and all its dependencies (Python libraries, SSH tools, etc.).

### Step 3: Verify Installation Works
```bash
# Check that Ansible installed correctly
ansible --version
```

**Expected output** (versions may vary):
```
ansible [core 2.12.1]
  config file = None
  configured module search path = ['/home/username/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3/dist-packages/ansible
  ansible collection location = /home/username/.ansible/collections:/usr/share/ansible/collections
  executable location = /usr/bin/ansible
  python version = 3.10.6 (main, Nov 14 2022, 16:10:14) [GCC 11.4.0] 64 bit
```

**If you see an error** like "command not found":
1. Try installing again: `sudo apt install ansible`
2. Check if `/usr/bin` is in your PATH: `echo $PATH`
3. Restart your terminal and try again

### Step 4: Create Your Ansible Workspace
```bash
# Create a dedicated folder for this course
mkdir -p ~/ansible-course

# Navigate to your new workspace
cd ~/ansible-course

# Verify you're in the right place
pwd
```

**What's happening:** We're creating a clean workspace to keep all our Ansible files organized.

### Step 5: Create Ansible Configuration File
Ansible can use default settings from a configuration file, making commands shorter and simpler.

```bash
# Create the main configuration file
nano ansible.cfg
```

**Copy and paste this configuration:**
```ini
[defaults]
# Tell Ansible where to find our host list
inventory = inventory.ini

# Default username for SSH connections (change if different)
remote_user = $USER

# Skip SSH key verification (OK for learning, NOT for production)
host_key_checking = False

# Don't create retry files when tasks fail
retry_files_enabled = False

# Let Ansible automatically find Python
interpreter_python = auto_silent

# How long to wait for SSH connections
timeout = 30

# Display output in a readable format
stdout_callback = yaml

[privilege_escalation]
# Automatically use sudo for tasks that need root access
become = True
become_method = sudo

# Don't prompt for sudo password (assumes passwordless sudo)
become_ask_pass = False
```

**Save and exit nano:** Press `Ctrl+X`, then `Y`, then `Enter`

#### Understanding Each Setting (Beginner Breakdown)
- `inventory = inventory.ini` → "Find my server list in this file"
- `remote_user = $USER` → "Use my current username when connecting to other machines"
- `host_key_checking = False` → "Don't ask me to verify SSH fingerprints (learning mode)"
- `become = True` → "Automatically use sudo when needed"
- `stdout_callback = yaml` → "Show results in an easy-to-read format"

### Step 6: Create Initial Inventory File
The inventory tells Ansible which computers to manage:

```bash
# Create an empty inventory file
nano inventory.ini
```

**Start with this basic structure:**
```ini
# This is your inventory file - it lists all computers Ansible will manage

# Local machine (great for testing)
[local]
localhost ansible_connection=local

# Future remote servers (we'll add these later)
[webservers]
# 192.168.1.10
# 192.168.1.11

[databases] 
# 192.168.1.20

# Variables that apply to all servers
[all:vars]
# Use Python 3 (standard on modern Ubuntu)
ansible_python_interpreter=/usr/bin/python3
```

**Save and exit:** `Ctrl+X`, then `Y`, then `Enter`

### Step 7: Test Your Setup
Let's verify everything works by pinging localhost:

```bash
# Test Ansible can connect to your local machine
ansible localhost -m ping
```

**Expected output:**
```
localhost | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

**If you see "SUCCESS"** - Congratulations! Ansible is working perfectly.

**If you see errors:**
- "Permission denied" → Check your SSH keys or use `-k` flag
- "Inventory not found" → Make sure you're in the `~/ansible-course` directory

## Code Examples
- `ansible.cfg` and `inventory.ini` above.

## Hands-On Exercise

**Complete these tasks to reinforce your learning:**

1. **Check your Ansible version:**
   ```bash
   ansible --version
   ```
   Write down the version number - you'll need it if you ask for help later!

2. **Test different inventory formats:**
   ```bash
   # Test connecting to localhost  
   ansible localhost -m ping
   
   # List all hosts in your inventory
   ansible-inventory --list
   
   # Show inventory in a tree format
   ansible-inventory --graph
   ```

3. **Create your workspace backup:**
   ```bash
   # Make a backup of your working configuration
   cp ansible.cfg ansible.cfg.backup
   cp inventory.ini inventory.ini.backup
   ```

**Expected Results:**
- `ansible --version` shows version info with Python 3.x
- `ansible localhost -m ping` returns "SUCCESS" and "pong"
- Your workspace contains `ansible.cfg` and `inventory.ini`

## Troubleshooting Tips

### Common Installation Issues

**Problem:** "bash: ansible: command not found"
```bash
# Solution 1: Reinstall Ansible
sudo apt update
sudo apt install -y ansible

# Solution 2: Check if it's installed in a different location
which ansible
whereis ansible

# Solution 3: Check your PATH
echo $PATH | grep -o '/usr/bin'
```

**Problem:** "Could not successfully use console_scripts entry point"
```bash
# Solution: Install missing Python dependencies
sudo apt install -y python3-pip python3-dev
```

**Problem:** "Permission denied (publickey)"
```bash
# Solution: Test with local connection first
ansible localhost -m ping -c local
```

### Configuration File Issues

**Problem:** Ansible ignores your ansible.cfg
```bash
# Check which config file Ansible is using
ansible --version -v

# Verify you're in the right directory
pwd
ls -la ansible.cfg
```

**Problem:** "ERROR! Unable to parse inventory file"
```bash
# Test inventory file syntax
ansible-inventory --parse inventory.ini

# Check file format (should be plain text)
file inventory.ini
```

### Quick Validation Commands
```bash
# Verify Ansible can read your config
ansible-config dump

# Test basic functionality without connecting anywhere
ansible localhost -m setup --connection=local | head -20

# Check if Python is properly detected
ansible localhost -m debug -a "var=ansible_python_version"
```

**Pro Tip:** If you're still having issues, try this minimal test:
```bash
# Create a minimal test (bypasses config files)
ansible localhost -i "localhost," -m ping -c local
```

If this works but your regular setup doesn't, there's an issue with your configuration files.

## Summary / Key Takeaways
- Ansible installed and configured.
- Workspace ready for future lessons.

## Next Steps
- Learn how Ansible knows which machines to manage (inventories). 💡

---

**Navigation:** [← Lesson 1](lesson-01-introduction.md) | [Next: Lesson 3 →](lesson-03-inventory.md)
