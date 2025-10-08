#!/bin/bash
# Quick diagnostic script for apt cache issues

echo "=== Ansible Apache SSH Troubleshooting ==="
echo

echo "1. Testing SSH connectivity..."
if ssh -o ConnectTimeout=5 127.0.0.1 "echo 'SSH OK'" 2>/dev/null; then
    echo "   ✅ SSH connection successful"
else
    echo "   ❌ SSH connection failed"
    echo "   Run: sudo systemctl start ssh"
    exit 1
fi

echo
echo "2. Checking for apt locks..."
LOCKS=$(ssh 127.0.0.1 "sudo lsof /var/lib/dpkg/lock* /var/lib/apt/lists/lock /var/cache/apt/archives/lock 2>/dev/null | wc -l")
if [ "$LOCKS" -gt 0 ]; then
    echo "   ⚠️  Apt locks found - clearing them..."
    ssh 127.0.0.1 "sudo pkill apt; sudo pkill dpkg" 2>/dev/null || true
    ssh 127.0.0.1 "sudo rm -f /var/lib/apt/lists/lock /var/cache/apt/archives/lock /var/lib/dpkg/lock*" 2>/dev/null || true
    echo "   ✅ Locks cleared"
else
    echo "   ✅ No apt locks found"
fi

echo
echo "3. Testing apt update..."
if ssh 127.0.0.1 "sudo apt update" 2>/dev/null; then
    echo "   ✅ Apt update successful"
else
    echo "   ❌ Apt update failed"
    echo "   Checking internet connectivity..."
    if ping -c 2 8.8.8.8 >/dev/null 2>&1; then
        echo "   ✅ Internet connection OK"
        echo "   ⚠️  Repository issue - try: sudo apt clean && sudo apt update"
    else
        echo "   ❌ No internet connection"
    fi
fi

echo
echo "4. Checking if Apache is already installed..."
if ssh 127.0.0.1 "systemctl is-active apache2" 2>/dev/null | grep -q "active"; then
    echo "   ✅ Apache is already running"
    echo "   Visit: http://127.0.0.1"
else
    echo "   ℹ️  Apache not running - ready for installation"
fi

echo
echo "=== Recommendations ==="
echo "• If apt issues persist, use: ansible-playbook -i examples/inventory-ssh-local.ini examples/apache-ssh-robust.yml -K"
echo "• For verbose output, add -v flag to ansible-playbook"
echo "• Check logs with: sudo journalctl -u apt-daily"