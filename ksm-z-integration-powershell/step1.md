### Step 1: Installation and Vault Registration

This step walks through the complete setup of the Keeper Secrets Manager PowerShell plugin, from installing necessary modules to registering your Keeper Vault.

**Important**: Ensure your PowerShell execution policy allows script execution. If you encounter errors installing modules, you might need to run `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser` in an elevated PowerShell prompt and then restart your PowerShell session.

**1. Install Microsoft PowerShell Secret Management Module**

Keeper Secrets Manager uses the `Microsoft.PowerShell.SecretManagement` module. Install it from the PowerShell Gallery:

`Install-Module -Name Microsoft.PowerShell.SecretManagement -Force -Confirm:$false -SkipPublisherCheck`{{execute}}

**2. Install Keeper Secrets Manager for PowerShell**

Next, install the Keeper Secrets Manager PowerShell extension:

`Install-Module -Name SecretManagement.Keeper -Force -Confirm:$false -SkipPublisherCheck`{{execute}}

*(To update an existing installation, you would use `Update-Module -Name SecretManagement.Keeper`)*

**3. Install a Local Secret Store Extension**

The Keeper PowerShell plugin needs a local secret management extension to securely store its own configuration. We'll use `Microsoft.Powershell.SecretStore` as recommended in the official documentation. Other stores like `SecretManagement.KeyChain` can also be used.

`Install-Module -Name Microsoft.Powershell.SecretStore -Force -Confirm:$false -SkipPublisherCheck`{{execute}}

**4. Register a Local Vault for Configuration Storage**

Register a secret vault for the local store. This vault will store the KSM plugin's configuration. We'll name it `LocalStore`.

`Register-SecretVault -Name LocalStore -ModuleName Microsoft.Powershell.SecretStore -DefaultVault`{{execute}}

*Note: The first time you register `Microsoft.Powershell.SecretStore`, it may prompt you to create a password to secure this local vault. Please follow the prompts.* Setting it as `-DefaultVault` here is for the local store; we will set Keeper as the default for secrets access later.

**5. Register the Keeper Vault**

Now, register your Keeper Secrets Manager Vault. You'll use the local vault (`LocalStore`) to save the KSM configuration and connect to Keeper using either a One-Time Token or a Base64 encoded configuration string.

*   **To generate a One-Time Token or Base64 Config:** Refer to the [Keeper Secrets Manager Quick Start Guide](https://docs.keeper.io/secrets-manager/secrets-manager/quick-start-guide#create-a-secrets-manager-client-device).
*   **Permissions Note**: If you intend to update secrets (`Set-Secret`), ensure the KSM Application has "Editable" permissions for the relevant records/folders in your Keeper Vault.

Choose **one** of the following methods:

**Method A: Using a One-Time Token**
Replace `[ONE-TIME TOKEN]` with your actual token.

`Register-KeeperVault -Name Keeper -LocalVaultName LocalStore -OneTimeToken [ONE-TIME TOKEN]`{{copy}}

**Method B: Using a Base64 Encoded Configuration**
Replace `[BASE64_CONFIG_STRING]` with your actual Base64 encoded KSM configuration.

`Register-KeeperVault -Name Keeper -LocalVaultName LocalStore -Config [BASE64_CONFIG_STRING]`{{copy}}

For this tutorial, paste one of these commands (with your actual token/config) into the terminal and execute it.

**6. Set Keeper Vault as Default (Recommended)**

Set your newly registered Keeper vault as the default. This tells PowerShell's `SecretManagement` module to use your Keeper vault when getting and setting secrets without needing to specify `-Vault Keeper` in every command.

`Set-SecretVaultDefault Keeper`{{execute}}

Your Keeper Secrets Manager PowerShell plugin is now set up and ready to use!
