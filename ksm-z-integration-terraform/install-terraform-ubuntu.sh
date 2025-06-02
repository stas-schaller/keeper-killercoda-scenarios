#!/bin/bash

# Install Terraform CLI in Ubuntu
# Source: https://learn.hashicorp.com/tutorials/terraform/install-cli
apt update -y && apt-get install -y curl gnupg software-properties-common && curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - && apt-add-repository -y "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" && apt update -y && apt install -y terraform

# snap install terraform --classic
# echo "Terraform was installed" >> /opt/.backgroundfinished

mkdir ~/terraform-example && cd ~/terraform-example && touch main.tf
