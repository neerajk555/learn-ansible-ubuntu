#!/bin/bash
# Test script for Node.js installation exercise

echo "🔍 Testing Node.js Installation Exercise..."
echo "==========================================="

# Check if Node.js is installed
echo "1. Checking Node.js installation..."
if command -v node &> /dev/null; then
    echo "   ✅ Node.js found: $(node --version)"
else
    echo "   ❌ Node.js not found"
    exit 1
fi

# Check if npm is installed
echo "2. Checking npm installation..."
if command -v npm &> /dev/null; then
    echo "   ✅ npm found: $(npm --version)"
else
    echo "   ❌ npm not found"
    exit 1
fi

# Check project directory
echo "3. Checking project directory..."
PROJECT_DIR="$HOME/nodejs-projects"
if [ -d "$PROJECT_DIR" ]; then
    echo "   ✅ Project directory exists: $PROJECT_DIR"
else
    echo "   ❌ Project directory not found: $PROJECT_DIR"
fi

# Check sample app
echo "4. Checking sample application..."
APP_DIR="$PROJECT_DIR/ansible-node-app"
if [ -d "$APP_DIR" ]; then
    echo "   ✅ Sample app directory exists: $APP_DIR"
    
    # Check package.json
    if [ -f "$APP_DIR/package.json" ]; then
        echo "   ✅ package.json exists"
    else
        echo "   ❌ package.json missing"
    fi
    
    # Check app.js
    if [ -f "$APP_DIR/app.js" ]; then
        echo "   ✅ app.js exists"
    else
        echo "   ❌ app.js missing"
    fi
    
    # Check node_modules
    if [ -d "$APP_DIR/node_modules" ]; then
        echo "   ✅ Dependencies installed (node_modules exists)"
    else
        echo "   ❌ Dependencies not installed"
    fi
else
    echo "   ❌ Sample app not found: $APP_DIR"
fi

# Test global packages
echo "5. Checking global npm packages..."
GLOBAL_PACKAGES=("nodemon" "pm2" "express-generator")
for package in "${GLOBAL_PACKAGES[@]}"; do
    if npm list -g --depth=0 2>/dev/null | grep -q "$package"; then
        echo "   ✅ $package installed globally"
    else
        echo "   ❌ $package not found globally"
    fi
done

# Test if app can start (optional)
echo "6. Testing application startup (optional)..."
if [ -f "$APP_DIR/app.js" ] && [ -f "$APP_DIR/package.json" ]; then
    echo "   🚀 To test the application manually:"
    echo "      cd $APP_DIR"
    echo "      npm start"
    echo "      Then open http://localhost:3000"
else
    echo "   ❌ Cannot test application - files missing"
fi

echo ""
echo "🎉 Test complete! Check the results above."
echo "💡 To run the Node.js exercise playbook:"
echo "   ansible-playbook examples/nodejs-simple.yml"
echo "   or"
echo "   ansible-playbook examples/nodejs-complete.yml"