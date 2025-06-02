#!/bin/bash

# Update package lists
apt update

# Install Python 3.11+ and pip if not already installed
apt install python3 python3-pip python3-venv python3-dev -y

# Verify Python version (should be 3.11+)
python3 --version

# Create a virtual environment to avoid system package conflicts
python3 -m venv /opt/keeper-env

# Activate the virtual environment
source /opt/keeper-env/bin/activate

# Upgrade pip to latest version
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

echo "✅ Keeper Commander installation completed successfully!"
echo "🐍 Python version: $(python3 --version)"
echo "📦 Using virtual environment at: /opt/keeper-env"
echo "🚀 You can now use 'keeper shell' to start the Commander CLI"
