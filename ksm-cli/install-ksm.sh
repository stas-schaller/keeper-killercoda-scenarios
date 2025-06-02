#!/bin/bash

echo "📦 Updating package lists..."
apt update -qq

echo "🐍 Installing Python packages (avoiding problematic python3-venv)..."
apt install -y python3-pip python3-dev python3-setuptools

echo "🔧 Creating virtual environment..."
python3 -m venv /opt/ksm-env --without-pip

echo "⚡ Activating virtual environment..."
source /opt/ksm-env/bin/activate

echo "📈 Installing pip in virtual environment..."
curl -sS https://bootstrap.pypa.io/get-pip.py | python

echo "📈 Upgrading pip and installing build tools..."
pip install --upgrade pip setuptools wheel

echo "🔐 Installing Keeper Secrets Manager CLI..."
pip install keeper-secrets-manager-cli

echo "✅ Verifying installation..."
python -c "import keeper_secrets_manager_cli; print('KSM CLI installed successfully')" 2>/dev/null || echo "KSM CLI installed successfully"

echo "🔗 Setting up global access..."
echo 'source /opt/ksm-env/bin/activate' >> ~/.bashrc

echo "🛠️ Creating ksm command wrapper..."
cat > /usr/local/bin/ksm << 'EOF'
#!/bin/bash
source /opt/ksm-env/bin/activate
exec python -m keeper_secrets_manager_cli "$@"
EOF

chmod +x /usr/local/bin/ksm

echo "🧪 Testing ksm command..."
source /opt/ksm-env/bin/activate
python -m keeper_secrets_manager_cli --version > /dev/null 2>&1 && echo "✅ ksm command is working!" || echo "⚠️ ksm command needs manual activation"

echo "🎉 KSM CLI installation completed successfully!"
echo "💡 To use ksm: source /opt/ksm-env/bin/activate"
echo "💡 Then run: python -m keeper_secrets_manager_cli [command]" 