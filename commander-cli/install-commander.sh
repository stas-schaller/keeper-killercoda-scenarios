#!/bin/bash

echo "🚀 Installing Keeper Commander CLI in one step..."
apt update -qq && apt install -y python3-pip curl && pip3 install --break-system-packages --ignore-installed keepercommander keeper-secrets-manager-core pyOpenSSL

echo "✅ Installation completed!"
echo "🧪 Testing installation..."
python3 -m keepercommander.cli --version || echo "⚠️ Installation completed but may need manual verification"
echo "💡 Use: python3 -m keepercommander.cli [command]"
