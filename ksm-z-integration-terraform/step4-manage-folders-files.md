### Step 4: Managing Folders & File Attachments

This step covers organizing your secrets by managing folders and handling file attachments within records using Terraform.

**A. Creating and Managing Folders**

Folders help organize secrets within Keeper. Listing folders was covered in Step 2 (Data Sources). Here, we focus on creating and managing them as resources.

```terraform
# Ensure provider configuration is present from previous steps.

# You can get potential parent folder UIDs from Step 2, Part C (Listing Folders)
resource "secretsmanager_folder" "my_tf_project_folder" {
  name = "Terraform Project - ${timestamp()}" # Unique name using timestamp
  
  # Replace with a valid parent_uid from your Keeper Vault where your app has rights.
  # This could be the UID of a Shared Folder your KSM app is associated with,
  # or a subfolder UID within that context.
  parent_uid = "[UID_OF_PARENT_SHARED_FOLDER]"
  
  # force_delete = true # Set to true to allow deletion of non-empty folders. Use with caution.
}

output "new_project_folder_uid" {
  description = "UID of the newly created project folder."
  value       = secretsmanager_folder.my_tf_project_folder.uid
}

output "new_project_folder_name" {
  description = "Name of the newly created project folder."
  value       = secretsmanager_folder.my_tf_project_folder.name
}
```{{copy}}

**Instructions for Creating a Folder:**

1.  **Crucial**: Replace `[UID_OF_PARENT_SHARED_FOLDER]` with an actual `folder_uid` from your Keeper Vault. This should typically be the UID of the Shared Folder your KSM application has permissions to, or a subfolder within it. You can get this from the `data "secretsmanager_folders"` output shown in Step 2.
2.  Add the `resource "secretsmanager_folder"` block to your `main.tf`.
3.  Initialize and apply: `terraform init && terraform apply -auto-approve`{{execute}}
4.  Verify in your Keeper Vault: The new folder should appear under the parent folder you specified.

To **update** a folder (e.g., rename it), simply change the `name` attribute in the resource block and re-apply. Terraform will plan an update.

To **delete** a folder, remove its `resource "secretsmanager_folder"` block from `main.tf` and apply. Note the `force_delete` attribute if you need to delete non-empty folders (use with extreme caution).

**B. Managing File Attachments**

The KSM Terraform provider can upload files and attach them to records.

**1. Create a local sample file for upload:**

In your Katacoda terminal (or local machine), create a dummy file:
`echo "This is a sensitive API key for deployment: $(openssl rand -hex 16)" > api_key.txt`{{execute}}

**2. Update `main.tf` to upload the file and attach it to a new record:**

```terraform
# Ensure provider configuration is present.

# Resource to upload the local file to Keeper
resource "secretsmanager_file" "api_key_file_resource" {
  title      = "API Key File for My TF App (${timestamp()})"
  file_name  = "uploaded_api_key.txt" # Name of the file as it will appear in Keeper
  file_path  = "api_key.txt"          # Path to the local file to upload
}

# Resource for a new login record that will use the uploaded file
resource "secretsmanager_login" "record_with_api_key_file" {
  title = "Service Account with API Key File (${timestamp()})"
  notes = "This record has an API key file attached, managed by Terraform."
  
  # Optionally, place this record in the folder created above
  folder_uid = secretsmanager_folder.my_tf_project_folder.uid

  login {
    value = "service-user-with-file@example.com"
  }

  password {
    value = "Sup3rS3cureP@sswordForFileUser!"
  }

  # Attaching the uploaded file using its resource ID
  file_ref {
    # The 'value' here is a list of blocks, each containing a file UID.
    value = [
      {
        uid = resource.secretsmanager_file.api_key_file_resource.id
      }
    ]
    # You can add more file UIDs here if attaching multiple files.
  }
}

output "api_key_file_resource_uid" {
  description = "UID of the uploaded file resource itself."
  value       = resource.secretsmanager_file.api_key_file_resource.id
}

output "record_with_api_key_file_uid" {
  description = "UID of the record with the file attachment."
  value       = resource.secretsmanager_login.record_with_api_key_file.id
}

output "record_with_api_key_file_attachment_ref" {
  description = "Details of the file attachment reference on the record."
  value       = resource.secretsmanager_login.record_with_api_key_file.file_ref[0].value[0]
  sensitive   = true
}
```{{copy}}

**Instructions for File Management:**

1.  Ensure you have created `api_key.txt` locally using the command above.
2.  Add the `resource "secretsmanager_file"` and the `resource "secretsmanager_login" "record_with_api_key_file"` blocks to your `main.tf`.
3.  If you created the folder in Part A, you can use its UID for `folder_uid` in the record (as shown with `secretsmanager_folder.my_tf_project_folder.uid`). Otherwise, provide a valid folder UID or remove the line.
4.  Initialize and apply: `terraform init && terraform apply -auto-approve`{{execute}}
5.  Verify in your Keeper Vault: A new record should exist, containing the uploaded file.

**Detaching or Deleting Files:**

-   **Detaching a file from a record**: Remove the corresponding `uid` from the `file_ref.value` list within the record resource and apply. The file resource itself remains in Keeper if not deleted separately.
-   **Deleting a file from Keeper**: Remove the `resource "secretsmanager_file" "api_key_file_resource"` block and apply. If the file is still referenced by other records (even those not managed by this Terraform config), Keeper's policies will determine behavior (e.g., it might prevent deletion or orphan the reference).

This step showed how to organize secrets with folders and enrich records with file attachments, all managed through Terraform. 