
## 1. Install Microsoft PowerShell Secret Management Module:

`Install-Module -Name Microsoft.PowerShell.SecretManagement -Force`{{execute}}

## 2. Install Keeper Secrets Manager for PowerShell
`Install-Module -Name SecretManagement.Keeper -Force`{{execute}}

## 3. Install Secrets Management extension

`Install-Module -Name Microsoft.Powershell.SecretStore -Force`{{execute}}

## 4. Register a Vault to use for Configuration Storage

`Register-SecretVault -Name MyLocalStore -ModuleName Microsoft.Powershell.SecretStore`{{execute}}

## 5. Register the Keeper Vault

[Go here](generate-one-time-token.html) for instructions to generate One-Time Token

`Register-KeeperVault -Name MyKeeperVault -LocalVaultName MyLocalStore -OneTimeToken [ONE-TIME TOKEN]`{{copy}}

## 6. Set Keeper Vault as default vault

`Set-SecretVaultDefault MyKeeperVault`{{execute}}
