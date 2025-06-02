# Step 4: Record Updates & File Management

This step covers updating existing records, and comprehensive file management including uploading files to records, downloading them, and deleting them from records using the KSM Java SDK.

## 1. Prepare Your Environment

-   Ensure you have a working `ksm-config.json`.
-   You will need the UID of an existing record (e.g., created in Step 3) where your KSM application has **"Can Edit"** permission.
-   Create a sample file in your project directory to upload, e.g., `sample-java-attachment.txt`.

```bash
echo "This is a sample file for KSM Java SDK attachment testing - V1." > sample-java-attachment.txt
ls -l sample-java-attachment.txt
```
`echo "This is a sample file for KSM Java SDK attachment testing - V1." > sample-java-attachment.txt && ls -l sample-java-attachment.txt`{{execute}}

## 2. Create/Modify Java Class: ManageRecordAndFiles

Ensure you have a Java class for these operations (e.g., `ManageRecordAndFiles.java`).

```bash
# Example: touch src/main/java/com/keepersecurity/ksmsdk/javatutorial/ManageRecordAndFiles.java
# Ensure your package structure matches.
```
`# For this tutorial, we assume you are modifying an existing class or creating one with this name.`{{execute}}

### Add/Modify the Java Code

Update your Java file with the following code. It demonstrates record updates, file upload, download, and deletion.

```java
package com.keepersecurity.ksmsdk.javatutorial;

import com.keepersecurity.secretsManager.core.*;
import static com.keepersecurity.secretsManager.core.SecretsManager.initializeStorage;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.Date;

public class ManageRecordAndFiles {

    private static final String ONE_TIME_TOKEN = "[ONE_TIME_TOKEN_IF_NEEDED]";
    private static final String CONFIG_FILE_NAME = "ksm-config.json";

    // ⚠️ Replace with the UID of a record created in a previous step (e.g., Step 3)
    private static final String TARGET_RECORD_UID = "[YOUR_RECORD_UID_FOR_OPERATIONS]";
    private static final String SAMPLE_FILE_TO_UPLOAD = "sample-java-attachment.txt";
    private static final String DOWNLOADED_FILE_NAME = "downloaded-java-sample.txt";

    public static void main(String[] args) {
        System.out.println("🚀 Updating records and managing file attachments...");
        LocalConfigStorage storage = new LocalConfigStorage(CONFIG_FILE_NAME);
        SecretsManagerOptions options = null;

        try {
            if (!new File(CONFIG_FILE_NAME).exists() || (ONE_TIME_TOKEN != null && !ONE_TIME_TOKEN.startsWith("["))) {
                System.out.println("🔑 Initializing KSM storage...");
                initializeStorage(storage, ONE_TIME_TOKEN);
            }
            options = new SecretsManagerOptions(storage);

            // --- 1. Retrieve the Record ---
            System.out.println("\n--- Retrieving Record for Operations ---");
            KeeperSecrets secrets = SecretsManager.getSecrets(options, List.of(TARGET_RECORD_UID));
            KeeperRecord recordToManage = secrets.getRecordByUid(TARGET_RECORD_UID);

            if (recordToManage == null) {
                System.err.println("❌ Error: Target record UID '" + TARGET_RECORD_UID + "' not found. Please create it first.");
                return;
            }
            System.out.println("✅ Found record: '" + recordToManage.getTitle() + "' (UID: " + recordToManage.getRecordUid() + ")");

            // --- 2. Update Record Fields ---
            System.out.println("\n--- Updating Record Fields ---");
            // Modify existing notes
            String originalNotes = recordToManage.getNotes() != null ? recordToManage.getNotes() : "";
            recordToManage.setNotes(originalNotes + "\nUpdated by Java SDK at " + new Date().toString());

            // Add or update a custom field
            boolean customFieldUpdated = false;
            for (KeeperRecordField field : recordToManage.getCustom()) {
                if (field instanceof Text && "SDK_Status".equals(((Text) field).getLabel())) {
                    ((Text) field).getValue().set(0, "File Ops In Progress"); // Assuming single value text field
                    customFieldUpdated = true;
                    break;
                }
            }
            if (!customFieldUpdated) {
                recordToManage.getCustom().add(new Text("SDK_Status", "SDK Operation Status", new ArrayList<>(List.of("Initial Update"))));
            }
            
            SecretsManager.updateSecret(options, recordToManage); // Save changes
            System.out.println("✅ Record fields updated successfully.");
            // Re-fetch to confirm (optional)
            // recordToManage = SecretsManager.getSecrets(options, List.of(TARGET_RECORD_UID)).getRecordByUid(TARGET_RECORD_UID);
            // System.out.println("    New Notes: " + recordToManage.getNotes());

            // --- 3. Upload a File ---
            System.out.println("\n--- Uploading File ---");
            File fileToUploadObj = new File(SAMPLE_FILE_TO_UPLOAD);
            if (!fileToUploadObj.exists()) {
                System.err.println("❌ Error: Sample file '" + SAMPLE_FILE_TO_UPLOAD + "' not found.");
                return;
            }
            KeeperFileUpload fileUploadData = new KeeperFileUpload(
                    fileToUploadObj.getName(), "SDK Upload - " + fileToUploadObj.getName(),
                    Files.probeContentType(fileToUploadObj.toPath()), Files.readAllBytes(fileToUploadObj.toPath()));
            System.out.println("📎 Uploading '" + fileUploadData.getName() + "' to record UID: " + recordToManage.getRecordUid());
            SecretsManager.uploadFile(options, recordToManage, fileUploadData);
            System.out.println("✅ File uploaded successfully!");
            recordToManage = SecretsManager.getSecrets(options, List.of(TARGET_RECORD_UID)).getRecordByUid(TARGET_RECORD_UID); // Refresh record

            // --- 4. Download a File ---
            System.out.println("\n--- Downloading File ---");
            if (recordToManage.getFiles() != null && !recordToManage.getFiles().isEmpty()) {
                KeeperFile fileToDownload = recordToManage.getFiles().get(0); // Download the first file
                System.out.println("📥 Downloading file: '" + fileToDownload.getData().getTitle() + "' (UID: " + fileToDownload.getFileUid() + ")");
                byte[] downloadedBytes = SecretsManager.downloadFile(options, fileToDownload);
                try (FileOutputStream fos = new FileOutputStream(DOWNLOADED_FILE_NAME)) {
                    fos.write(downloadedBytes);
                    System.out.println("✅ File downloaded to: " + DOWNLOADED_FILE_NAME + " (Size: " + downloadedBytes.length + " bytes)");
                } catch (IOException e) {
                    System.err.println("❌ Error saving downloaded file: " + e.getMessage());
                }
            } else {
                System.out.println("ℹ️ No files on record to download.");
            }

            // --- 5. Delete a File from the Record ---
            System.out.println("\n--- Deleting File from Record ---");
             if (recordToManage.getFiles() != null && !recordToManage.getFiles().isEmpty()) {
                KeeperFile fileToDelete = recordToManage.getFiles().get(0); // Delete the first file for this example
                System.out.println("🗑️ Attempting to delete file: '" + fileToDelete.getData().getTitle() + "' (UID: " + fileToDelete.getFileUid() + ")");
                SecretsManager.deleteFile(options, recordToManage.getRecordUid(), fileToDelete.getFileUid());
                System.out.println("✅ File deletion request sent for UID: " + fileToDelete.getFileUid());
                // Re-fetch record to verify
                recordToManage = SecretsManager.getSecrets(options, List.of(TARGET_RECORD_UID)).getRecordByUid(TARGET_RECORD_UID);
                System.out.println("    Files remaining on record: " + (recordToManage.getFiles() != null ? recordToManage.getFiles().size() : 0));
            } else {
                System.out.println("ℹ️ No files on record to delete.");
            }

            System.out.println("\n🎉 Record update and file management operations complete.");

        } catch (Exception e) {
            System.err.println("❌ Error during operations: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
```{{copy}}

## 3. Configure Target Record UID

-   In your Java file (e.g., `ManageRecordAndFiles.java`):
    -   **Crucial**: Replace `[YOUR_RECORD_UID_FOR_OPERATIONS]` with the UID of an existing record (e.g., one created in Step 3) where your KSM application has **"Can Edit"** permissions.
    -   If needed, update `[ONE_TIME_TOKEN_IF_NEEDED]` for initial `ksm-config.json` setup.

## 4. Run the Application

Ensure your `build.gradle` is configured to run the correct main class (e.g., `com.keepersecurity.ksmsdk.javatutorial.ManageRecordAndFiles`).

```bash
gradle -PmainClass=com.keepersecurity.ksmsdk.javatutorial.ManageRecordAndFiles run --console=plain
```
`gradle -PmainClass=com.keepersecurity.ksmsdk.javatutorial.ManageRecordAndFiles run --console=plain`{{execute}}

### Expected Output:

```
🚀 Updating records and managing file attachments...

--- Retrieving Record for Operations ---
✅ Found record: 'My Secure Login - Java SDK' (UID: YOUR_RECORD_UID_FOR_OPERATIONS)

--- Updating Record Fields ---
✅ Record fields updated successfully.

--- Uploading File ---
📎 Uploading 'sample-java-attachment.txt' to record UID: YOUR_RECORD_UID_FOR_OPERATIONS
✅ File uploaded successfully!

--- Downloading File ---
📥 Downloading file: 'SDK Upload - sample-java-attachment.txt' (UID: ...)
✅ File downloaded to: downloaded-java-sample.txt (Size: ... bytes)

--- Deleting File from Record ---
🗑️ Attempting to delete file: 'SDK Upload - sample-java-attachment.txt' (UID: ...)
✅ File deletion request sent for UID: ...
    Files remaining on record: 0

🎉 Record update and file management operations complete.
```

**Verify**: 
- Check the target record in your Keeper Vault; its notes/custom fields should be updated, and the file should have been attached and then removed.
- Check your project directory for `downloaded-java-sample.txt`.

## Understanding the Code

-   **Record Update (`record.setNotes()`, `record.getCustom().add()`, `SecretsManager.updateSecret()`)**:
    -   First, retrieve the `KeeperRecord` object.
    -   Modify its properties directly (e.g., `setNotes()`, or get a list of fields like `getCustom()` and add/modify `KeeperRecordField` objects within it).
    -   Call `SecretsManager.updateSecret(options, recordToUpdate)` to persist the changes.
-   **File Upload (`SecretsManager.uploadFile()`)**: As covered previously, uploads a `KeeperFileUpload` object to a `KeeperRecord`.
-   **File Download (`SecretsManager.downloadFile()`)**: Downloads a `KeeperFile` and returns its content as `byte[]`.
-   **File Deletion (`SecretsManager.deleteFile(options, recordUid, fileUid)`)**: Deletes a specific file from a record, identified by the record's UID and the file's UID.

## Next Steps

In the final step, we will focus on Folder Management (creating, listing, updating, deleting folders) and deleting entire records.