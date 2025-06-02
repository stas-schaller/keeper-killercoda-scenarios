# Step 5: Folder Management & Record Deletion

This step focuses on managing folders (creating, listing, updating, deleting) and deleting entire records using the KSM Python SDK. Client-side caching, which was also part of the original Step 5, is demonstrated here as well as it's often used with these operations.

## 1. Prepare Your Environment

- Ensure you have a `ksm-config.json` from previous steps (or a valid One-Time Token for initial setup).
- Have the UID of a Shared Folder where your KSM application has **"Can Edit"** permissions. This will be the parent for new folders created by the script.

## 2. Create Script for Folder & Record Management

```bash
# You can reuse main.py or create a new file like main_manage_folders_records.py
touch main.py
```
`touch main.py`{{execute}}

## 3. Add Code for Folder and Record Operations

Copy and paste this code into your Python script (e.g., `main.py`):

```python
import os
import time
from keeper_secrets_manager_core import SecretsManager
from keeper_secrets_manager_core.storage import FileKeyValueStorage
from keeper_secrets_manager_core.options import SecretsManagerOptions
from keeper_secrets_manager_core.cache import InMemoryCache
from keeper_secrets_manager_core.dto.dtos import RecordCreate, RecordField # For creating a test record

# Initialize Secrets Manager (assuming ksm-config.json exists or token is provided for initial setup)
ONE_TIME_TOKEN_STEP5 = os.environ.get("KSM_ONE_TIME_TOKEN_STEP5", "[ONE_TIME_TOKEN_IF_NEEDED]")
CONFIG_FILE_NAME = "ksm-config.json"

# ⚠️ Replace with UID of a Shared Folder with "Can Edit" permissions for your KSM App
# This will serve as the parent for folders created in this demo.
PARENT_SHARED_FOLDER_UID = os.environ.get("KSM_PARENT_FOLDER_UID_STEP5", "[YOUR_PARENT_SHARED_FOLDER_UID_HERE]")

# Setup Caching (optional, but good practice)
app_cache = InMemoryCache()
options = SecretsManagerOptions(
    token=ONE_TIME_TOKEN_STEP5 if not os.path.exists(CONFIG_FILE_NAME) and ONE_TIME_TOKEN_STEP5 != "[ONE_TIME_TOKEN_IF_NEEDED]" else None,
    config=FileKeyValueStorage(CONFIG_FILE_NAME),
    cache=app_cache,
    cache_period=300 # Cache for 5 minutes (300 seconds)
)
secrets_manager = SecretsManager(options=options)

def manage_folders_and_records():
    if not PARENT_SHARED_FOLDER_UID or PARENT_SHARED_FOLDER_UID == "[YOUR_PARENT_SHARED_FOLDER_UID_HERE]":
        print("❌ PARENT_SHARED_FOLDER_UID placeholder must be replaced. Aborting.")
        return

    print(f"🚀 Managing folders under parent UID: {PARENT_SHARED_FOLDER_UID} and deleting records...")
    new_folder_uid = None
    test_record_uid_in_folder = None

    try:
        # --- 1. Folder Management ---
        print("\n--- Folder Management Operations ---")

        # a. Create a new folder
        new_folder_name = f"PythonSDK_DemoFolder_{int(time.time())}"
        print(f"📁 Creating folder: '{new_folder_name}' under parent UID: {PARENT_SHARED_FOLDER_UID}")
        # create_folder takes folder_name and optional parent_uid (which is the shared folder UID here)
        # or the UID of another folder you created if nesting.
        created_folder_details = secrets_manager.create_folder(folder_name=new_folder_name, parent_uid=PARENT_SHARED_FOLDER_UID)
        new_folder_uid = created_folder_details.get('folder_uid')
        if not new_folder_uid:
            raise Exception(f"Failed to create folder. Response: {created_folder_details}")
        print(f"✅ Folder '{new_folder_name}' created successfully! UID: {new_folder_uid}")

        # b. List all folders (within the application's scope)
        print("\n--- Listing Folders ---")
        # get_folders_all() is a convenience method for all folders, or use get_folders() for more control
        all_folders = secrets_manager.get_folders_all()
        print(f"🔍 Found {len(all_folders)} folder(s) in total:")
        for folder in all_folders:
            print(f"  - Name: {folder.name}, UID: {folder.uid}, Parent UID: {folder.parent_uid or 'N/A'}")
        
        # c. Update (rename) the created folder
        updated_folder_name = new_folder_name + "_Renamed"
        print(f"\n✏️ Renaming folder '{new_folder_name}' (UID: {new_folder_uid}) to '{updated_folder_name}'")
        secrets_manager.update_folder(folder_uid=new_folder_uid, folder_name=updated_folder_name)
        print(f"✅ Folder {new_folder_uid} renamed successfully to '{updated_folder_name}'.")

        # --- 2. Create a Record in the New Folder (for deletion test) ---
        print("\n--- Creating a Test Record in the New Folder ---")
        test_record_data = RecordCreate(record_type='login', title="PythonSDK_ToDelete_InFolder")
        test_record_data.fields = [RecordField(field_type='login', value='delete_me_py@example.com')]
        
        print(f"Creating record in folder '{updated_folder_name}' (UID: {new_folder_uid})")
        test_record_uid_in_folder = secrets_manager.create_secret(folder_uid=new_folder_uid, record=test_record_data)
        print(f"✅ Test record created in folder. UID: {test_record_uid_in_folder}")

        # --- 3. Delete the Test Record ---
        print(f"\n--- Deleting Test Record (UID: {test_record_uid_in_folder}) ---")
        delete_result = secrets_manager.delete_secrets([test_record_uid_in_folder])
        if delete_result and delete_result[0].get('status') == 'success':
            print(f"✅ Record {test_record_uid_in_folder} deleted successfully.")
        else:
            print(f"⚠️ Record {test_record_uid_in_folder} deletion may have failed. Response: {delete_result}")
        test_record_uid_in_folder = None # Mark as deleted

    except Exception as e:
        print(f"❌ An error occurred during folder/record operations: {str(e)}")
    finally:
        # --- 4. Delete the Created Folder (Cleanup) ---
        if new_folder_uid:
            print(f"\n--- Deleting Folder '{updated_folder_name if updated_folder_name else new_folder_name}' (UID: {new_folder_uid}) ---")
            try:
                # Note: delete_folder might require the folder to be empty depending on backend rules.
                # The Python SDK does not have a direct 'force' parameter for delete_folder.
                # Ensure records within are deleted first if necessary.
                secrets_manager.delete_folder(new_folder_uid)
                print(f"✅ Folder {new_folder_uid} deleted successfully.")
            except Exception as e_del_folder:
                print(f"❌ Error deleting folder {new_folder_uid}: {str(e_del_folder)}")
                print("   (Folder might need to be empty, or there might be permission issues.)")

    print("\n🎉 Folder management and record deletion demo complete.")

if __name__ == '__main__':
    manage_folders_and_records()

```{{copy}}

### 4. Configure Required Parameters

-   **`[ONE_TIME_TOKEN_IF_NEEDED]`**: If `ksm-config.json` doesn't exist, replace this (or set `KSM_ONE_TIME_TOKEN_STEP5` env var) for initial setup.
-   **`[YOUR_PARENT_SHARED_FOLDER_UID_HERE]`**: **Crucial!** Replace this placeholder (or set `KSM_PARENT_FOLDER_UID_STEP5` env var) with the UID of a Shared Folder in your Keeper Vault where your KSM Application has **"Can Edit"** permissions. This folder will act as the parent for the new folder created in this script.

### 5. Run the Script

```bash
python3 main.py # or your chosen filename
```
`python3 main.py`{{execute}}

## Understanding the Code

-   **Caching (`InMemoryCache`, `SecretsManagerOptions`)**: 
    -   An `InMemoryCache` is instantiated.
    -   `SecretsManagerOptions` is used to pass the `cache` object and `cache_period` (in seconds) to the `SecretsManager`.
-   **Folder Creation (`secrets_manager.create_folder`)**: 
    -   Takes `folder_name` and an optional `parent_uid`.
    -   `parent_uid` is the UID of the shared folder context or another folder UID if nesting.
-   **Listing Folders (`secrets_manager.get_folders_all()`)**: Retrieves all folders accessible by the KSM application.
-   **Updating Folders (`secrets_manager.update_folder`)**: Takes `folder_uid` and the new `folder_name` to rename it.
-   **Record Deletion (`secrets_manager.delete_secrets([list_of_uids])`)**: Deletes one or more records given their UIDs.
-   **Folder Deletion (`secrets_manager.delete_folder(folder_uid)`)**: Deletes the specified folder. Note: The folder might need to be empty first for successful deletion, depending on Keeper's backend rules and SDK behavior (the Python SDK does not expose a direct "force delete" flag for non-empty folders).

## Conclusion

This step demonstrated how to manage the lifecycle of folders and records, including creation, listing, updating, and deletion, using the KSM Python SDK, along with setting up client-side caching for improved performance.

This completes the KSM Python SDK tutorial! Please review the `finish.md` tab for a summary of what you've learned and important next steps.