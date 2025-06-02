#!/bin/bash

echo "🚀 Installing Keeper Commander CLI in one step..."
apt update -qq && apt install -y python3-pip curl && pip3 install --break-system-packages keepercommander keeper-secrets-manager-core pyOpenSSL

echo "✅ Installation completed!"
echo "💡 Use: python3 -m keepercommander.cli [command]"
