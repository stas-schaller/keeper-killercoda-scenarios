
### Step 2: Configure and Use the KSM Plugin

Now that the KSM plugin is enabled in Vault, this step will guide you through configuring it with your KSM application credentials and then using Vault commands to access secrets from your Keeper Vault.

**Ensure all commands in this step are run in the second terminal (T2), where you previously set `VAULT_ADDR` and enabled the plugin.** The Vault server should still be running in the first terminal (T1).

### 1. Configure KSM Plugin

To allow the plugin to communicate with your Keeper Vault, you need to provide it with your KSM application's configuration. This configuration is a Base64 encoded JSON string.

*   **Obtain your KSM Configuration**: Use Keeper Commander or the Keeper Web Vault to get the Base64 configuration string for your KSM application. As mentioned in the `intro.md`, ensure this KSM application has the appropriate permissions ("View Record" for reading, "Edit Record" for writing/deleting) for the operations you intend to perform.

Replace `[KSM_CONFIG_BASE64]` in the command below with your actual Base64 configuration string.

`vault write ksm/config ksm_config=[KSM_CONFIG_BASE64]`{{copy T2}}

After running the command, Vault will store this configuration securely and use it to authenticate with Keeper.

### 2. List Secrets (Records)

Once configured, you can list all records accessible by your KSM application through the plugin.

`vault list ksm/records`{{execute T2}}

This command will show a list of record UIDs available from your Keeper Vault via the configured KSM application.

### 3. Read a Specific Record by UID

To retrieve the details of a specific record, use its UID. Replace `[RECORD_UID]` with the UID of a record you want to access (obtained from the previous step or your Keeper Vault).

`vault read -format=json ksm/record uid=[RECORD_UID]`{{copy T2}}

This will output the record's fields and values in JSON format.

### 4. Get TOTP (Two-Factor Code) from a Record

If a record contains a TOTP (Two-Factor Authentication) code field, you can retrieve the current TOTP value. Replace `[RECORD_UID]` with the UID of the record containing the TOTP field.

`vault read -format=json ksm/record/totp uid=[RECORD_UID]`{{copy T2}}

This command is useful for programmatically fetching time-sensitive codes.

### 5. Create a Secret

To create a new secret in your Keeper Vault via HashiCorp Vault, you'll need "Edit Record" permission for your KSM application on the target Shared Folder where the new record will be created. You also need the UID of that target folder.

First, prepare the JSON data for the new secret. Here's an example to create a new login record. You can copy this JSON and save it to a temporary file (e.g., `new_record_data.json`) in your `/root/hashicorp-vault/` directory, or modify it as needed.

**Example `new_record_data.json`:**
```json
{
  "title": "New Vault-Created Login",
  "type": "login",
  "fields": [
    {
      "type": "login",
      "value": [
        "new_user@example.com"
      ]
    },
    {
      "type": "password",
      "value": [
        "SecureP@$$wOrd123"
      ]
    },
    {
      "type": "url",
      "value": [
        "https://example.com"
      ]
    }
  ],
  "notes": "This record was created via HashiCorp Vault KSM plugin."
}
```{{copy T2}}

Now, use the `vault write` command. Replace `[TARGET_FOLDER_UID]` with the UID of the Shared Folder in your Keeper Vault where you want to create this new record. You can get this UID from your Keeper Vault.

`vault write -format=json ksm/record/create folder_uid=[TARGET_FOLDER_UID] data=@new_record_data.json`{{copy T2}}

If successful, a new record will be created in the specified folder in your Keeper Vault.

### 6. Update a Secret

To update an existing secret, you'll need its UID and "Edit Record" permission for your KSM application on that specific record.

First, prepare the JSON data with the fields you want to update. You don't need to provide all fields, only those changing. For example, to update the password of an existing record:

**Example `update_record_data.json`:**
```json
{
  "fields": [
    {
      "type": "password",
      "value": [
        "EvenNewerP@$$wOrd456"
      ]
    }
  ],
  "notes": "Password updated via HashiCorp Vault KSM plugin."
}
```{{copy T2}}

Replace `[RECORD_UID_TO_UPDATE]` with the UID of the record you want to modify. Save the above JSON to `update_record_data.json` or similar.

`vault write -format=json ksm/record uid=[RECORD_UID_TO_UPDATE] data=@update_record_data.json`{{copy T2}}

This will update the specified fields of the record in your Keeper Vault.

### 7. Delete a Secret

To delete a secret, you'll need its UID and "Edit Record" permission for your KSM application on that specific record. Be cautious, as this action is permanent.

Replace `[RECORD_UID_TO_DELETE]` with the UID of the record you wish to delete.

`vault delete ksm/record uid=[RECORD_UID_TO_DELETE]`{{copy T2}}

This will remove the record from your Keeper Vault.

## Cleanup (Optional)

The following commands show how to deregister the plugin and stop the Vault server. This is useful if you want to clean up the environment after testing.

### 8. Deregister the KSM Plugin

First, disable the secrets engine path where KSM was mounted:

`vault secrets disable ksm`{{execute T2}}

Then, deregister the plugin itself:

`vault plugin deregister secret vault-plugin-secrets-ksm`{{execute T2}}

Verify it's removed:

`vault plugin list secret`{{execute T2}}

You should no longer see `vault-plugin-secrets-ksm` in the list.

### 9. Stop the Vault Server

To stop the HashiCorp Vault development server, go to the **first terminal (T1)** where `vault server -dev ...` is running and press `Ctrl+C`.

`echo 'Press Ctrl+C in Terminal 1 (T1) to stop the Vault server.'`{{execute T2}}

This concludes the operations with the KSM plugin in HashiCorp Vault.
