#!/bin/bash

# Install PowerShell using Snap
# -----------------------------
#apt-get install snap snapd -y
#snap install powershell --classic
#Install PowerShell from Ubuntu Repository
# -----------------------------
wget -q https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
dpkg -i packages-microsoft-prod.deb
apt-get update -y
apt-get -y install powershell && rm -f packages-microsoft-prod.deb && clear && pwsh
