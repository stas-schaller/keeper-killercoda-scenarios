# Step 4: File Attachments & Management

Keeper Secrets Manager allows you to securely store and manage file attachments associated with your records. This step covers uploading, downloading, and listing file attachments using the KSM Java SDK.

## 1. Prepare Your Environment

-   Ensure you have a working `ksm-config.json`.
-   You will need the UID of an existing record where your KSM application has **"Can Edit"** permission (to upload files) and **"Can View"** permission (to download/list files).
-   Create a sample file in your project directory to upload, e.g., `sample-attachment.txt`.

```bash
echo "This is a sample file for KSM Java SDK attachment testing." > sample-attachment.txt
ls -l sample-attachment.txt
```
`echo "This is a sample file for KSM Java SDK attachment testing." > sample-attachment.txt && ls -l sample-attachment.txt`{{execute}}

## 2. Create Java Class: ManageFileAttachments

```bash
touch src/main/java/com/keepersecurity/ksmsdk/javatutorial/ManageFileAttachments.java
```
`touch src/main/java/com/keepersecurity/ksmsdk/javatutorial/ManageFileAttachments.java`{{execute}}

### Add the Java Code

Paste the following code into `src/main/java/com/keepersecurity/ksmsdk/javatutorial/ManageFileAttachments.java`:

```java
package com.keepersecurity.ksmsdk.javatutorial;

import com.keepersecurity.secretsManager.core.*;
import static com.keepersecurity.secretsManager.core.SecretsManager.initializeStorage;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.List;

public class ManageFileAttachments {

    private static final String ONE_TIME_TOKEN = "[ONE_TIME_TOKEN_IF_NEEDED]";
    private static final String CONFIG_FILE_NAME = "ksm-config.json";

    // ⚠️ Replace with the UID of a record where your KSM App has edit & view permissions
    private static final String TARGET_RECORD_UID_FOR_FILES = "[YOUR_RECORD_UID_FOR_FILES]";
    private static final String SAMPLE_FILE_TO_UPLOAD = "sample-attachment.txt";
    private static final String DOWNLOADED_FILE_NAME = "downloaded-sample.txt";

    public static void main(String[] args) {
        System.out.println("🚀 Managing file attachments...");
        LocalConfigStorage storage = new LocalConfigStorage(CONFIG_FILE_NAME);

        try {
            if (!new File(CONFIG_FILE_NAME).exists() || !ONE_TIME_TOKEN.startsWith("[")) {
                System.out.println("🔑 Initializing KSM storage...");
                initializeStorage(storage, ONE_TIME_TOKEN);
            }
            SecretsManagerOptions options = new SecretsManagerOptions(storage);

            // --- 1. Upload a File to the Record ---
            System.out.println("\n--- Uploading File ---");
            File fileToUpload = new File(SAMPLE_FILE_TO_UPLOAD);
            if (!fileToUpload.exists()) {
                System.err.println("❌ Error: Sample file '" + SAMPLE_FILE_TO_UPLOAD + "' not found. Please create it.");
                return;
            }

            // To upload, first get the target record
            // We fetch only the specific record to ensure we have the latest version/details
            KeeperSecrets secretsForUpload = SecretsManager.getSecrets(options, List.of(TARGET_RECORD_UID_FOR_FILES));
            KeeperRecord recordForUpload = secretsForUpload.getRecordByUid(TARGET_RECORD_UID_FOR_FILES);

            if (recordForUpload == null) {
                System.err.println("❌ Error: Target record UID '" + TARGET_RECORD_UID_FOR_FILES + "' not found for upload.");
                return;
            }

            // Create KeeperFileUpload object
            // Title is how it appears in Keeper, Name is the actual filename
            KeeperFileUpload fileUploadData = new KeeperFileUpload(
                    fileToUpload.getName(), // name (actual filename)
                    "SDK Uploaded - " + fileToUpload.getName(), // title (display name in Keeper)
                    Files.probeContentType(fileToUpload.toPath()), // type (optional, attempts to detect MIME type)
                    Files.readAllBytes(fileToUpload.toPath()) // data
            );

            System.out.println("📎 Uploading '" + fileUploadData.getName() + "' with title '" + fileUploadData.getTitle() + "' to record UID: " + recordForUpload.getRecordUid());
            SecretsManager.uploadFile(options, recordForUpload, fileUploadData);
            System.out.println("✅ File uploaded successfully!");

            // --- 2. List Files for the Record ---
            System.out.println("\n--- Listing Files for Record ---");
            // Re-fetch the record to see the newly uploaded file and other existing files
            KeeperSecrets secretsForListing = SecretsManager.getSecrets(options, List.of(TARGET_RECORD_UID_FOR_FILES));
            KeeperRecord recordForListing = secretsForListing.getRecordByUid(TARGET_RECORD_UID_FOR_FILES);

            if (recordForListing != null && recordForListing.getFiles() != null && !recordForListing.getFiles().isEmpty()) {
                System.out.println("📄 Files attached to record '" + recordForListing.getTitle() + "' (UID: " + recordForListing.getRecordUid() + "):");
                for (KeeperFile kf : recordForListing.getFiles()) {
                    KeeperFileData fileData = kf.getData(); // KeeperFileData holds name, title, size, etc.
                    System.out.printf("    - Title: %s (Name: %s, UID: %s, Size: %d bytes, Type: %s)%n",
                            fileData.getTitle(), fileData.getName(), kf.getFileUid(), fileData.getSize(), fileData.getType());
                }
            } else {
                System.out.println("ℹ️ No files found for record UID: " + (recordForListing != null ? recordForListing.getRecordUid() : TARGET_RECORD_UID_FOR_FILES));
            }

            // --- 3. Download a File from the Record ---
            System.out.println("\n--- Downloading File ---");
            if (recordForListing != null && recordForListing.getFiles() != null && !recordForListing.getFiles().isEmpty()) {
                // For this example, let's try to download the file we just uploaded by its title.
                // In a real scenario, you might know the file UID or iterate to find the specific file.
                String uploadedFileTitle = "SDK Uploaded - " + SAMPLE_FILE_TO_UPLOAD;
                KeeperFile fileToDownload = null;
                for(KeeperFile kf : recordForListing.getFiles()){
                    if(kf.getData().getTitle().equals(uploadedFileTitle)){
                        fileToDownload = kf;
                        break;
                    }
                }

                if (fileToDownload != null) {
                    System.out.println("📥 Downloading file with Title: '" + fileToDownload.getData().getTitle() + "' (UID: " + fileToDownload.getFileUid() + ")");
                    byte[] downloadedBytes = SecretsManager.downloadFile(options, fileToDownload);
                    
                    try (FileOutputStream fos = new FileOutputStream(DOWNLOADED_FILE_NAME)) {
                        fos.write(downloadedBytes);
                        System.out.println("✅ File downloaded successfully to: " + DOWNLOADED_FILE_NAME);
                        System.out.println("    Size: " + downloadedBytes.length + " bytes");
                        // Verify content (optional)
                        // String content = new String(downloadedBytes);
                        // System.out.println("    Content preview: " + content.substring(0, Math.min(content.length(), 30)) + "...");
                    } catch (IOException e) {
                        System.err.println("❌ Error saving downloaded file: " + e.getMessage());
                    }
                } else {
                    System.out.println("ℹ️ File with title '" + uploadedFileTitle + "' not found for download.");
                }
            } else {
                System.out.println("ℹ️ No files available on the record to download.");
            }

            System.out.println("\n🎉 File management operations complete. Check your Keeper Vault and local directory for results.");

        } catch (Exception e) {
            System.err.println("❌ Error during file management operations: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
```{{copy}}

## 3. Configure Target Record UID

-   In `ManageFileAttachments.java`:
    -   **Crucial**: Replace `[YOUR_RECORD_UID_FOR_FILES]` with the UID of an existing record in your Keeper Vault where your KSM application has appropriate permissions (Edit for upload, View for list/download).
    -   If needed, update `[ONE_TIME_TOKEN_IF_NEEDED]`.

## 4. Run the Application

```bash
gradle -PmainClass=com.keepersecurity.ksmsdk.javatutorial.ManageFileAttachments run --console=plain
```
`gradle -PmainClass=com.keepersecurity.ksmsdk.javatutorial.ManageFileAttachments run --console=plain`{{execute}}

### Expected Output:

```
🚀 Managing file attachments...

--- Uploading File ---
📎 Uploading 'sample-attachment.txt' with title 'SDK Uploaded - sample-attachment.txt' to record UID: YOUR_RECORD_UID_FOR_FILES
✅ File uploaded successfully!

--- Listing Files for Record ---
📄 Files attached to record 'Your Record Title' (UID: YOUR_RECORD_UID_FOR_FILES):
    - Title: SDK Uploaded - sample-attachment.txt (Name: sample-attachment.txt, UID: ..., Size: ..., Type: text/plain)
    ...

--- Downloading File ---
📥 Downloading file with Title: 'SDK Uploaded - sample-attachment.txt' (UID: ...)
✅ File downloaded successfully to: downloaded-sample.txt
    Size: ... bytes

🎉 File management operations complete. Check your Keeper Vault and local directory for results.
```

**Verify**: 
- Check the target record in your Keeper Vault; the new file `SDK Uploaded - sample-attachment.txt` should be attached.
- Check your project directory; the file `downloaded-sample.txt` should exist and contain the content of `sample-attachment.txt`.

## Understanding the Code

-   **`KeeperFileUpload`**: This class is used to prepare a file for uploading. You provide the `name` (original filename), `title` (display name in Keeper), `type` (MIME type, optional), and the file `data` as a byte array.
-   **`SecretsManager.uploadFile(options, record, fileUploadData)`**: Uploads the prepared file to the specified `KeeperRecord`.
    -   The `record` object must be an up-to-date instance of `KeeperRecord` (it's good practice to fetch it just before upload if you don't already have it).
-   **Listing Files**: After fetching a `KeeperRecord`, its `getFiles()` method returns a `List<KeeperFile>`. Each `KeeperFile` object has:
    -   `getFileUid()`: The unique ID of the file attachment.
    -   `getData()`: Returns a `KeeperFileData` object which contains metadata like `name`, `title`, `size`, and `type`.
-   **`SecretsManager.downloadFile(options, keeperFile)`**: Downloads the specified `KeeperFile` and returns its content as a byte array.

## Important Notes on File Handling

-   **Permissions**: Ensure your KSM application has "Can Edit" permission on the record to upload files and "Can View" to list/download files.
-   **File Size Limits**: Keeper has limits on the size of individual file attachments, which may depend on your subscription plan. The SDK might also impose practical limits for very large files due to memory constraints during upload/download.
-   **Error Handling**: Always include robust error handling for file operations (e.g., file not found, network issues, permission denied).

## Next Steps

In the final step of this tutorial, you'll explore advanced configuration options, including in-memory storage for KSM configuration and secret caching for improved performance.