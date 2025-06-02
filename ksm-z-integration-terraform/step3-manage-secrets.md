### Step 3: Managing Secrets - Create, Update, Delete

Beyond reading secrets, a key strength of Terraform is managing the lifecycle of your resources, including secrets in Keeper. This step covers creating, updating, and deleting records.

**A. Creating a New Record via Terraform**

Let's create a new Login record. This uses a `resource` block (not `data`) because Terraform will be responsible for its existence.

Update/create your `main.tf` (ensure provider configuration from Step 1 or 2 is present, but only once):

```terraform
# Provider configuration (ensure this is defined from previous steps)
# provider "secretsmanager" {
#   credential = "[CONFIG JSON or BASE64]"
# }

resource "secretsmanager_login" "new_app_creds" {
  title = "My Terraform App Credentials"
  notes = "These credentials were provisioned by Terraform for a new application."

  # Optional: Specify a folder_uid to place this record in a specific folder.
  # You can get folder UIDs from the output in Step 2 (Part C).
  # folder_uid = "[EXISTING_FOLDER_UID]"

  login {
    value = "new_tf_user@example.com"
  }

  password {
    # For simplicity, we set a password value.
    # The provider also supports password generation for applicable fields.
    # See provider documentation for `generate` and `complexity` within password blocks.
    # To auto-generate a password you could do (check docs for all options):
    # generate = "yes"
    # complexity {
    #   length = 20
    #   caps = 3
    #   lowercase = 3
    #   digits = 3
    #   special = 2
    # }
    value = "Str0ngP@sswOrdGeneratedByTF!"
  }

  url {
    value = "https://tf-app.example.com"
  }
  
  # Example of adding a custom text field
  # Note: For adding custom fields to existing types like login, you would typically 
  # use the generic `secretsmanager_record` resource or check if the typed resource supports custom blocks.
  # For this example, we'll keep it to standard `login` fields. 
  # If you need custom fields on creation, the generic `secretsmanager_record` resource is more flexible.
}

output "new_app_creds_uid" {
  description = "UID of the newly created login record (this is the resource ID)."
  value       = secretsmanager_login.new_app_creds.id
}

output "new_app_creds_title" {
  description = "Title of the newly created login record."
  value       = secretsmanager_login.new_app_creds.title
}

output "new_app_creds_login_value" {
  description = "Login value of the newly created record."
  value       = secretsmanager_login.new_app_creds.login[0].value # Accessing the block's value
}
```{{copy}}

**Instructions for Creation:**

1.  Ensure your provider block is correctly configured.
2.  Optionally, replace `[EXISTING_FOLDER_UID]` if you want to place the record in a specific folder.
3.  Save `main.tf`.
4.  Initialize if you haven't recently: `terraform init`{{execute}}
5.  Apply to create the record: `terraform apply -auto-approve`{{execute}}
6.  Review the outputs. Verify the record's creation in your Keeper Vault.

**B. Updating an Existing Record Managed by Terraform**

Once a resource is managed by Terraform, you update it by changing its attributes in your configuration file.

Let's modify the `notes` and the `login.value` for the `new_app_creds` record created above.

In `main.tf`, find the `resource "secretsmanager_login" "new_app_creds"` block and make these changes:

```terraform
# ... (provider configuration and other resources) ...

resource "secretsmanager_login" "new_app_creds" {
  title = "My Terraform App Credentials" # Title remains the same
  notes = "NOTE: Credentials UPDATED by Terraform at ${timestamp()}.
Please rotate if necessary." # MODIFIED

  # folder_uid = "[EXISTING_FOLDER_UID]" # Remains the same or as previously set

  login {
    value = "updated_tf_user@example.com" # MODIFIED
  }

  password {
    value = "Str0ngP@sswOrdGeneratedByTF!" # Password remains the same for this example
                                         # Changing this would also update the secret.
  }

  url {
    value = "https://tf-app.example.com"
  }
}

# ... (outputs can remain the same) ...
```{{copy}}

**Instructions for Update:**

1.  Modify the `notes` and `login.value` in `main.tf` for the `secretsmanager_login.new_app_creds` resource as shown. We use `timestamp()` to show the dynamic nature of updates.
2.  Save the `main.tf` file.
3.  Terraform will detect the changes. Review the plan: `terraform plan`{{execute}}
4.  Apply the changes: `terraform apply -auto-approve`{{execute}}
5.  Verify in your Keeper Vault. The record's notes and username should reflect the new values.

**C. Deleting a Record Managed by Terraform**

To delete a record managed by Terraform, you remove its `resource` block from your configuration.

**Instructions for Deletion:**

1.  In `main.tf`, delete or comment out the entire `resource "secretsmanager_login" "new_app_creds" { ... }` block.
2.  Also, remove or comment out any `output` blocks that refer to it (like `output "new_app_creds_uid"`) to avoid errors.
3.  Save `main.tf`.
4.  Terraform will detect the resource is no longer declared. Review the plan: `terraform plan`{{execute}}
5.  Apply to delete the record: `terraform apply -auto-approve`{{execute}}
6.  Verify in Keeper Vault that the "My Terraform App Credentials" record is gone.

This Create, Read (from previous steps), Update, Delete (CRUD) lifecycle is fundamental to managing any resource with Terraform, including your Keeper secrets. 