# Listing Secrets

`Get-SecretInfo -Vault MyKeeperVault`{{execute}}

# Getting a Single Secret

`Get-Secret "[SECRET NAME]" -AsPlainText`{{copy}}

# Get an Individual Secret Value From a Secret

`Get-Secret "[SECRET NAME].[FIELD NAME]" -AsPlainText`{{copy}}

> Ex: `Get-Secret "Family Chase Account.Password" -AsPlainText`

# Set a Value to a Secret

`Set-Secret "[SECRET NAME].[FIELD NAME]" -Secret [VALUE TO SET] -Vault MyKeeperVault`{{copy}}

# Download a File

`Get-Secret "[SECRET NAME]".files["FILE NAME"] | Set-Content -Path <FILE PATH> -AsByteStream`{{copy}}

### Step 2: Using Keeper Secrets with PowerShell

Once your Keeper vault is registered and set as the default (as covered in Step 1), you can use standard PowerShell `SecretManagement` cmdlets to interact with your secrets.

**Note on Naming**: If your record titles or field names contain a dot (`.`) or a backslash (`\`), you will need to escape these characters with a backslash when using them in dot notation. For example, a field named `server.address` would be referenced as `server\.address`.

**1. Listing Secrets**

To see a list of all records accessible by your KSM Application from the default Keeper vault:

`Get-SecretInfo`{{execute}}

*If 'Keeper' was not set as the default vault, you would use: `Get-SecretInfo -Vault Keeper`*

**Example Output:**
```powershell
Name                                  Type      VaultName
----                                  ----      ---------
RECORD_UID_1_WebAppLogin              Hashtable Keeper
RECORD_UID_2_DatabaseCreds            Hashtable Keeper
RECORD_UID_3_SSH_Key_File             Hashtable Keeper
```
*The `Name` column displays each record's UID followed by its title (if the title is not too long, otherwise it might be truncated or just show UID).* 

**2. Getting a Single Secret (Full Record Object)**

To retrieve all fields and values for a specific secret record, use its UID or its full title. The `-AsPlainText` switch displays the values directly; otherwise, sensitive fields like passwords are returned as `SecureString` objects.

Replace `[RECORD_UID_OR_TITLE]` with the actual UID or title of your record (e.g., `_3zT0HvBtRdYzKTMw1IySA` or `"My Web App Login"`). Remember to quote titles with spaces.

`Get-Secret -Name "[RECORD_UID_OR_TITLE]" -AsPlainText`{{copy}}

**Example Output (for a login record):**
```powershell
Name                           Value
----                           -----
login                          webappuser
password                       S3cureP@sswOrd!
url                            https://myapp.example.com
notes                          Accessed via PowerShell
Files                          {config.json, id_rsa.ppk}
custom_field_customFieldName   CustomValue123
```

**3. Getting a Specific Value from a Secret (Dot Notation)**

To retrieve a specific field (like `password`), custom field, or file information, use dot notation following the record's UID or title.

*   **Standard Field (e.g., password):**
    `Get-Secret -Name "[RECORD_UID_OR_TITLE].password" -AsPlainText`{{copy}}

*   **Custom Field (e.g., a custom field named `apiKey`):**
    `Get-Secret -Name "[RECORD_UID_OR_TITLE].custom_field_apiKey" -AsPlainText`{{copy}}
    *(Note: custom fields are prefixed with `custom_field_`)*

**Example:** Retrieve the password from a record titled "WebAppLogin":
`Get-Secret -Name "WebAppLogin.password" -AsPlainText`{{execute}}

**4. Setting/Updating a Secret Value**

To update the value of a specific field in a Keeper record (requires the KSM application to have "Editable" permissions on the record):

Replace `[RECORD_UID_OR_TITLE]`, `[FIELD_NAME]`, and `[NEW_VALUE]` accordingly.

`Set-Secret -Name "[RECORD_UID_OR_TITLE].[FIELD_NAME]" -Secret "[NEW_VALUE]"`{{copy}}

**Example:** Update the URL field of a record titled "WebAppLogin":
`Set-Secret -Name "WebAppLogin.url" -Secret "https://new.myapp.example.com"`{{execute}}

*(If 'Keeper' is not your default vault, add `-Vault Keeper` to the command)*

**5. Downloading a File**

To download a file attached to a Keeper record, use dot notation to specify the record and the filename within the `files` collection. Then, pipe the output to `Set-Content`.

Replace `[RECORD_UID_OR_TITLE]` and `[FILENAME_IN_KEEPER]` with your actual values. Replace `<PATH_TO_SAVE_FILE>` with the desired local path (e.g., `./downloaded_attachment.txt`).

`Get-Secret -Name "[RECORD_UID_OR_TITLE].files[[FILENAME_IN_KEEPER]]" | Set-Content -Path "<PATH_TO_SAVE_FILE>" -AsByteStream`{{copy}}

**Example:** Download `my_config.json` from a record named "Server Configs" to the current directory:
`Get-Secret -Name "Server Configs.files[my_config.json]" | Set-Content -Path ./my_config.json -AsByteStream`{{execute}}

This will download the specified file to the path you provide.
