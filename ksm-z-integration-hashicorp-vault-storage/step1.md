## Installing KSM Plugin and Starting Vault Server

### 0. Install Hashicorp Vault

Wait for the terminal finish installing Hashicorp Vault

### 1. Create plugin directory:

`mkdir plugins`{{execute}}

### 2. Download plugin binary

`wget -q https://github.com/Keeper-Security/secrets-manager/releases/download/vault-plugin-secrets-ksm-v0.1.0/vault-plugin-secrets-ksm_0.1.0_linux_amd64.zip`{{execute}}

### 3. Unzip and copy KSM Vault plugin binary into the plugins folder

`unzip *.zip -d plugins`{{execute}}

### 4. Start Hashicorp Vault server in dev mode

`vault server -dev -dev-root-token-id=root -dev-plugin-dir=/root/hashicorp-vault/plugins`{{execute}}

### 5. In the new Terminal Navigate to the working directory

`cd hashicorp-vault`{{execute T2}}

### 6. Set vault server url in the env vars

`export VAULT_ADDR=http://127.0.0.1:8200`{{execute}}

### 7. Enable KSM Vault plugin

`vault secrets enable -path=myksm vault-plugin-secrets-ksm`{{execute}}

### 8. Check that KSM plugin was registered

`vault secrets list`{{execute}}

At this point you should see `vault-plugin-secrets-ksm` plugin registered in the path `myksm`
