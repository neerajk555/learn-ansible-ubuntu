# Exercise: Install Node.js with Ansible

## 🎯 Learning Objectives
- Install Node.js and npm using Ansible
- Configure Node.js for development
- Create a sample Node.js project structure
- Verify the installation works correctly

## 📋 Prerequisites
- Completed Lessons 1-5 (Basic Ansible setup and package management)
- Ubuntu system with Ansible configured
- Basic understanding of playbooks and tasks

## 🚀 Exercise Overview

In this exercise, you'll create an Ansible playbook that:
1. Installs Node.js and npm from Ubuntu repositories
2. Installs Node.js via NodeSource repository (latest LTS)
3. Sets up a development environment
4. Creates a sample Node.js project
5. Verifies everything works correctly

### Why we use localhost for this exercise

You’ll run this entirely on localhost (your Ubuntu machine/VM) so you can learn fast without SSH or extra servers.

- Ansible executes tasks locally when you target a host with `ansible_connection=local`.
- Same playbook logic works on real servers later—just change the inventory.
- You may still need `become: yes` for package installs (sudo).

Inventory entry used in this course:

```ini
[local]
localhost ansible_connection=local
```

Then your playbook uses:

```yaml
hosts: local
```

## 📝 Step-by-Step Implementation

### Step 1: Create the Node.js Installation Playbook

```bash
# Navigate to your Ansible workspace
cd ~/ansible-course

# Create the Node.js playbook
nano playbooks/nodejs-setup.yml
```

**Paste this comprehensive Node.js setup playbook:**

```yaml
---
- name: Install and Configure Node.js Development Environment
  hosts: local
  become: yes
  gather_facts: yes
  
  vars:
    nodejs_version: "20"  # LTS version
    global_packages:
      - "@angular/cli"
      - "create-react-app"
      - "express-generator"
      - "nodemon"
      - "pm2"
    project_directory: "{{ ansible_env.HOME }}/nodejs-projects"
    sample_app_name: "ansible-node-app"
  
  tasks:
    # === METHOD 1: Install from Ubuntu repositories (older version) ===
    - name: Install Node.js from Ubuntu repositories
      ansible.builtin.apt:
        name:
          - nodejs
          - npm
        state: present
        update_cache: yes
      tags: ['ubuntu-repo']
    
    # === METHOD 2: Install latest LTS from NodeSource ===
    - name: Install required packages for NodeSource repository
      ansible.builtin.apt:
        name:
          - curl
          - software-properties-common
          - ca-certificates
          - gnupg
        state: present
        update_cache: yes
      tags: ['nodesource']
    
    - name: Download NodeSource setup script
      ansible.builtin.get_url:
        url: "https://deb.nodesource.com/setup_{{ nodejs_version }}.x"
        dest: /tmp/nodesource_setup.sh
        mode: '0755'
      tags: ['nodesource']
    
    - name: Run NodeSource setup script
      ansible.builtin.command: /tmp/nodesource_setup.sh
      args:
        creates: /etc/apt/sources.list.d/nodesource.list
      tags: ['nodesource']
    
    - name: Install Node.js from NodeSource repository
      ansible.builtin.apt:
        name:
          - nodejs
        state: latest
        update_cache: yes
      tags: ['nodesource']
    
    # === DEVELOPMENT ENVIRONMENT SETUP ===
    - name: Create Node.js projects directory
      ansible.builtin.file:
        path: "{{ project_directory }}"
        state: directory
        mode: '0755'
        owner: "{{ ansible_env.USER }}"
        group: "{{ ansible_env.USER }}"
      become: no
    
    - name: Install global npm packages
      ansible.builtin.npm:
        name: "{{ item }}"
        global: yes
        state: present
      loop: "{{ global_packages }}"
      become: yes
    
    # === SAMPLE PROJECT CREATION ===
    - name: Create sample Node.js application directory
      ansible.builtin.file:
        path: "{{ project_directory }}/{{ sample_app_name }}"
        state: directory
        mode: '0755'
        owner: "{{ ansible_env.USER }}"
        group: "{{ ansible_env.USER }}"
      become: no
    
    - name: Create package.json for sample app
      ansible.builtin.copy:
        dest: "{{ project_directory }}/{{ sample_app_name }}/package.json"
        content: |
          {
            "name": "{{ sample_app_name }}",
            "version": "1.0.0",
            "description": "Sample Node.js app created by Ansible",
            "main": "app.js",
            "scripts": {
              "start": "node app.js",
              "dev": "nodemon app.js",
              "test": "echo \"Error: no test specified\" && exit 1"
            },
            "dependencies": {
              "express": "^4.18.0"
            },
            "devDependencies": {
              "nodemon": "^3.0.0"
            },
            "keywords": ["ansible", "nodejs", "express"],
            "author": "Ansible Automation",
            "license": "MIT"
          }
        owner: "{{ ansible_env.USER }}"
        group: "{{ ansible_env.USER }}"
        mode: '0644'
      become: no
    
    - name: Create sample Express.js application
      ansible.builtin.copy:
        dest: "{{ project_directory }}/{{ sample_app_name }}/app.js"
        content: |
          const express = require('express');
          const os = require('os');
          const app = express();
          const port = 3000;
          
          // Middleware
          app.use(express.json());
          app.use(express.static('public'));
          
          // Routes
          app.get('/', (req, res) => {
            res.send(`
              <html>
                <head>
                  <title>Node.js App - Deployed by Ansible</title>
                  <style>
                    body { font-family: Arial, sans-serif; margin: 2rem; background: #f5f5f5; }
                    .container { max-width: 800px; margin: 0 auto; background: white; padding: 2rem; border-radius: 8px; }
                    .success { color: green; }
                    .info { background: #e8f4fd; padding: 1rem; border-radius: 4px; margin: 1rem 0; }
                  </style>
                </head>
                <body>
                  <div class="container">
                    <h1>🚀 Node.js Application</h1>
                    <p class="success">✅ Successfully deployed with Ansible!</p>
                    <div class="info">
                      <h3>System Information</h3>
                      <p><strong>Hostname:</strong> ${os.hostname()}</p>
                      <p><strong>Platform:</strong> ${os.platform()} ${os.arch()}</p>
                      <p><strong>Node.js Version:</strong> ${process.version}</p>
                      <p><strong>Uptime:</strong> ${Math.floor(process.uptime())} seconds</p>
                    </div>
                    <h3>Available Endpoints:</h3>
                    <ul>
                      <li><a href="/api/status">GET /api/status</a> - API status</li>
                      <li><a href="/api/system">GET /api/system</a> - System info JSON</li>
                    </ul>
                  </div>
                </body>
              </html>
            `);
          });
          
          app.get('/api/status', (req, res) => {
            res.json({
              status: 'OK',
              message: 'Node.js API is running!',
              timestamp: new Date().toISOString(),
              uptime: process.uptime()
            });
          });
          
          app.get('/api/system', (req, res) => {
            res.json({
              hostname: os.hostname(),
              platform: os.platform(),
              architecture: os.arch(),
              nodeVersion: process.version,
              memory: {
                total: Math.round(os.totalmem() / 1024 / 1024) + ' MB',
                free: Math.round(os.freemem() / 1024 / 1024) + ' MB'
              },
              cpus: os.cpus().length
            });
          });
          
          app.listen(port, () => {
            console.log(`🚀 Server running at http://localhost:${port}`);
            console.log(`📊 System: ${os.platform()} ${os.arch()}`);
            console.log(`🟢 Node.js: ${process.version}`);
          });
        owner: "{{ ansible_env.USER }}"
        group: "{{ ansible_env.USER }}"
        mode: '0644'
      become: no
    
    - name: Install project dependencies
      ansible.builtin.npm:
        path: "{{ project_directory }}/{{ sample_app_name }}"
        state: present
      become: no
    
    # === VERIFICATION TASKS ===
    - name: Get Node.js version
      ansible.builtin.command: node --version
      register: node_version
      changed_when: false
      become: no
    
    - name: Get npm version
      ansible.builtin.command: npm --version
      register: npm_version
      changed_when: false
      become: no
    
    - name: Display installation results
      ansible.builtin.debug:
        msg: |
          === NODE.JS INSTALLATION COMPLETE ===
          Node.js Version: {{ node_version.stdout }}
          npm Version: {{ npm_version.stdout }}
          Project Directory: {{ project_directory }}
          Sample App: {{ project_directory }}/{{ sample_app_name }}
          
          🚀 To test your app:
          1. cd {{ project_directory }}/{{ sample_app_name }}
          2. npm start
          3. Open http://localhost:3000
    
    - name: Create startup script
      ansible.builtin.copy:
        dest: "{{ project_directory }}/{{ sample_app_name }}/start-app.sh"
        content: |
          #!/bin/bash
          echo "🚀 Starting Node.js application..."
          cd {{ project_directory }}/{{ sample_app_name }}
          echo "📂 Current directory: $(pwd)"
          echo "🟢 Node.js version: $(node --version)"
          echo "📦 npm version: $(npm --version)"
          echo ""
          echo "Starting server at http://localhost:3000"
          echo "Press Ctrl+C to stop"
          npm start
        owner: "{{ ansible_env.USER }}"
        group: "{{ ansible_env.USER }}"
        mode: '0755'
      become: no
```

### Step 2: Create a Simpler Version for Beginners

```bash
# Create a simpler version for those just learning
nano playbooks/nodejs-simple.yml
```

```yaml
---
- name: Simple Node.js Installation
  hosts: local
  become: yes
  gather_facts: yes
  
  tasks:
    - name: Update package cache
      ansible.builtin.apt:
        update_cache: yes
        cache_valid_time: 3600
    
    - name: Install Node.js and npm
      ansible.builtin.apt:
        name:
          - nodejs
          - npm
        state: present
    
    - name: Verify Node.js installation
      ansible.builtin.command: node --version
      register: node_check
      changed_when: false
      become: no
    
    - name: Verify npm installation
      ansible.builtin.command: npm --version
      register: npm_check
      changed_when: false
      become: no
    
    - name: Show installation results
      ansible.builtin.debug:
        msg: |
          ✅ Node.js installed: {{ node_check.stdout }}
          ✅ npm installed: {{ npm_check.stdout }}
```

### Step 3: Run the Playbooks

```bash
# Option 1: Run the simple version first
ansible-playbook playbooks/nodejs-simple.yml

# Option 2: Run the comprehensive version
ansible-playbook playbooks/nodejs-setup.yml

# Option 3: Run only specific parts using tags
ansible-playbook playbooks/nodejs-setup.yml --tags "ubuntu-repo"
ansible-playbook playbooks/nodejs-setup.yml --tags "nodesource"
```

### Step 4: Test Your Node.js Installation

```bash
# Navigate to the sample project
cd ~/nodejs-projects/ansible-node-app

# Start the application
npm start

# OR use the startup script
./start-app.sh
```

Open your browser and go to:
- **http://localhost:3000** - Main application
- **http://localhost:3000/api/status** - API status
- **http://localhost:3000/api/system** - System information

### Step 5: Verification Commands

```bash
# Check versions
node --version
npm --version

# List global packages
npm list -g --depth=0

# Check project structure
tree ~/nodejs-projects/

# Test API endpoints
curl http://localhost:3000/api/status
curl http://localhost:3000/api/system
```

## 🎯 Exercise Challenges

### Challenge 1: Add More Global Packages
Modify the playbook to install additional global packages:
- `typescript`
- `@nestjs/cli`  
- `vue-cli`

### Challenge 2: Create Multiple Sample Projects
Extend the playbook to create:
- A React app template
- An Express API template
- A TypeScript project template

### Challenge 3: Environment Variables
Add tasks to configure Node.js environment variables:
- `NODE_ENV=development`
- Custom `NODE_PATH`
- Development vs Production configurations

## 🐛 Troubleshooting

### Common Issues and Solutions

**Issue**: "npm: command not found"
```bash
# Check if npm is installed
dpkg -l | grep npm

# Reinstall if needed
sudo apt remove nodejs npm
sudo apt install nodejs npm
```

**Issue**: Permission denied for global packages
```bash
# Fix npm permissions
mkdir ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
```

**Issue**: Old Node.js version from Ubuntu repos
```bash
# Use the NodeSource method in the playbook
ansible-playbook playbooks/nodejs-setup.yml --tags "nodesource"
```

## ✅ Success Criteria

After completing this exercise, you should have:
- ✅ Node.js and npm installed and working
- ✅ A sample Express.js application running
- ✅ Global npm packages available
- ✅ Project directory structure created
- ✅ Understanding of package management with Ansible

## 🚀 Next Steps

1. **Explore Express.js**: Modify the sample app to add new routes
2. **Database Integration**: Add MongoDB or PostgreSQL to your setup
3. **Production Deployment**: Create a production-ready Node.js deployment playbook
4. **Containerization**: Learn to deploy Node.js apps with Docker and Ansible

## 📚 Related Lessons

- **Lesson 5**: Managing Packages and Services
- **Lesson 6**: Using Variables and Facts  
- **Lesson 8**: Working with Templates
- **Lesson 13**: Deploying a Simple Web Application

---

**🎉 Congratulations!** You've successfully automated Node.js installation and setup using Ansible. This is a foundational skill for modern web development automation!