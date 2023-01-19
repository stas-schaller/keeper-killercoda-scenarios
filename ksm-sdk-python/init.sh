# #!/bin/bash

sudo apt-get update
#sudo apt-get install -y curl

# install pypi manually, not through apt-get as it will give us some errors with the installed package

sudo apt remove -y python3-pip
wget https://bootstrap.pypa.io/get-pip.py
sudo python3 get-pip.py
rm get-pip.py

# Install KSM SDK
python3 -m pip install -U keeper-secrets-manager-core
