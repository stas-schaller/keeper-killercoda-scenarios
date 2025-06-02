#!/bin/bash

echo "🚀 Installing Ansible and Keeper Secrets Manager plugin..."
apt update -qq && apt install -y python3-pip curl && pip3 install --break-system-packages ansible keeper-secrets-manager-ansible pyOpenSSL

echo "✅ Installation completed!"
echo "🧪 Testing installations..."
ansible --version | head -1 || echo "⚠️ Ansible installation may need verification"
python3 -c "import keeper_secrets_manager_ansible; print('KSM Ansible plugin ready!')" || echo "⚠️ KSM plugin installation may need verification"
echo "💡 Ready to start automating with secure secrets!"

# Create the playbooks directory
mkdir -p /root/my-playbooks
echo "📁 Created /root/my-playbooks directory for your playbooks"
