### Step 2: Advanced Secret Retrieval & Data Sources

This step delves deeper into retrieving secrets, showcasing how to access detailed fields from various record types using both specific and generic data sources. We will also cover how to list available folders.

**A. Detailed Field Access from a Login Record**

Building on the basic retrieval, let's extract more fields from a `secretsmanager_login` data source. This example also uses the `hashicorp/local` provider to write details to a local file for inspection, which is a common debugging or output technique.

Ensure you have a login record in Keeper that your KSM application can access.

Update/create your `main.tf` with the following:

```terraform
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    secretsmanager = {
      source  = "keeper-security/secretsmanager"
      version = ">= 1.0.0" # Use your desired provider version
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.1" # Or your desired version
    }
  }
}

provider "secretsmanager" {
  credential = "[CONFIG JSON or BASE64]" # Replace with your KSM config
}

provider "local" {}

data "secretsmanager_login" "detailed_login_secret" {
  path = "[UID_OF_LOGIN_RECORD]" # Replace with your Login Record UID
}

# Outputting various fields from the login record
output "login_record_uid" {
  value = data.secretsmanager_login.detailed_login_secret.path
}
output "login_record_type" {
  value = data.secretsmanager_login.detailed_login_secret.type
}
output "login_record_title" {
  value = data.secretsmanager_login.detailed_login_secret.title
}
output "login_record_notes" {
  value     = data.secretsmanager_login.detailed_login_secret.notes
  sensitive = true
}
output "login_record_login_value" {
  value = data.secretsmanager_login.detailed_login_secret.login
}
output "login_record_password_value" {
  value     = data.secretsmanager_login.detailed_login_secret.password
  sensitive = true
}
output "login_record_url" {
  value = data.secretsmanager_login.detailed_login_secret.url
}

# Example: Iterating over TOTP fields if they exist
output "login_record_totp_details" {
  value = [
    for t in data.secretsmanager_login.detailed_login_secret.totp : {
      url   = t.url
      token = t.token # This will be the current OTP, changes frequently
      ttl   = t.ttl
    }
  ]
  sensitive = true
}

# Example: Iterating over File References if they exist
output "login_record_file_references" {
  value = [
    for fr in data.secretsmanager_login.detailed_login_secret.file_ref : {
      uid           = fr.uid
      title         = fr.title
      name          = fr.name
      type          = fr.type
      size          = fr.size
      last_modified = fr.last_modified
      # content_base64 = fr.content_base64 # Be cautious enabling this, can be large and sensitive
    }
  ]
  sensitive = true
}

# Writing details to a local file for inspection
resource "local_file" "login_secret_details" {
  filename        = "${path.module}/login_secret_details.txt"
  file_permission = "0600"
  content         = <<-EOT
    UID:    ${data.secretsmanager_login.detailed_login_secret.path}
    Type:   ${data.secretsmanager_login.detailed_login_secret.type}
    Title:  ${data.secretsmanager_login.detailed_login_secret.title}
    Notes:  ${data.secretsmanager_login.detailed_login_secret.notes}
    ======
    Login:    ${data.secretsmanager_login.detailed_login_secret.login}
    Password: ${data.secretsmanager_login.detailed_login_secret.password} (Sensitive - not shown directly)
    URL:      ${data.secretsmanager_login.detailed_login_secret.url}

    TOTP Fields:
    ${join("\n", [
      for t in data.secretsmanager_login.detailed_login_secret.totp : (
        "    - URL: ${t.url}, Token: (Sensitive), TTL: ${t.ttl}"
      )
    ])}

    File References:
    ${join("\n", [
      for fr in data.secretsmanager_login.detailed_login_secret.file_ref : (
        "    - UID: ${fr.uid}, Name: ${fr.name}, Type: ${fr.type}, Size: ${fr.size}"
      )
    ])}
  EOT
}
```{{copy}}

**Instructions:**
1.  Replace `[CONFIG JSON or BASE64]` with your KSM configuration string.
2.  Replace `[UID_OF_LOGIN_RECORD]` with the UID of an existing Login record in your Keeper Vault.
3.  Run `terraform init`{{execute}} to initialize providers.
4.  Run `terraform apply -auto-approve`{{execute}} to fetch the data and create the local file.
5.  Inspect the output values and the generated `login_secret_details.txt` file.

**B. Using the Generic `secretsmanager_record` Data Source**

The `secretsmanager_login` data source is specific. For other record types or for more generic handling, use `data "secretsmanager_record"`.

```terraform
# Add this to your main.tf or create a new one, ensuring provider config is present.

# Replace with the UID of ANY existing record in your Vault
data "secretsmanager_record" "generic_secret" {
  path = "[UID_OF_ANY_RECORD]" # Replace with your record UID
}

output "generic_secret_uid" {
  description = "UID of the fetched generic record."
  value       = data.secretsmanager_record.generic_secret.path
}

output "generic_secret_type" {
  description = "Type of the fetched generic record."
  value       = data.secretsmanager_record.generic_secret.type
}

output "generic_secret_title" {
  description = "Title of the fetched generic record."
  value       = data.secretsmanager_record.generic_secret.title
}

# Accessing standard fields (structure depends on record type)
output "generic_secret_standard_fields" {
  description = "Standard fields of the fetched generic record."
  value       = data.secretsmanager_record.generic_secret.fields
  sensitive   = true
}

# Accessing custom fields
output "generic_secret_custom_fields" {
  description = "Custom fields of the fetched generic record."
  value       = data.secretsmanager_record.generic_secret.custom
  sensitive   = true
}

# Accessing file attachments
output "generic_secret_file_attachments" {
  description = "File attachments of the fetched generic record."
  value       = data.secretsmanager_record.generic_secret.file_ref
  sensitive   = true
}
```{{copy}}

**Instructions:**
1.  Ensure your `provider "secretsmanager"` block is configured.
2.  Replace `[UID_OF_ANY_RECORD]` with the UID of an existing record (any type) in your Vault.
3.  Run `terraform apply -auto-approve`{{execute}}.
4.  Review the new outputs. The structure of `fields`, `custom`, and `file_ref` will vary based on the record's type and content.

**C. Listing Existing Folders**

To organize or find placement for new secrets, you might need to list existing folders within your KSM application's scope.

```terraform
# Add this to your main.tf, ensuring provider config is present.

data "secretsmanager_folders" "all_accessible_folders" {}

output "all_folder_details" {
  description = "Details of all folders accessible by the KSM application."
  value       = data.secretsmanager_folders.all_accessible_folders.folders
}

# Example: Filtering folders by a parent folder UID (if known)
# data "secretsmanager_folders" "specific_subfolders" {
#   folder_uid = "[PARENT_FOLDER_UID_HERE]"
# }
# 
# output "specific_subfolder_details" {
#   description = "Details of subfolders under a specific parent."
#   value       = data.secretsmanager_folders.specific_subfolders.folders
# }
```{{copy}}

**Instructions:**
1.  Ensure your `provider "secretsmanager"` block is configured.
2.  Run `terraform apply -auto-approve`{{execute}}.
3.  Inspect the `all_folder_details` output. It will show a list of folder objects, each with `folder_uid`, `name`, `parent_uid`, etc., that your KSM application can see.

This step has shown you how to retrieve comprehensive details from your Keeper records and list folder structures, preparing you for managing these resources in the next steps. 