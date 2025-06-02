# Step 4: Record Updates & File Management (Upload, Download, Delete)

This step covers updating existing records, and comprehensive file management including uploading files to records, downloading them, and deleting them from records using the KSM Python SDK.

## 1. Prepare Your Environment

- Ensure you have a `ksm-config.json` from previous steps (or a valid One-Time Token for initial setup).
- Have the UID of a record you created in a previous step (e.g., from Step 3). This record will be used for updates and file operations.
- Create a sample file for upload if it doesn't exist:

```bash
echo "# Sample Python SDK Configuration File for Upload
app_name=KSM Python Tutorial App
version=1.0.1
created_by=KSM Python SDK - Step 4
timestamp=$(date)" > py-sample-config.txt
```
`echo "# Sample Python SDK Configuration File for Upload
app_name=KSM Python Tutorial App
version=1.0.1
created_by=KSM Python SDK - Step 4
timestamp=$(date)" > py-sample-config.txt`{{execute}}

## 2. Create Script for Updates & File Management

```bash
# You can reuse main.py or create a new file like main_manage_files_updates.py
touch main.py
```
`touch main.py`{{execute}}

## 3. Add Code for Updates and File Operations

Copy and paste this code into your Python script (e.g., `main.py`):

```python
import os
import time
from keeper_secrets_manager_core import SecretsManager
from keeper_secrets_manager_core.storage import FileKeyValueStorage
from keeper_secrets_manager_core.dto.dtos import RecordField, File

# Initialize Secrets Manager (assuming ksm-config.json exists or token is provided for initial setup)
ONE_TIME_TOKEN_STEP4 = os.environ.get("KSM_ONE_TIME_TOKEN_STEP4", "[ONE_TIME_TOKEN_IF_NEEDED]")
CONFIG_FILE_NAME = "ksm-config.json"

# ⚠️ Replace with the UID of a record created in a previous step (e.g., Step 3)
# This record will be used for updates and file operations.
TARGET_RECORD_UID = os.environ.get("KSM_TARGET_RECORD_UID_STEP4", "[UID_OF_RECORD_FROM_PREVIOUS_STEP]")

secrets_manager = SecretsManager(
    token=ONE_TIME_TOKEN_STEP4 if not os.path.exists(CONFIG_FILE_NAME) and ONE_TIME_TOKEN_STEP4 != "[ONE_TIME_TOKEN_IF_NEEDED]" else None,
    config=FileKeyValueStorage(CONFIG_FILE_NAME)
)

UPLOAD_FILE_PATH = './py-sample-config.txt'
DOWNLOAD_DEST_PATH = './downloaded_py_sample_config.txt'

def manage_record_and_files():
    if not TARGET_RECORD_UID or TARGET_RECORD_UID == "[UID_OF_RECORD_FROM_PREVIOUS_STEP]":
        print("❌ TARGET_RECORD_UID placeholder must be replaced with an actual Record UID from a previous step. Aborting.")
        return

    print(f"🚀 Managing record UID: {TARGET_RECORD_UID} and its files...")

    try:
        # --- 1. Retrieve the record to update and attach files to ---
        print(f"\n🔍 Retrieving record UID: {TARGET_RECORD_UID}...")
        # get_secrets() returns a list, even for a single UID
        records = secrets_manager.get_secrets(record_uid=TARGET_RECORD_UID)
        if not records:
            print(f"❌ Record with UID '{TARGET_RECORD_UID}' not found. Please create it first (e.g., run Step 3).")
            return
        record_to_manage = records[0]
        print(f"✅ Found record: '{record_to_manage.title}' (Type: {record_to_manage.type})")

        # --- 2. Update Record Fields (e.g., notes or a custom field) ---
        print(f"\n✏️ Updating record: {record_to_manage.title}...")
        original_notes = record_to_manage.notes
        record_to_manage.notes = (original_notes or "") + f"\nUpdated by Python SDK - Step 4 at {time.ctime()}"
        
        # Example: Add or update a custom field
        found_custom_field = False
        for field in record_to_manage.fields:
            if hasattr(field, 'label') and field.label == "SDK_Update_Status":
                field.value = "Step 4 File Ops Complete"
                found_custom_field = True
                break
        if not found_custom_field:
            status_field = RecordField(field_type="text", label="SDK_Update_Status", value="Step 4 File Ops Initialized")
            record_to_manage.fields.append(status_field)
            
        secrets_manager.update_secret(record_to_manage)
        print(f"✅ Record '{record_to_manage.title}' updated successfully.")
        # Re-fetch to confirm update (optional)
        # record_to_manage = secrets_manager.get_secrets(record_uid=TARGET_RECORD_UID)[0]
        # print(f"Updated notes: {record_to_manage.notes}")

        # --- 3. Upload a File to the Record ---
        print(f"\n📎 Uploading file '{UPLOAD_FILE_PATH}' to record '{record_to_manage.title}'...")
        if os.path.exists(UPLOAD_FILE_PATH):
            # upload_file_path() is a convenient method
            uploaded_file_info = secrets_manager.upload_file_path(record_to_manage, UPLOAD_FILE_PATH)
            print(f"✅ File uploaded successfully: '{uploaded_file_info.name}' (Size: {uploaded_file_info.size} bytes)")
            
            # Refresh record data to see the new file attachment details
            record_to_manage = secrets_manager.get_secrets(record_uid=TARGET_RECORD_UID)[0]
        else:
            print(f"❌ File not found for upload: {UPLOAD_FILE_PATH}")

        # --- 4. Download a File from the Record ---
        if record_to_manage.files:
            file_to_download = record_to_manage.files[0] # Assuming we download the first attached file
            print(f"\n💾 Downloading file '{file_to_download.name}' to '{DOWNLOAD_DEST_PATH}'...")
            
            # download_file takes the record, file name (or UID), and destination path
            secrets_manager.download_file(record_to_manage, file_to_download.name, DOWNLOAD_DEST_PATH)
            print(f"✅ File '{file_to_download.name}' downloaded successfully.")
            if os.path.exists(DOWNLOAD_DEST_PATH):
                print(f"   Downloaded file size: {os.path.getsize(DOWNLOAD_DEST_PATH)} bytes")
        else:
            print("\nℹ️ No files found on the record to download.")

        # --- 5. Delete a File from the Record ---
        if record_to_manage.files:
            file_to_delete_name = record_to_manage.files[0].name # Assuming we delete the first attached file
            print(f"\n🗑️ Deleting file '{file_to_delete_name}' from record '{record_to_manage.title}'...")
            
            # delete_file_from_record takes the record and the name of the file to delete
            secrets_manager.delete_file_from_record(record_to_manage, file_to_delete_name)
            print(f"✅ File '{file_to_delete_name}' deleted successfully from the record.")

            # Refresh record data to see that the file is gone
            record_to_manage = secrets_manager.get_secrets(record_uid=TARGET_RECORD_UID)[0]
            print(f"   Files remaining on record: {len(record_to_manage.files)}")
        else:
            print("\nℹ️ No files found on the record to delete.")

    except Exception as e:
        print(f"❌ An error occurred: {str(e)}")
        print("💡 Common issues:")
        print("   - Invalid or missing KSM configuration (ksm-config.json or token for setup).")
        print(f"   - Incorrect TARGET_RECORD_UID ('{TARGET_RECORD_UID}') or record does not exist.")
        print("   - Insufficient permissions on the record/folder.")
        print(f"   - File '{UPLOAD_FILE_PATH}' not found for upload.")

    print("\n🎉 Record update and file management demo complete.")

if __name__ == '__main__':
    manage_record_and_files()

```{{copy}}

### 4. Configure Required Parameters

-   **`[ONE_TIME_TOKEN_IF_NEEDED]`**: If `ksm-config.json` doesn't exist, replace this (or set `KSM_ONE_TIME_TOKEN_STEP4` env var) for initial setup.
-   **`[UID_OF_RECORD_FROM_PREVIOUS_STEP]`**: **Crucial!** Replace this placeholder (or set `KSM_TARGET_RECORD_UID_STEP4` env var) with the UID of an actual record you created in a previous step (e.g., from Step 3). This record will be modified.

### 5. Run the Script

```bash
python3 main.py # or your chosen filename
```
`python3 main.py`{{execute}}

## Understanding the Code

-   **Record Retrieval (`secrets_manager.get_secrets(record_uid=...)`)**: Fetches the specific record to be managed. It returns a list, so we take the first element.
-   **Record Update (`record_to_manage.notes = ...`, `record_to_manage.fields.append(...)`, `secrets_manager.update_secret(record_object)`)**:
    -   Modify attributes of the fetched record object directly (e.g., `record.notes`, `record.fields`).
    -   To add/update fields, you can append new `RecordField` objects or find and modify existing ones in the `record.fields` list.
    -   Call `secrets_manager.update_secret(record_object)` with the modified record object to save changes back to the Keeper Vault.
-   **File Upload (`secrets_manager.upload_file_path(record, file_path)`)**: 
    -   A convenient method to upload a file from a local path directly to the specified record.
    -   Other methods like `upload_file` (for file-like objects) and `upload_file_bytes` are also available.
-   **File Download (`secrets_manager.download_file(record, file_name_or_uid, destination_path)`)**:
    -   Downloads the specified file (by name or its UID from `record.files[n].uid`) from the record to the given local destination path.
-   **File Deletion (`secrets_manager.delete_file_from_record(record, file_name)`)**:
    -   Removes the specified file attachment from the record.
    -   The SDK handles the necessary API calls to update the record by removing the file reference.

## Next Steps

In the next step, we'll explore Folder Management (creating, listing, updating, deleting folders) and how to delete entire records.
