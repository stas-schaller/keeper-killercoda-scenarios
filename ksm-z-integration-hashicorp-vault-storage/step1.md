## Installing KSM Plugin and Starting Vault Server

### Step 1: Install KSM Plugin and Start Vault Server

In this step, we will download the KSM plugin for HashiCorp Vault, prepare the plugin directory, and start the Vault server in development mode with the plugin enabled.

### 1. Confirm HashiCorp Vault Installation

The `intro.md` tab explained that HashiCorp Vault would be installed automatically. Please ensure the installation script in the **first terminal (T1)** has completed. You should see a "Vault installation complete" message or similar.

### 2. Create Plugin Directory

First, create a directory where Vault will look for plugins.

`mkdir plugins`{{execute T1}}

### 3. Download KSM Vault Plugin Binary

Next, download the KSM Vault plugin binary. 

> **Important**: The link below points to a specific version. Always check the [Keeper Security Secrets Manager Releases Page](https://github.com/Keeper-Security/secrets-manager/releases?q=vault-plugin-secrets-ksm&expanded=true) for the latest version of the `vault-plugin-secrets-ksm` and replace the URL and filename accordingly.

For this tutorial, we will use version 1.0.0 as an example:

`wget -q https://github.com/Keeper-Security/secrets-manager/releases/download/vault-plugin-secrets-ksm%2Fv1.0.0/vault-plugin-secrets-ksm_1.0.0_linux_amd64.zip`{{execute T1}}

### 4. Unzip and Place KSM Plugin Binary

Unzip the downloaded file and place the plugin binary into the `plugins` directory you created.

`unzip *.zip -d plugins`{{execute T1}}

### 5. Start HashiCorp Vault Server (Dev Mode)

Now, start the HashiCorp Vault server in development mode. The `-dev` flag makes it easy to get a server running for testing and development without needing to unseal it. The `-dev-root-token-id=root` flag sets the root token to "root" for simplicity in this tutorial. The `-dev-plugin-dir` flag tells Vault where to find the KSM plugin.

This command will occupy the current terminal (T1) with server logs.

`vault server -dev -dev-root-token-id=root -dev-plugin-dir=/root/hashicorp-vault/plugins`{{execute T1}}

**Note**: The Vault server is now running in the first terminal (T1). For the subsequent commands, you will use the **second terminal (T2)**, which is automatically opened by Killercoda.

### 6. Navigate to Working Directory in New Terminal

In the **second terminal (T2)**, navigate to the working directory.

`cd /root/hashicorp-vault`{{execute T2}}

### 7. Set Vault Server Address Environment Variable

To interact with the Vault server, set the `VAULT_ADDR` environment variable. This tells the Vault CLI where to send commands.

`export VAULT_ADDR='http://127.0.0.1:8200'`{{execute T2}}

### 8. Enable KSM Vault Plugin

Now, enable the KSM secrets engine plugin. We will mount it at the path `ksm`. This is the path recommended in the official Keeper documentation.

`vault secrets enable -path=ksm vault-plugin-secrets-ksm`{{execute T2}}

### 9. Verify KSM Plugin Registration

Check that the KSM plugin was successfully registered and is enabled at the specified path.

`vault secrets list`{{execute T2}}

At this point, you should see `vault-plugin-secrets-ksm` listed with the path `ksm/`. This confirms the plugin is ready for configuration.
