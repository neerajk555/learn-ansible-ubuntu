#!/bin/bash
echo "=== COMPLETE APACHE ANSIBLE TEST ==="

# Step 1: Run diagnostics
echo "🔍 Running diagnostics..."
./examples/diagnose-system.sh

# Step 2: Run emergency fixes if needed
read -p "Run emergency fixes? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🛠️ Running emergency fixes..."
    ./examples/emergency-fix.sh
fi

# Step 3: Test SSH connectivity
echo "🔗 Testing SSH connectivity..."
if ssh -o ConnectTimeout=5 127.0.0.1 "whoami" >/dev/null 2>&1; then
    echo "✅ SSH connectivity working"
else
    echo "❌ SSH connectivity failed - fix SSH first!"
    exit 1
fi

# Step 4: Run Ansible playbook
echo "🚀 Running Ansible playbook..."
echo "Trying simple method first..."
if ansible-playbook -i examples/inventory-ssh-local.ini examples/apache-ssh-simple.yml -K; then
    echo "✅ Simple method successful!"
else
    echo "❌ Simple method failed, trying minimal method..."
    ansible-playbook -i examples/inventory-ssh-local.ini examples/apache-ssh-minimal.yml -K
fi

# Step 5: Verify installation
echo "🧪 Testing Apache installation..."
if curl -s http://127.0.0.1 >/dev/null 2>&1; then
    echo "✅ Apache is responding on http://127.0.0.1"
    echo "📄 Page content preview:"
    curl -s http://127.0.0.1 | head -5
else
    echo "❌ Apache is not responding"
fi

echo "=== TEST COMPLETED ==="