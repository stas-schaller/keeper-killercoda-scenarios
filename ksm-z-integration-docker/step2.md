## Step 2: Create dockerfile that builds on the default MySQL dockerfile



<pre class="file" data-filename="Dockerfile" data-target="replace">
FROM mysql:debian

RUN apt-get update && \
  apt-get install -y python3 python3-pip python3-venv && \
  apt-get clean

# Avoid system installed modules that might interfere.
ENV VIRTUAL_ENV /venv
RUN python3 -m pip install --upgrade pip && \
  	python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Upgrade pip since the distro's Python might be old enough that it doesn't like to install newer modules.
RUN pip3 install --upgrade pip

# Install Keeper Secrets Manager CLI
RUN pip3 install keeper-secrets-manager-cli


ENV MYSQL_ROOT_PASSWORD keeper://YrXVDkmvSvQp_r4w4MmVLw/custom_field/rootpwd
ENV MYSQL_PASSWORD      keeper://YrXVDkmvSvQp_r4w4MmVLw/field/password
ENV MYSQL_USER          keeper://YrXVDkmvSvQp_r4w4MmVLw/field/login
ENV MYSQL_DATABASE      keeper://YrXVDkmvSvQp_r4w4MmVLw/custom_field/dbname

# Import our configuration, decode it, and store it a place where ksm can find it.
#RUN ksm profile import $(cat /run/secrets/ksmconfig.b64)
# ENTRYPOINT ["KSM_CONFIG=$(cat /run/secrets/ksmconfig.b64)", "/bin/sh", "-c", "ksm exec -- docker-entrypoint.sh"]
# ENTRYPOINT ["/bin/sh", "-c" , "ksm profile import $(cat /run/secrets/ksmconfig.b64) && ksm exec -- docker-entrypoint.sh"]
ENTRYPOINT ["KSM_CONFIG=$(cat /tmp/ksmconfig.b64)", "/bin/sh", "-c", "ksm exec -- docker-entrypoint.sh"]



</pre>


## Initialize config from One-Time-Token

Replace `[ONE-TIME-TOKEN]` with the one time token generate in Web Vault

`ksm init default [ONE-TIME-TOKEN] > ksmconfig.b64`{{copy}}



## Step 3: Build docker container

Build container and then start it (the container will be removed once it is stopped)



`docker build \
-q \
--progress=plain \
--no-cache \
-t ksmexample .`{{execute}}


Run the container

`docker run -v "$(pwd)/ksmconfig.b64:/tmp/ksmconfig.b64:ro" --rm -it ksmexample`{{execute}}

