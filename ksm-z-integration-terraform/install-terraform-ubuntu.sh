#!/bin/bash

# Install Terraform CLI in Ubuntu
# Source: https://learn.hashicorp.com/tutorials/terraform/install-cli
apt update -y
# apt-get install -y curl
# apt-get install -y gnupg 
apt install -y software-properties-common

curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add - 
apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

# Update to add the repository, and install the Terraform CLI.
apt update -y
apt install -y terraform

# echo "Terraform was installed" >> /opt/.backgroundfinished
