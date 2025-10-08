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