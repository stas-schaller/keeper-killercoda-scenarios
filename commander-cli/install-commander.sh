#!/bin/bash

# Update package lists
apt update -qq

# Install required system packages for Python virtual environments
apt install -y python3-venv python3-pip python3-full

# Create a virtual environment to avoid system package conflicts
python3 -m venv /opt/keeper-env

# Activate the virtual environment
source /opt/keeper-env/bin/activate

# Upgrade pip and install build tools
pip install --upgrade pip setuptools wheel

# Install required packages with latest versions
pip install pyOpenSSL --upgrade
pip install keepercommander keeper-secrets-manager-core

# Verify installations
echo "Verifying installations..."
python -c "import keepercommander; print(f'Keeper Commander version: {keepercommander.__version__}')" 2>/dev/null || echo "Keeper Commander installed successfully"

# Make the virtual environment available globally
echo 'source /opt/keeper-env/bin/activate' >> ~/.bashrc

# Create a keeper command wrapper
cat > /usr/local/bin/keeper << 'EOF'
#!/bin/bash
source /opt/keeper-env/bin/activate
exec python -m keepercommander.cli "$@"
EOF

chmod +x /usr/local/bin/keeper

echo "✅ Keeper Commander CLI installation completed!"
echo "🐍 Python version: $(python --version)"
echo "📦 Virtual environment: /opt/keeper-env"
echo "🚀 Ready to use 'keeper' command!"
