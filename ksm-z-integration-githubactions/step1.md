### Step 1: Configure KSM Application & GitHub Secrets

To allow your GitHub Actions workflow to securely access secrets stored in Keeper, you first need to create a KSM Application configuration. This configuration acts as the credential for the GitHub Action.

**1. Generate KSM Application Configuration using Keeper Commander**

First, log in to Keeper Commander. The `install-prereqs.sh` script associated with this step ensures Keeper Commander is available.

`keeper shell`{{execute}}

Once logged in, generate a new client configuration for your application. Replace `[APP NAME]` with a descriptive name for your GitHub Actions integration (e.g., `GitHub-Actions-MyRepo`). The `--config-init json` flag will output the configuration in JSON format, which is easy to use.

**Wait for Commander to finish installation if it's the first run.**

`sm client add --app [APP NAME] --unlock-ip --config-init json`{{copy}}

You should receive output similar to the following. This JSON blob is your KSM Application Configuration – treat it as a sensitive secret.

```json
Successfully generated Client Device
====================================
Initialized Config: {"hostname": "keepersecurity.com","clien[...]ZcUefxPWewf03LLGeoei0="} 
IP Lock: Disabled
Token Expires On: 2021-10-20 15:07:02
App Access Expires on: Never
```

**2. Add the KSM Configuration as a GitHub Secret**

Navigate to your GitHub repository settings, then go to "Secrets and variables" -> "Actions". Click on "New repository secret".

This KSM configuration JSON will be stored as a secret in GitHub, which the Keeper GitHub Action will use to authenticate.

![GitHub Secrets Page](./assets/img_1.png)

Create a new secret. A common name for this secret is `KSM_CONFIG_JSON` (as used in the example in the next step), but you can name it as you prefer. Paste the entire JSON output from the previous command as the value for this secret.

![Create New GitHub Secret](./assets/img_2.png)

Once added, your secret will be listed.

![GitHub Secret Added](./assets/img_3.png)

In the next step, we will use this GitHub secret (`KSM_CONFIG_JSON`) in the Keeper Secrets Manager GitHub Action to retrieve specific secrets from your vault.
