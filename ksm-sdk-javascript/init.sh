# #!/bin/bash
# Make sure we are in the `ksm-sample-js` directory in CLI
mkdir ksm-sample-js && cd ksm-sample-js

# Install NodeJS

sudo apt install -y curl
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt install -y nodejs
node --version
