### Wait for the requirements to be installed...

The following will be done while you wait:

- Updates the package repository using `sudo apt-get update`.

- Removes the existing installation of `python3-pip` using `sudo apt remove -y python3-pip`.

- Downloads the `get-pip.py` script from the official Python Package Index (PyPI) website using wget.

- Installs `pip` manually by executing the `get-pip.py` script using `sudo python3 get-pip.py`.

- Removes the downloaded `get-pip.py` script using `rm get-pip.py`.

- Upgrades the `pyOpenSSL` package using `python3 -m pip install pyOpenSSL --upgrade`.

- Installs or upgrades the ansible package using `python3 -m pip install -U ansible`.