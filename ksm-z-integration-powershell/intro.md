# Keeper Secrets Manager & PowerShell Integration Tutorial

Welcome! This tutorial guides you through integrating Keeper Secrets Manager (KSM) with PowerShell, leveraging Microsoft's `SecretManagement` module. You'll learn how to securely access and manage secrets stored in your Keeper Vault directly within your PowerShell scripts and environment.

## About the Keeper Secrets Manager PowerShell Plugin

The Keeper Secrets Manager PowerShell plugin allows you to seamlessly use secrets from your Keeper Vault in your PowerShell workflows. It registers Keeper as a secure vault within PowerShell's native `SecretManagement` module, enabling you to use standard PowerShell cmdlets to interact with your Keeper secrets.

### Key Features:
- **Retrieve Secrets**: Fetch passwords, API keys, connection strings, and other sensitive data from your Keeper Vault.
- **Vault Integration**: Works as an extension vault for the `Microsoft.PowerShell.SecretManagement` module.
- **Update Secrets**: Modify and update secret values in your Keeper Vault directly from PowerShell (requires appropriate KSM application permissions).
- **Download Files**: Securely download files attached to your Keeper records.

## What You'll Learn

- How to install and configure the necessary PowerShell modules (`Microsoft.PowerShell.SecretManagement`, `SecretManagement.Keeper`, and a local store like `Microsoft.Powershell.SecretStore`).
- How to register your Keeper Vault with PowerShell's Secret Management.
- How to use PowerShell cmdlets (`Get-SecretInfo`, `Get-Secret`, `Set-Secret`) to list, retrieve, and update secrets.
- How to download files attached to Keeper records.

## Prerequisites

To follow this tutorial, you will need:

*   **PowerShell Version 6.0 or later**: Microsoft distributes PowerShell 6+ separately from older versions. This integration requires the newer PowerShell Core.
*   **Keeper Secrets Manager Add-on**: Enabled for your Keeper Business or Enterprise account.
*   **Keeper Role with SM Policy**: Membership in a Keeper Role with the "Secrets Manager" enforcement policy enabled.
*   **KSM Application Configuration**: An initialized KSM Application (One-Time Token or Base64 configuration string). Refer to the [Secrets Manager Configuration Guide](https://docs.keeper.io/secrets-manager/secrets-manager/about/secrets-manager-configuration) if needed.
*   **Execution Policy (Potentially)**: Depending on your system settings, you might need to set your PowerShell execution policy to allow scripts from the PowerShell Gallery. You can do this by running `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser` in an elevated PowerShell prompt if you encounter issues installing modules.

**Environment Setup:**

This Katacoda environment will automatically install PowerShell for you. Please wait for the installation to complete. You should be dropped into a `pwsh` prompt. If not, you can type `pwsh`{{execute}} in the terminal to start PowerShell.

Let's get started by installing the required modules and configuring your Keeper Vault!