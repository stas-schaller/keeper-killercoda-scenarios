# #!/bin/bash
# Make sure we are in the `ksm-sample-js` directory in CLI
mkdir ksm-sample-js && cd ksm-sample-js

# Install NodeJS 16
sudo apt-get update
#sudo apt-get install -y curl
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt-get install -y nodejs npm
node --version
