#!/bin/bash

echo "📦 Updating package lists..."
apt update -qq

echo "🐍 Installing Python virtual environment packages..."
apt install -y python3-venv python3-pip python3-full

echo "🔧 Creating virtual environment..."
python3 -m venv /opt/keeper-env

echo "⚡ Activating virtual environment..."
source /opt/keeper-env/bin/activate

echo "📈 Upgrading pip and installing build tools..."
pip install --upgrade pip setuptools wheel

echo "🔐 Installing Keeper Commander CLI..."
pip install pyOpenSSL --upgrade
pip install keepercommander keeper-secrets-manager-core

echo "✅ Verifying installation..."
python -c "import keepercommander; print(f'Keeper Commander version: {keepercommander.__version__}')" 2>/dev/null

echo "🔗 Setting up global access..."
echo 'source /opt/keeper-env/bin/activate' >> ~/.bashrc

echo "🛠️ Creating keeper command wrapper..."
cat > /usr/local/bin/keeper << 'EOF'
#!/bin/bash
source /opt/keeper-env/bin/activate
exec python -m keepercommander.cli "$@"
EOF

chmod +x /usr/local/bin/keeper

echo "🎉 Installation completed successfully!"

# Signal completion to foreground script
touch /tmp/keeper-setup-complete
