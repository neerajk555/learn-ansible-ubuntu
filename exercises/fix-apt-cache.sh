#!/bin/bash
# Quick fix script for "Failed to update apt cache" error

echo "🔧 Fixing apt cache issues..."

echo "Step 1: Killing stuck apt processes..."
ssh 127.0.0.1 "sudo pkill apt || true; sudo pkill dpkg || true" 2>/dev/null

echo "Step 2: Removing lock files..."
ssh 127.0.0.1 "sudo rm -f /var/lib/apt/lists/lock /var/cache/apt/archives/lock /var/lib/dpkg/lock*" 2>/dev/null || true

echo "Step 3: Configuring dpkg..."
ssh 127.0.0.1 "sudo dpkg --configure -a" 2>/dev/null || true

echo "Step 4: Cleaning apt cache..."
ssh 127.0.0.1 "sudo apt clean"

echo "Step 5: Updating apt cache..."
if ssh 127.0.0.1 "sudo apt update"; then
    echo "✅ Apt cache updated successfully!"
    echo
    echo "Now try running your playbook again:"
    echo "ansible-playbook -i examples/inventory-ssh-local.ini examples/apache-ssh.yml -K"
else
    echo "❌ Still having issues. Try the robust playbook:"
    echo "ansible-playbook -i examples/inventory-ssh-local.ini examples/apache-ssh-robust.yml -K"
fi