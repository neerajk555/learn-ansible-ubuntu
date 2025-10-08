#!/bin/bash
echo "=== ANSIBLE SSH APACHE DIAGNOSTIC SCRIPT ==="
echo "Date: $(date)"
echo "User: $(whoami)"
echo

echo "1. SSH Connectivity Test:"
ssh -o ConnectTimeout=5 127.0.0.1 "echo 'SSH: ✅ Connected'" 2>/dev/null || echo "SSH: ❌ Failed"
echo

echo "2. System Resources:"
echo "Disk Space: $(df -h / | tail -1 | awk '{print $4}') available"
echo "Memory: $(free -h | grep '^Mem:' | awk '{print $7}') available"
echo "Load: $(uptime | awk -F'load average:' '{print $2}')"
echo

echo "3. Network Connectivity:"
ping -c1 8.8.8.8 >/dev/null 2>&1 && echo "Internet: ✅ Connected" || echo "Internet: ❌ No connection"
nslookup archive.ubuntu.com >/dev/null 2>&1 && echo "DNS: ✅ Working" || echo "DNS: ❌ Failed"
echo

echo "4. Package Management Status:"
ps aux | grep -E "(apt|dpkg)" | grep -v grep | wc -l | awk '{if($1>0) print "Apt processes: ❌ " $1 " running"; else print "Apt processes: ✅ None running"}'
ls /var/lib/dpkg/lock* 2>/dev/null | wc -l | awk '{if($1>0) print "Lock files: ❌ " $1 " present"; else print "Lock files: ✅ None found"}'
echo

echo "5. Apache Status:"
if systemctl is-active apache2 >/dev/null 2>&1; then
    echo "Apache: ✅ Running"
    echo "Port 80: $(ss -tlnp | grep :80 >/dev/null && echo '✅ Listening' || echo '❌ Not listening')"
else
    echo "Apache: ❌ Not running"
fi
echo

echo "6. Suggested Actions:"
if ! ssh -o ConnectTimeout=5 127.0.0.1 "exit" >/dev/null 2>&1; then
    echo "- Fix SSH connectivity first"
fi

if ps aux | grep -E "(apt|dpkg)" | grep -v grep >/dev/null; then
    echo "- Kill stuck package management processes: sudo pkill apt; sudo pkill dpkg"
fi

if ls /var/lib/dpkg/lock* >/dev/null 2>&1; then
    echo "- Remove lock files: sudo rm /var/lib/dpkg/lock*"
fi

if ! ping -c1 8.8.8.8 >/dev/null 2>&1; then
    echo "- Check internet connection"
fi

echo "=== END DIAGNOSTIC ==="