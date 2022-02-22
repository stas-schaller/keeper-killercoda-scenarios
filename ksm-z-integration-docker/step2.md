## Create `Dockerfile`

<pre class="file" data-filename="Dockerfile" data-target="replace">
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
</pre>

## Initialize config from One-Time-Token

`cd workdir`{{execute}}

### Make a mounting volume folder to store config file

`mkdir vol`{{execute}}

### Generate config base64 file to the volume folder

_Note: **Replace `[ONE-TIME-TOKEN]` with the one time token generate in Web Vault**_

`ksm init default [ONE-TIME-TOKEN] > vol/ksmconfig.b64`{{copy}}

## Step 3: Build docker container

Build container and then start it (the container will be removed once it is stopped)

`docker build -t ksmexample .`{{execute}}

### Run the container

_Note: **Replace `[ONE-TIME-TOKEN]` with the one time token generate in Web Vault**_

`docker run \
-v "$(pwd)/vol:/data" \
-e MYSQL_ROOT_PASSWORD='keeper://[RECORD UID]/custom_field/rootpwd' \
-e MYSQL_USER='keeper://[RECORD UID]/field/login' \
-e MYSQL_PASSWORD='keeper://[RECORD UID]/field/password' \
-e MYSQL_DATABASE='mydb' \
-p 3306:3306 \
--rm \
-it ksmexample`{{copy}}


