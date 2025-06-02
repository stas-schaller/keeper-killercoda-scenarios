### Step 4: Updating Records, File Management & Record Deletion

This step demonstrates how to update existing records, manage file attachments (upload, download, delete), and delete entire records.

### 1. Prepare Test Record and Sample File

- Ensure you have a record from previous steps (e.g., one created in Step 2). You'll need its UID.
- Create a sample file named `sample-upload.txt` in your `ksm-sample-js` directory.

```bash
echo "This is a sample file for KSM JavaScript SDK upload." > sample-upload.txt
```
`echo "This is a sample file for KSM JavaScript SDK upload." > sample-upload.txt`{{execute}}

### 2. Create Script: `manage_record_advanced.js`

<pre class="file" data-filename="manage_record_advanced.js" data-target="replace">
const {
    initializeStorage,
    localConfigStorage,
    getSecrets,
    updateSecret,
    uploadFile,
    downloadFile,
    deleteSecret,
    KeeperFileUpload, // Type for file upload data
    KeeperRecord,      // Type for record object
    KeeperFile         // Type for file object
} = require("@keeper-security/secrets-manager-core");
const fs = require('fs').promises;
const path = require('path');

const ONE_TIME_TOKEN = "[ONE_TIME_TOKEN_IF_NEEDED]";
const CONFIG_FILE_NAME = "myksmconfig.json";
// UID of a record to update, attach files to, and then delete
const TARGET_RECORD_UID = "[UID_OF_RECORD_TO_MANAGE]"; 
const UPLOAD_FILE_NAME = 'sample-upload.txt';
const DOWNLOADED_FILE_NAME = 'downloaded-via-sdk.txt';

// Utility function to fetch a single record by UID
async function getRecordByUid(options, uid) {
    const { records } = await getSecrets(options, [uid]);
    if (!records || records.length === 0) {
        console.warn(`Record with UID '${uid}' not found.`);
        return null;
    }
    return records[0];
}

async function advancedRecordManagement() {
    const storage = localConfigStorage(CONFIG_FILE_NAME);
    try {
        await initializeStorage(storage, ONE_TIME_TOKEN);
        console.log("KSM storage initialized or configuration loaded.");
    } catch (e) {
        console.log("Proceeding with existing configuration or valid token.");
    }
    const options = { storage: storage };

    let ownerRecord = await getRecordByUid(options, TARGET_RECORD_UID);
    if (!ownerRecord) return;

    // --- 1. Update Record Fields ---
    console.log(`\n--- Updating record: ${TARGET_RECORD_UID} ---`);
    try {
        // Modify a standard field (e.g., a new custom field or update notes)
        if (!ownerRecord.data.custom) ownerRecord.data.custom = [];
        let sdkStatusField = ownerRecord.data.custom.find(f => f.label === "SDK_File_Test_Status");
        if (sdkStatusField) {
            sdkStatusField.value = ["Updated: " + new Date().toISOString()];
        } else {
            ownerRecord.data.custom.push({ 
                label: "SDK_File_Test_Status", 
                type: "text", 
                value: ["Initial Update: " + new Date().toISOString()]
            });
        }
        ownerRecord.data.notes = (ownerRecord.data.notes || "") + "\nFile operations tested via JS SDK at " + new Date().toLocaleString();

        await updateSecret(options, ownerRecord);
        console.log(`Record ${TARGET_RECORD_UID} updated successfully.`);
        
        // Re-fetch to get the latest revision number and data
        ownerRecord = await getRecordByUid(options, TARGET_RECORD_UID);
        if (!ownerRecord) { 
            console.error("Record disappeared after update, aborting further steps."); 
            return; 
        }
        console.log("Updated record notes:", ownerRecord.data.notes);

    } catch (e) {
        console.error(`Error updating record: ${e.message}`, e.stack);
    }

    let uploadedFileUid = null;
    // --- 2. Upload File to Record ---
    console.log(`\n--- Uploading file to record: ${TARGET_RECORD_UID} ---`);
    try {
        const fileContentBuffer = await fs.readFile(UPLOAD_FILE_NAME);
        const fileName = path.basename(UPLOAD_FILE_NAME);

        const fileUploadData = {
            name: fileName,
            title: `JS SDK Upload - ${fileName}`,
            type: 'text/plain', // Or use a library to determine mime type
            data: fileContentBuffer // SDK expects Uint8Array (Buffer in Node.js is a subclass of Uint8Array)
        };
        
        // uploadFile expects the full ownerRecord object
        uploadedFileUid = await uploadFile(options, ownerRecord, fileUploadData);
        console.log(`File '${fileName}' uploaded successfully to record ${TARGET_RECORD_UID}. New File UID: ${uploadedFileUid}`);

        // Re-fetch record to get updated file list and revision
        ownerRecord = await getRecordByUid(options, TARGET_RECORD_UID);
         if (!ownerRecord) { 
            console.error("Record disappeared after file upload, aborting further steps."); 
            return; 
        }

    } catch (e) {
        console.error(`Error uploading file: ${e.message}`, e.stack);
    }

    // --- 3. Download File from Record ---
    if (ownerRecord && ownerRecord.files && ownerRecord.files.length > 0) {
        console.log(`\n--- Downloading file from record: ${TARGET_RECORD_UID} ---`);
        try {
            // Attempt to download the first file found on the record
            // In a real scenario, you might find a file by its UID or name (title) if known
            const fileToDownload = ownerRecord.files.find(f => f.fileUid === uploadedFileUid || f.data.name === UPLOAD_FILE_NAME);

            if (fileToDownload) {
                console.log(`Attempting to download file: ${fileToDownload.data.name} (UID: ${fileToDownload.fileUid})`);
                const downloadedFileContent = await downloadFile(fileToDownload); // downloadFile takes the KeeperFile object
                await fs.writeFile(DOWNLOADED_FILE_NAME, downloadedFileContent);
                console.log(`File '${fileToDownload.data.name}' downloaded successfully as '${DOWNLOADED_FILE_NAME}'.`);
            } else {
                console.log(`File '${UPLOAD_FILE_NAME}' or with UID '${uploadedFileUid}' not found on record for download.`);
            }
        } catch (e) {
            console.error(`Error downloading file: ${e.message}`, e.stack);
        }
    }

    // --- 4. Delete File from Record (by modifying fileRef field) ---
    if (ownerRecord && uploadedFileUid) {
        console.log(`\n--- Deleting file (UID: ${uploadedFileUid}) from record: ${TARGET_RECORD_UID} ---`);
        try {
            const fileRefField = ownerRecord.data.fields.find(f => f.type === 'fileRef');
            if (fileRefField && fileRefField.value) {
                const initialFileCount = fileRefField.value.length;
                fileRefField.value = fileRefField.value.filter(uid => uid !== uploadedFileUid);
                if (fileRefField.value.length < initialFileCount) {
                    await updateSecret(options, ownerRecord);
                    console.log(`File reference ${uploadedFileUid} removed from record ${TARGET_RECORD_UID} and record updated.`);
                     // Re-fetch record to confirm
                    ownerRecord = await getRecordByUid(options, TARGET_RECORD_UID);
                    if (ownerRecord) {
                         const updatedFileRefField = ownerRecord.data.fields.find(f => f.type === 'fileRef');
                         const currentFileRefs = updatedFileRefField ? updatedFileRefField.value : [];
                         console.log("Current file references on record:", currentFileRefs);
                    }
                } else {
                    console.log(`File UID ${uploadedFileUid} not found in fileRef field.`);
                }
            } else {
                console.log(`No fileRef field found on record or it is empty.`);
            }
        } catch (e) {
            console.error(`Error deleting file from record: ${e.message}`, e.stack);
        }
    }

    // --- 5. Delete Entire Record ---
    console.log(`\n--- Deleting record: ${TARGET_RECORD_UID} ---`);
    try {
        const deleteResult = await deleteSecret(options, [TARGET_RECORD_UID]);
        if (deleteResult.records && deleteResult.records.length > 0 && deleteResult.records[0].recordUid === TARGET_RECORD_UID && deleteResult.records[0].responseCode === 'success') {
            console.log(`Record ${TARGET_RECORD_UID} deleted successfully.`);
        } else {
            console.error(`Failed to delete record ${TARGET_RECORD_UID}. Response:`, deleteResult);
        }
    } catch (e) {
        console.error(`Error deleting record: ${e.message}`, e.stack);
    }
}

advancedRecordManagement().catch(error => {
    console.error("An critical error occurred in advancedRecordManagement:", error);
});
</pre>

### 3. Configure Placeholders

- In `manage_record_advanced.js`:
    - Replace `[ONE_TIME_TOKEN_IF_NEEDED]`.
    - Replace `[UID_OF_RECORD_TO_MANAGE]` with the UID of an existing record you want to modify, attach files to, and ultimately delete.

### 4. Execute the Script

`node manage_record_advanced.js`{{execute}}

This script will:
1. Update fields of the specified record.
2. Upload `sample-upload.txt` to it.
3. Download the uploaded file back.
4. Attempt to remove the file reference from the record.
5. Delete the entire record.

Verify the changes in your Keeper Vault (especially the deletion at the end).