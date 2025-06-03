#!/bin/bash

echo "Starting PowerShell installation for Ubuntu..."

# Install prerequisites for adding Microsoft repository
echo "Updating package lists and installing prerequisites (curl, gnupg, apt-transport-https)..."
sudo apt-get update -y
sudo apt-get install -y curl gnupg apt-transport-https lsb-release

# Import the public Microsoft GPG key
echo "Importing Microsoft GPG key..."
wget -q https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb

# Update the package list again and install PowerShell
echo "Updating package list and installing PowerShell..."
sudo apt-get update -y
sudo apt-get install -y powershell

echo "PowerShell installation complete."
echo "Attempting to start PowerShell (pwsh)..."

# The Katacoda setup script in index.json uses `courseData` which executes this script.
# The last command `pwsh` will drop the user into the PowerShell prompt.
# If this script were a `setup.sh` for a step, we might add:
# echo "done" >> /opt/.backgroundfinished

pwsh
