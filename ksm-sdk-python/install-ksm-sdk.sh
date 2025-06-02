#!/bin/bash

echo "🚀 Installing Keeper Secrets Manager Python SDK..."
apt update -qq && apt install -y python3-pip curl && pip3 install --break-system-packages keeper-secrets-manager-core pyOpenSSL

echo "✅ Installation completed!"
echo "🧪 Testing installation..."
python3 -c "import keeper_secrets_manager_core; print('KSM Python SDK ready!')" || echo "⚠️ Installation completed but may need manual verification"
echo "💡 Ready to start coding with KSM Python SDK!"
