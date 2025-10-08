# Why We Use Localhost (and How It's Different from a Web Server)

This course is optimized for learning on a single machine (your Ubuntu desktop or VM) using localhost. Here’s why, how it works, and how it differs from deploying to a remote web server.

## TL;DR
- Localhost = your own machine. Fast, safe, and requires no SSH or extra hosts.
- Remote web server = another machine reached over SSH. Closer to production, but needs network access and credentials.
- Ansible on localhost runs tasks directly without SSH when `ansible_connection=local` is used.

---

## Why Start with Localhost?

- Lower friction: No cloud account, DNS, or security keys required
- Faster feedback: Run-play-test cycles are seconds, not minutes
- Safe sandbox: You can break and fix without affecting real servers
- Same skills: Playbooks, modules, variables, and handlers work the same

Once you’re comfortable, you can point the exact same playbooks to real servers by changing the inventory and connection settings.

## How Ansible Runs on Localhost

Ansible supports running playbooks directly on the control machine.

Two common approaches:

1) Inventory declares a local host
```ini
[local]
localhost ansible_connection=local
```
Then run playbooks targeting `hosts: local`:
```yaml
- name: Example
  hosts: local
  gather_facts: yes
  tasks:
    - name: Verify
      ansible.builtin.command: echo "Running on {{ inventory_hostname }}"
```

2) Use the special `hosts: localhost` with connection overridden in the play
```yaml
- name: Run on localhost explicitly
  hosts: localhost
  connection: local
  tasks:
    - debug: msg="Hello from localhost"
```

Key points:
- No SSH needed. Tasks execute as local processes.
- `become: yes` still elevates privileges via sudo (you may be prompted for a password).
- Same modules, same YAML—only the transport differs.

## Localhost vs. Remote Web Server (At a Glance)

- Transport:
  - Localhost: `ansible_connection=local` (no SSH)
  - Remote: SSH (default), WinRM for Windows
- Credentials:
  - Localhost: none (uses your user), optional sudo
  - Remote: SSH key or password, remote user
- Networking:
  - Localhost: no network dependency
  - Remote: host reachable on network, firewall/ports
- Inventory:
  - Localhost: usually a single entry `localhost`
  - Remote: IPs/hostnames, groups, variables per host
- Side effects:
  - Localhost: changes your machine
  - Remote: changes remote systems (safer for your workstation)

## Common Pitfalls and Tips

- Using `localhost` without `ansible_connection=local` may cause SSH attempts to your own machine.
- Forgetting `become: yes` results in permission errors when installing packages.
- Proxy / corporate networks can block package repos; use `update_cache: yes` and check apt sources.
- When switching from localhost to remote hosts:
  - Add remote hosts to inventory
  - Set `ansible_user`, `ansible_host`, and provide SSH keys
  - Remove `ansible_connection=local`

## How Ansible Installs on Localhost

- Install Ansible on your Ubuntu machine (the control node) via apt or pip (see Lesson 2).
- You only need Ansible on the control node. Managed nodes don’t need Ansible installed.
- When running locally, the control node and managed node are the same machine.

Quick check:
```bash
ansible --version
ansible-inventory --list -i examples/inventory.ini | jq '.'
```

## Minimal Working Example

Inventory (`examples/inventory.ini`):
```ini
[local]
localhost ansible_connection=local
```

Playbook (`examples/ping-local.yml`):
```yaml
---
- name: Ping localhost without SSH
  hosts: local
  gather_facts: no
  tasks:
    - name: Test connectivity
      ansible.builtin.ping:
```

Run:
```bash
ansible-playbook -i examples/inventory.ini examples/ping-local.yml
```

Expected output: `SUCCESS` with the ping module.

---

Start local for speed and confidence, then point the same playbooks at real servers when you’re ready.