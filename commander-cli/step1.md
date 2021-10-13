
# Pre-requisites
In the steps below, we will be using Python package manager to install Keeper Commander.

Make sure you have following installed:

- Python 3 - `python3 --version`{{execute}}
- Pip - `pip3 --version`{{execute}}

# Install Commander


`pip3 install keepercommander`{{execute}}

# Open Commander Terminal

The first step is to configure a Data Center to which Commander will connect. If you are using USA datacenter, then there is nothing to change, but if you need to connect to Europe, Australia, or GovCloud datacenter, then your commant to start commander will have different `--server` values:

US:  `keeper shell`{{execute}}

EU:  `keeper shell --server keepersecurity.eu`{{execute}}

AU:  `keeper shell --server keepersecurity.com.au`{{execute}}

GOV: `keeper shell --server govcloud.keepersecurity.us`{{execute}}
