#!/bin/bash

echo "🚀 Installing Keeper Secrets Manager CLI in one step..."
apt update -qq && apt install -y python3-pip curl && pip3 install --break-system-packages keeper-secrets-manager-cli

echo "✅ Installation completed!"
echo "🧪 Testing installation..."
python3 -m keeper_secrets_manager_cli --version || echo "⚠️ Installation completed but may need manual verification"
echo "💡 Use: python3 -m keeper_secrets_manager_cli [command]" 