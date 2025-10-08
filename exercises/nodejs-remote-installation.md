# Exercise: Install Node.js on a Remote Server with Ansible (SSH-Based)

This exercise is the remote-host version of the localhost Node.js setup. You’ll target one or more remote Linux servers over SSH, install Node.js (NodeSource LTS), and bootstrap a simple Express.js app.

## 🎯 Learning Objectives
- Configure inventory and SSH access for remote hosts
- Bootstrap Python if missing on remote machines
- Install Node.js over SSH using NodeSource repo
- Create a sample app and verify remotely

## ✅ Prerequisites
- You’ve completed the localhost Node.js exercise or understand the basics
- Remote Ubuntu/Debian server(s) reachable over network (public IP or LAN)
- SSH access with a user that can sudo (`become: yes`)
- Your SSH key copied to the remote host(s) or password-based SSH available

## 🧩 Inventory (Remote)
Create `examples/inventory-remote.ini`:

```ini
# Example remote inventory (adjust hosts and users)
[remote]
web1 ansible_host=192.168.1.20 ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa
web2 ansible_host=203.0.113.10 ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa

# Optional: group vars for all remote hosts
[remote:vars]
ansible_python_interpreter=/usr/bin/python3
```

Notes:
- If Python isn’t present, we’ll install it via raw commands in the playbook.
- If you use passwords instead of keys, add `ansible_ssh_pass=...` (not recommended) or use `--ask-pass`.

## 📄 Playbook
Create `examples/nodejs-remote.yml`:

```yaml
---
- name: Install Node.js on remote servers (NodeSource LTS)
  hosts: remote
  become: yes
  gather_facts: false

  pre_tasks:
    - name: Ensure Python is available (for Ansible)
      raw: |
        if command -v python3 >/dev/null 2>&1; then
          echo 'python3 present'
        elif command -v apt >/dev/null 2>&1; then
          apt update -y && apt install -y python3
        elif command -v dnf >/dev/null 2>&1; then
          dnf install -y python3
        elif command -v yum >/dev/null 2>&1; then
          yum install -y python3
        fi
      changed_when: false

    - name: Gather facts now that Python exists
      setup:

  vars:
    nodejs_version: "20"
    project_dir: "/opt/nodejs-projects"
    app_name: "ansible-node-app"
    global_packages:
      - nodemon
      - pm2

  tasks:
    - name: Install base packages
      apt:
        name:
          - curl
          - ca-certificates
          - gnupg
          - software-properties-common
        state: present
        update_cache: yes
      when: ansible_facts.os_family == 'Debian'

    - name: Add NodeSource repository script
      get_url:
        url: "https://deb.nodesource.com/setup_{{ nodejs_version }}.x"
        dest: /tmp/nodesource_setup.sh
        mode: '0755'
      when: ansible_facts.os_family == 'Debian'

    - name: Run NodeSource setup
      command: /tmp/nodesource_setup.sh
      args:
        creates: /etc/apt/sources.list.d/nodesource.list
      when: ansible_facts.os_family == 'Debian'

    - name: Install Node.js (Debian/Ubuntu)
      apt:
        name: nodejs
        state: latest
        update_cache: yes
      when: ansible_facts.os_family == 'Debian'

    # Project directory
    - name: Create project directory
      file:
        path: "{{ project_dir }}/{{ app_name }}"
        state: directory
        mode: '0755'

    - name: Create app files
      copy:
        dest: "{{ project_dir }}/{{ app_name }}/app.js"
        mode: '0644'
        content: |
          const http = require('http');
          const os = require('os');
          const port = 3000;
          const server = http.createServer((req, res) => {
            if (req.url === '/api/status') {
              res.setHeader('Content-Type', 'application/json');
              return res.end(JSON.stringify({ status: 'OK', host: os.hostname(), ts: new Date().toISOString() }));
            }
            res.end(`Node.js running on ${os.hostname()} (v${process.versions.node})`);
          });
          server.listen(port, () => console.log(`Server listening on port ${port}`));

    - name: Create package.json
      copy:
        dest: "{{ project_dir }}/{{ app_name }}/package.json"
        mode: '0644'
        content: |
          {
            "name": "{{ app_name }}",
            "version": "1.0.0",
            "main": "app.js",
            "scripts": {
              "start": "node app.js"
            },
            "dependencies": {}
          }

    - name: Install dependencies (none yet, ensures npm works)
      npm:
        path: "{{ project_dir }}/{{ app_name }}"
        state: present

    - name: Install useful global packages
      npm:
        name: "{{ item }}"
        global: yes
        state: present
      loop: "{{ global_packages }}"

    - name: Show versions
      command: node --version
      register: node_v
      changed_when: false

    - debug:
        msg: "Installed Node.js {{ node_v.stdout }} on {{ inventory_hostname }}; app at {{ project_dir }}/{{ app_name }}"

  handlers: []
```

## ▶️ Run It
From your project root:

```bash
ansible-playbook -i examples/inventory-remote.ini examples/nodejs-remote.yml -b
```

- `-b` uses sudo (become)
- Add `-u someuser` to override the SSH user
- Add `-k` or `--ask-pass` if not using SSH keys
- Add `--limit web1` to target a single host

## 🔍 Verify Remotely
- SSH to the remote host and run:

```bash
cd /opt/nodejs-projects/ansible-node-app
node app.js &
curl http://localhost:3000
curl http://localhost:3000/api/status
```

For a proper service, consider adding a systemd unit or using pm2 in production mode.

## 🧠 What’s Different vs Localhost?
- Transport: SSH to remote machine (default), not local execution
- Credentials: remote user + key/password instead of your local user
- Paths: use remote filesystem paths (e.g., `/opt/...`) instead of `$HOME`
- Bootstrap: ensure Python exists for Ansible to operate

## 🐛 Troubleshooting
- SSH auth fails: confirm key permissions and `ansible_user`
- Python missing: ensure pre_tasks ran; check privilege escalation
- Apt errors: update repos or check outbound internet access from the server
- Permission denied: add `become: yes` and ensure your user is in sudoers

---

Use this as a stepping stone from localhost learning to real-world, multi-host automation.