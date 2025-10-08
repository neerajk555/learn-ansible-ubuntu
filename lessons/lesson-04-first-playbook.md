# Lesson 4: Writing Your First Playbook

## Learning Objectives
- Create and run a simple Ansible playbook.
- Understand plays, hosts, tasks, and modules.

## What is an Ansible Playbook? (Detailed Explanation)

Think of a **playbook** like a cooking recipe, but for computers:
- **Recipe steps** = Ansible tasks 
- **Ingredients** = Target hosts and variables
- **Kitchen** = Your Ubuntu control machine
- **Finished meal** = Configured servers

### Playbook vs Ad-Hoc Commands

**Ad-hoc command** (like a quick snack):
```bash
ansible localhost -m ping
```

**Playbook** (like a full meal with multiple courses):
```yaml
---
- name: Complete server setup
  hosts: localhost
  tasks:
    - name: Test connectivity  
      ping:
    - name: Install software
      apt:
        name: nginx
        state: present
    - name: Start service
      service:
        name: nginx 
        state: started
```

### Key Playbook Components (Beginner Breakdown)

1. **Play**: A section targeting specific hosts
2. **Tasks**: Individual actions to perform  
3. **Modules**: Ansible's built-in tools (ping, apt, copy, etc.)
4. **Variables**: Dynamic values that change per host

## Step-by-Step Tutorial (Ubuntu)

### Step 1: Create Your Playbooks Directory

```bash
# Navigate to your Ansible workspace
cd ~/ansible-course

# Create a dedicated folder for playbooks
mkdir -p playbooks

# Verify the directory was created
ls -la
```

**Why a separate directory?** As you learn, you'll create many playbooks. Organization matters!

### Step 2: Your First Playbook - Hello World

```bash
# Create your first playbook
nano playbooks/hello.yml
```

**Type this exactly (YAML is sensitive to indentation!):**
```yaml
---
# This is your first Ansible playbook!
# Lines starting with # are comments (ignored by Ansible)

- name: My First Ansible Playbook  
  hosts: local
  gather_facts: yes
  
  tasks:
    - name: Test basic connectivity
      ansible.builtin.ping:
    
    - name: Say hello to the system
      ansible.builtin.debug:
        msg: "Hello! I'm running Ansible on {{ inventory_hostname }}"
    
    - name: Show system information  
      ansible.builtin.debug:
        msg: "This is {{ ansible_distribution }} {{ ansible_distribution_version }} on {{ ansible_architecture }}"
    
    - name: Display current user
      ansible.builtin.debug:
        msg: "Current user: {{ ansible_user_id }}"
    
    - name: Show the current date/time
      ansible.builtin.debug:
        msg: "Playbook executed at: {{ ansible_date_time.iso8601 }}"
```

**Save and exit:** `Ctrl+X`, `Y`, `Enter`

### Step 3: Understanding YAML Syntax (Critical for Beginners!)

Before running the playbook, let's understand the format:

```yaml
---                           # YAML document start
- name: My First Playbook     # Play name (human-readable description)  
  hosts: local               # Which group of servers to target
  gather_facts: yes          # Collect system information first
  
  tasks:                     # List of actions to perform
    - name: Task description # Human-readable task name
      ansible.builtin.ping:  # Module to execute (ping test)
    
    - name: Another task     # Second task  
      ansible.builtin.debug: # Module name (debug = print messages)
        msg: "Hello world"    # Module parameter (message to print)
```

**Critical YAML Rules:**
- **Indentation matters!** Use 2 spaces, not tabs
- **Dashes (-) start lists** 
- **Colons (:) separate keys and values**
- **Everything is case-sensitive**

### Step 4: Run Your First Playbook

```bash
# Execute the playbook
ansible-playbook playbooks/hello.yml
```

**Expected Output (should look like this):**
```
PLAY [My First Ansible Playbook] *******************************************

TASK [Gathering Facts] *****************************************************
ok: [localhost]

TASK [Test basic connectivity] ********************************************
ok: [localhost]

TASK [Say hello to the system] ********************************************
ok: [localhost] => {
    "msg": "Hello! I'm running Ansible on localhost"
}

TASK [Show system information] ********************************************
ok: [localhost] => {
    "msg": "This is Ubuntu 22.04 on x86_64"
}

TASK [Display current user] ***********************************************
ok: [localhost] => {
    "msg": "Current user: your-username"
}

TASK [Show the current date/time] *****************************************
ok: [localhost] => {
    "msg": "Playbook executed at: 2024-01-15T10:30:45Z"
}

PLAY RECAP ****************************************************************
localhost                  : ok=6    changed=0    unreachable=0    failed=0
```

### Step 5: Understanding the Output

**Play Recap Explanation:**
- `ok=6` - 6 tasks completed successfully
- `changed=0` - No changes made to the system  
- `unreachable=0` - All hosts were reachable
- `failed=0` - No tasks failed

**Task Status Colors:**
- **Green (ok)** - Task completed, no changes needed
- **Yellow (changed)** - Task completed and made changes  
- **Red (failed)** - Task encountered an error

### Step 6: Create a More Practical Playbook

Let's create a playbook that actually does something useful:

```bash
# Create a system information playbook
nano playbooks/system-info.yml
```

**Paste this more advanced example:**
```yaml
---
- name: Gather Detailed System Information
  hosts: local
  gather_facts: yes
  
  tasks:
    - name: Display hostname and IP address
      ansible.builtin.debug:
        msg: |
          Hostname: {{ ansible_hostname }}
          IP Address: {{ ansible_default_ipv4.address | default('Not found') }}
    
    - name: Show memory information
      ansible.builtin.debug:
        msg: |
          Total Memory: {{ (ansible_memtotal_mb / 1024) | round(1) }} GB
          Free Memory: {{ (ansible_memfree_mb / 1024) | round(1) }} GB
    
    - name: Display disk usage
      ansible.builtin.debug:
        msg: |
          Root Disk: {{ ansible_mounts[0].size_total | filesizeformat }}
          Available: {{ ansible_mounts[0].size_available | filesizeformat }}
    
    - name: Check if this is a virtual machine
      ansible.builtin.debug:
        msg: "This appears to be a {{ ansible_virtualization_type | default('physical') }} machine"
    
    - name: List network interfaces  
      ansible.builtin.debug:
        msg: "Available interfaces: {{ ansible_interfaces | join(', ') }}"
```

**Run this new playbook:**
```bash
ansible-playbook playbooks/system-info.yml
```

### Step 7: Your First Playbook with Changes

Let's create a playbook that actually modifies your system:

```bash
# Create a setup playbook
nano playbooks/basic-setup.yml
```

**Paste this example:**
```yaml
---
- name: Basic Ubuntu System Setup
  hosts: local
  gather_facts: yes
  become: yes  # Use sudo for tasks that need root access
  
  tasks:
    - name: Update apt package cache  
      ansible.builtin.apt:
        update_cache: yes
        cache_valid_time: 3600  # Only update if cache is older than 1 hour
    
    - name: Install useful development tools
      ansible.builtin.apt:
        name:
          - curl
          - wget  
          - git
          - htop
          - tree
        state: present
    
    - name: Create a test directory
      ansible.builtin.file:
        path: /tmp/ansible-test
        state: directory
        mode: '0755'
    
    - name: Create a test file with content
      ansible.builtin.copy:
        dest: /tmp/ansible-test/hello.txt
        content: |
          Hello from Ansible!
          Created on: {{ ansible_date_time.iso8601 }}
          System: {{ ansible_distribution }} {{ ansible_distribution_version }}
        mode: '0644'
    
    - name: Verify the file was created
      ansible.builtin.debug:
        msg: "Test file created successfully!"
```

**Run with explanation:**
```bash
# Run the setup playbook
ansible-playbook playbooks/basic-setup.yml

# Verify it worked by checking the created files
ls -la /tmp/ansible-test/
cat /tmp/ansible-test/hello.txt
```

**What should happen:**
- Ansible updates your package cache
- Installs 5 useful tools (curl, wget, git, htop, tree)
- Creates a directory and file with dynamic content
- Shows "changed" status for tasks that modified your system

## Code Examples
- `playbooks/hello.yml` as above.

## Hands-On Exercise

**Complete these tasks to master your first playbooks:**

### Exercise 1: Modify the Hello Playbook
Edit `playbooks/hello.yml` and add these tasks:

```yaml
    - name: Show IP address
      ansible.builtin.debug:
        msg: "IP Address: {{ ansible_default_ipv4.address | default('No network interface found') }}"
    
    - name: Check disk space
      ansible.builtin.debug:
        msg: "Root disk has {{ ansible_mounts[0].size_available | filesizeformat }} available"
    
    - name: Count CPU cores
      ansible.builtin.debug:
        msg: "This system has {{ ansible_processor_vcpus }} CPU cores"
```

### Exercise 2: Create Your Own Information Gathering Playbook
Create a new file `playbooks/my-info.yml`:

```yaml
---
- name: My Custom System Info
  hosts: local
  gather_facts: yes
  
  tasks:
    - name: Show what I learned about this system
      ansible.builtin.debug:
        msg: |
          === MY UBUNTU SYSTEM ===
          Computer Name: {{ ansible_hostname }}
          Ubuntu Version: {{ ansible_distribution_version }}
          Kernel: {{ ansible_kernel }}
          Uptime: {{ ansible_uptime_seconds // 3600 }} hours
          Python: {{ ansible_python_version }}
```

### Exercise 3: Test Error Handling
Create `playbooks/error-test.yml` to see what happens when things go wrong:

```yaml
---
- name: Testing Errors (Learning Exercise)
  hosts: local
  
  tasks:
    - name: This will work fine
      ansible.builtin.debug:
        msg: "This task succeeds!"
    
    - name: This might fail (testing only!)
      ansible.builtin.fail:
        msg: "This is a deliberate failure for learning"
      ignore_errors: yes  # Don't stop the playbook if this fails
    
    - name: This runs even after the failure
      ansible.builtin.debug:
        msg: "The show goes on!"
```

Run it and observe the output:
```bash
ansible-playbook playbooks/error-test.yml
```

### Exercise 4: Dry Run Testing
Test your playbooks safely without making changes:

```bash
# Run in 'check mode' (dry run - shows what WOULD happen)
ansible-playbook playbooks/basic-setup.yml --check

# See the differences it would make
ansible-playbook playbooks/basic-setup.yml --check --diff

# Run for real
ansible-playbook playbooks/basic-setup.yml
```

## Troubleshooting Tips

### YAML Syntax Issues

**Problem:** "Syntax Error" or "mapping values are not allowed here"
```bash
# Check YAML syntax before running
python3 -c "import yaml; yaml.safe_load(open('playbooks/hello.yml'))"

# Common issues:
# 1. Mixed tabs and spaces (use only spaces!)
# 2. Missing colons after keys
# 3. Wrong indentation levels
```

**Problem:** Tasks don't run as expected
```bash
# Run with maximum verbosity to see what's happening
ansible-playbook playbooks/hello.yml -vvv

# Check if you're targeting the right hosts
ansible-playbook playbooks/hello.yml --list-hosts

# Run just specific tasks by tags (we'll learn this later)
ansible-playbook playbooks/hello.yml --list-tasks
```

### Variable and Facts Issues

**Problem:** "Undefined variable" errors
```bash
# Check if facts are being gathered
ansible localhost -m setup | grep ansible_distribution

# Manually gather facts in a separate task
- name: Gather facts manually
  setup:

# Use default values for variables that might not exist
msg: "IP: {{ ansible_default_ipv4.address | default('Not available') }}"
```

**Problem:** Playbook runs on wrong hosts
```bash
# Always verify which hosts will be targeted
ansible-playbook playbooks/hello.yml --list-hosts

# Check your inventory
ansible-inventory --list

# Use limit to restrict to specific hosts
ansible-playbook playbooks/hello.yml --limit localhost
```

### Module and Task Issues

**Problem:** "Module not found" errors
```bash
# Use fully qualified module names (recommended)
ansible.builtin.debug:    # Good
debug:                    # Works but not recommended

# List all available modules
ansible-doc -l | grep debug
```

**Problem:** Permission denied errors
```bash
# Use become for tasks that need sudo
- name: Install software
  ansible.builtin.apt:
    name: curl
    state: present
  become: yes

# Or set become for the entire play
- name: My Play
  hosts: local
  become: yes
  tasks: ...
```

### Quick Validation Commands

```bash
# Essential playbook commands:
ansible-playbook playbook.yml --syntax-check  # Check YAML syntax
ansible-playbook playbook.yml --check         # Dry run
ansible-playbook playbook.yml --list-tasks    # Show all tasks
ansible-playbook playbook.yml --list-hosts    # Show target hosts
ansible-playbook playbook.yml -v             # Verbose output
```

### Best Practices You've Learned

1. **Always use descriptive task names** - Future you will thank you!
2. **Test with `--check` first** - Safer than running directly
3. **Use `gather_facts: yes`** - You'll need system information
4. **Indent with 2 spaces consistently** - YAML is picky about this
5. **Comment your playbooks** - Explain why, not just what

**Pro Tip:** Create a template for new playbooks:
```bash
# Save this as playbooks/template.yml
---
- name: [REPLACE WITH DESCRIPTIVE NAME]
  hosts: local
  gather_facts: yes
  become: no  # Change to 'yes' if you need sudo
  
  tasks:
    - name: [FIRST TASK DESCRIPTION]
      ansible.builtin.debug:
        msg: "Replace this with your actual task"
```

## Summary / Key Takeaways
- Playbooks describe steps for target hosts.
- Tasks run modules; facts provide useful system data.

## Next Steps
- Manage packages and services (Apache, Nginx, etc.). 🧰

---

**Navigation:** [← Lesson 3](lesson-03-inventory.md) | [Next: Lesson 5 →](lesson-05-packages-services.md)