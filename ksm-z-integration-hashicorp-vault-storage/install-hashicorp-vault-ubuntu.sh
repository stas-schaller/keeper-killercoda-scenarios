#!/bin/bash

echo "Creating directory for Hashicorp Vault..."
mkdir -p ~/hashicorp-vault
cd ~/hashicorp-vault

echo "Updating package lists..."
apt update -y

echo "Installing software-properties-common..."
apt install -y software-properties-common

echo "Adding HashiCorp GPG key..."
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -

echo "Adding HashiCorp repository..."
apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

# Update to add the repository, and install the Vault.
echo "Updating package lists again..."
apt update -y
echo "Installing Vault..."
apt install -y vault
echo "Verifying Vault installation..."
vault --version

echo "Hashicorp Vault installation complete." 
echo "done" >> /opt/.backgroundfinished