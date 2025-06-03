### Step 3: Cleanup

To remove the Keeper Secrets Manager PowerShell plugin and its configuration from your environment, follow these steps:

**1. Unregister Vaults**

First, unregister the Keeper vault and then the local store vault you created. If you used different names than `Keeper` and `LocalStore`, replace them accordingly.

Unregister the Keeper vault:
`Unregister-SecretVault Keeper -Confirm:$false`{{execute}}

Unregister the local store vault (e.g., `LocalStore` if you used `Microsoft.Powershell.SecretStore`):
`Unregister-SecretVault LocalStore -Confirm:$false`{{execute}}

*(Using `Unregister-SecretVault * -Confirm:$false` would unregister all vaults, which might be broader than intended if you use PowerShell Secret Management for other purposes.)*

**2. Uninstall Keeper Secrets Manager Module**

`Uninstall-Module -Name SecretManagement.Keeper -Force`{{execute}}

**3. Reset and Uninstall Local Secret Store (Optional)**

If you used `Microsoft.Powershell.SecretStore` and want to completely remove its local data and the module itself:

Reset the SecretStore (this deletes the local database where KSM config was stored):
`Reset-SecretStore -Confirm:$false`{{execute}}

Then, uninstall the module:
`Uninstall-Module -Name Microsoft.Powershell.SecretStore -Force`{{execute}}

**4. Uninstall PowerShell Secret Management Module (Optional)**

If you no longer need the `Microsoft.PowerShell.SecretManagement` module itself:

`Uninstall-Module -Name Microsoft.PowerShell.SecretManagement -Force`{{execute}}

This completes the cleanup process.
