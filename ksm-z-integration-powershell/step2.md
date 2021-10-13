# Listing Secrets

`Get-SecretInfo -Vault MyKeeperVault`{{execute}}

# Getting a Single Secret

`Get-Secret "[SECRET NAME]" -AsPlainText`{{copy}}

# Get an Individual Secret Value From a Secret

`Get-Secret "[SECRET NAME].[FIELD NAME]" -AsPlainText`{{copy}}

> Ex: `Get-Secret "Family Chase Account.Password" -AsPlainText`

# Set a Value to a Secret

`Set-Secret "[SECRET NAME].[FIELD NAME]" <VALUE TO SET>`{{copy}}

# Download a File

`Get-Secret "[SECRET NAME]".files["FILE NAME"] | Set-Content -Path <FILE PATH> -AsByteStream`{{copy}}
