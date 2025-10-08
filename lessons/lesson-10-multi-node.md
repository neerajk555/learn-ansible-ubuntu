# Lesson 10: Setting Up Multi-Node Environments (using Virtual Machines or Multipass)

## Learning Objectives
- Install Multipass on Ubuntu.
- Create multiple Ubuntu VMs.
- Set up SSH key-based access for Ansible.

## Concept Overview
You'll create "managed nodes" as VMs on your Ubuntu machine. Ansible will connect via SSH using keys.

## Step-by-Step Tutorial (Ubuntu)
1. **Install Multipass:**
   ```bash
   sudo snap install multipass
   ```
2. **Launch VMs:**
   ```bash
   multipass launch --name web1 --mem 1G --disk 5G --cpus 1
   multipass launch --name db1 --mem 1G --disk 5G --cpus 1
   ```
   Tip: Default image is the current Ubuntu LTS. User is `ubuntu` with passwordless sudo.

3. **Get IPs:**
   ```bash
   multipass list
   ```
   Note the IPs (e.g., `10.139.64.5` for web1, `10.139.64.6` for db1).

4. **Generate SSH key for Ansible:**
   ```bash
   ssh-keygen -t ed25519 -C "ansible@ubuntu" -f ~/.ssh/ansible -N ""
   ```
5. **Copy key to VMs:**
   ```bash
   ssh-copy-id -i ~/.ssh/ansible.pub ubuntu@<WEB1_IP>
   ssh-copy-id -i ~/.ssh/ansible.pub ubuntu@<DB1_IP>
   ```
   Replace `<WEB1_IP>` and `<DB1_IP>` with actual IPs from step 3.

6. **Update `ansible.cfg` to use the key:**
   ```bash
   nano ansible.cfg
   ```
   Add under [defaults]:
   ```
   private_key_file = ~/.ssh/ansible
   ```
7. **Update `inventory.ini`:**
   ```bash
   nano inventory.ini
   ```
   Paste:
   ```
   [web]
   <WEB1_IP>

   [db]
   <DB1_IP>

   [all:vars]
   ansible_python_interpreter=/usr/bin/python3
   ```
   Replace `<WEB1_IP>` and `<DB1_IP>` with actual IPs.

8. **Test:**
   ```bash
   ansible all -m ping
   ```

## Code Examples
- Updated `ansible.cfg` and `inventory.ini`.

## Hands-On Exercise
- Create a third VM `web2`, add it to the `[web]` group, and verify with `ansible web -m ping`.
- Commands:
  ```bash
  multipass launch --name web2 --mem 1G --disk 5G --cpus 1
  # Get IP and add to inventory under [web]
  # Copy SSH key to new VM
  ```

## Troubleshooting Tips
- SSH "Permission denied": ensure key was copied and `private_key_file` is set.
- Firewall/host key prompts: `host_key_checking = False` helps for labs.

## Summary / Key Takeaways
- You now have real remote nodes managed via SSH and inventory groups.

## Next Steps
- Organize playbooks using Roles. 🧱

---

**Navigation:** [← Lesson 9](lesson-09-files-users.md) | [Next: Lesson 11 →](lesson-11-roles.md)