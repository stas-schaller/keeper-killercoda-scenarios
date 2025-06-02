FROM mysql:debian

RUN apt-get update && \
  apt-get install -y python3 python3-pip python3-venv && \
  apt-get clean

RUN python3 -m pip install --upgrade pip && \
  	python3 -m venv /venv                   # Avoid system installed modules that might interfere.
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

RUN pip3 install --upgrade pip              # Upgrade pip since the distro's Python might be old enough that it doesn't like to install newer modules.

RUN pip3 install keeper-secrets-manager-cli # Install Keeper Secrets Manager CLI

EXPOSE 3306

# Import our configuration from the injected file, place it to the environment variable called KSM_CONFIG
# and then use the built in entrypoint.sh file to start it using KSM wrapper command `exec` that will
# replace environment variables that have values starting w/ `keeper://`
#   NOTE: We could have just imported KSM_CONFIG value as an environment variable into the container
#         but that might lead to leaking secrets, hence we have to mount a volume that will have a
#         out configuration string in the file.
#               Some resources:
#               https://devops.stackexchange.com/a/3904
#               https://diogomonica.com/2017/03/27/why-you-shouldnt-use-env-variables-for-secret-data/
#               https://pythonspeed.com/articles/docker-build-secrets/
ENTRYPOINT ["/bin/sh", "-c", "KSM_CONFIG=$(cat /data/ksmconfig.b64) ksm exec -- /entrypoint.sh mysqld"]

# Just to view record details
#ENTRYPOINT ["/bin/sh", "-c", "KSM_CONFIG=$(cat /data/ksmconfig.b64) ksm secret get YrXVDkmvSvQp_r4w4MmVLw"]

# Command to connect to the db. Root password is taken from the custom field `rootpwd`
# mysql -h 127.0.0.1 -P 3306 --protocol=tcp -u root -p