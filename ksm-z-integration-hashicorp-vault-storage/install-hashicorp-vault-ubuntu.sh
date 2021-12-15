#!/bin/bash

mkdir -p ~/hashicorp-vault
cd ~/hashicorp-vault

# Install Vault in Ubuntu
# Source: https://www.cyberithub.com/how-to-install-hashicorp-vault-on-ubuntu-20-04-lts/
apt update -y
# apt-get install -y curl
# apt-get install -y gnupg 
apt install -y software-properties-common

curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

# Update to add the repository, and install the Vault.
apt update -y
apt install -y vault
vault --version