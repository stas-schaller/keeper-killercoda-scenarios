# Step 3: Creating Records & Folders

This step demonstrates how to programmatically create new records and folders in your Keeper Vault using the KSM Java SDK. This is useful for automating secret provisioning and organizing your vault structure.

## 1. Prepare Your Environment

-   Ensure you have a working `ksm-config.json` from previous steps.
-   You'll need the UID of a **Shared Folder** in your Keeper Vault where your KSM application has **"Can Edit"** permission. New records and folders will be created within this shared folder.

## 2. Create Java Class: CreateSecrets

Create a new Java class for this example.

```bash
touch src/main/java/com/keepersecurity/ksmsdk/javatutorial/CreateSecrets.java
```
`touch src/main/java/com/keepersecurity/ksmsdk/javatutorial/CreateSecrets.java`{{execute}}

### Add the Java Code

Paste the following code into `src/main/java/com/keepersecurity/ksmsdk/javatutorial/CreateSecrets.java`:

```java
package com.keepersecurity.ksmsdk.javatutorial;

import com.keepersecurity.secretsManager.core.*;
import static com.keepersecurity.secretsManager.core.SecretsManager.initializeStorage;
import java.util.List;
import java.util.ArrayList;

public class CreateSecrets {

    private static final String ONE_TIME_TOKEN = "[ONE_TIME_TOKEN_IF_NEEDED]"; // Only if ksm-config.json doesn't exist
    private static final String CONFIG_FILE_NAME = "ksm-config.json";

    // ⚠️ Replace with the UID of a Shared Folder where your KSM App has "Can Edit" permission
    private static final String TARGET_SHARED_FOLDER_UID = "[YOUR_SHARED_FOLDER_UID_HERE]";

    public static void main(String[] args) {
        System.out.println("🚀 Creating new records and folders...");
        LocalConfigStorage storage = new LocalConfigStorage(CONFIG_FILE_NAME);

        try {
            if (!new java.io.File(CONFIG_FILE_NAME).exists() || !ONE_TIME_TOKEN.startsWith("[")) {
                System.out.println("🔑 Initializing KSM storage...");
                initializeStorage(storage, ONE_TIME_TOKEN);
            }
            SecretsManagerOptions options = new SecretsManagerOptions(storage);

            // --- 1. Create a New Login Record ---
            System.out.println("\n--- Creating New Login Record ---");
            KeeperRecordData newLoginData = new KeeperRecordData(
                    "My Automated Login - Java SDK", // Title
                    "login",                         // Record Type
                    new ArrayList<>(List.of(        // Standard Fields
                            new Login("automated_user@example.com"),
                            new Password("P@$$wOrdJavaSDK123!"),
                            new Url("https://automated.example.com")
                    )),
                    new ArrayList<>(List.of(        // Custom Fields
                            new Text("API_Key_Custom", "Custom Label", new ArrayList<>(List.of("customValueJava123")))
                    )),
                    "This login record was created automatically by the KSM Java SDK tutorial." // Notes
            );

            // The createSecret method returns the UID of the newly created record
            String newLoginRecordUid = SecretsManager.createSecret(options, TARGET_SHARED_FOLDER_UID, newLoginData);
            System.out.println("✅ Login Record created successfully! UID: " + newLoginRecordUid);
            System.out.println("    Title: " + newLoginData.getTitle());

            // --- 2. Create a New Bank Card Record ---
            System.out.println("\n--- Creating New Bank Card Record ---");
            List<KeeperRecordField> cardFields = new ArrayList<>();
            cardFields.add(new Text("cardholderName", "Cardholder Name", new ArrayList<>(List.of("Java SDK User"))));
            cardFields.add(new Text("bankCard", "Card Number", new ArrayList<>(List.of("4000123456789010")))); // Use appropriate field type if available, e.g. PaymentCard
            cardFields.add(new Text("bankCard", "Expiration Date", new ArrayList<>(List.of("12/2025")))); 
            cardFields.add(new Text("bankCard", "Security Code", new ArrayList<>(List.of("123"))));

            KeeperRecordData newCardData = new KeeperRecordData(
                "My Automated Bank Card - Java SDK",
                "bankCard",
                cardFields,
                null, // No custom fields for this example
                "Automated bank card entry."
            );
            String newCardRecordUid = SecretsManager.createSecret(options, TARGET_SHARED_FOLDER_UID, newCardData);
            System.out.println("✅ Bank Card Record created successfully! UID: " + newCardRecordUid);

            // --- 3. Create a New Folder (Subfolder) within the Target Shared Folder ---
            System.out.println("\n--- Creating New Folder ---");
            String newFolderName = "Java SDK Automated Subfolder";
            // createFolder returns the UID of the newly created folder
            String newFolderUid = SecretsManager.createFolder(options, TARGET_SHARED_FOLDER_UID, newFolderName, null);
            System.out.println("✅ Folder created successfully! Name: " + newFolderName + ", UID: " + newFolderUid);
            System.out.println("    This folder is inside Shared Folder: " + TARGET_SHARED_FOLDER_UID);

            // --- 4. Create a record inside the newly created subfolder ---
            System.out.println("\n--- Creating Record in New Subfolder ---");
             KeeperRecordData recordInNewFolderData = new KeeperRecordData(
                    "Record in Automated Subfolder - Java SDK", 
                    "login",                        
                    new ArrayList<>(List.of(new Login("subfolder_user@example.com"))),
                    null,
                    "This record is inside a newly created subfolder."
            );
            // Use newFolderUid as the parentFolderUid for this record
            String recordInNewFolderUid = SecretsManager.createSecret(options, newFolderUid, recordInNewFolderData);
            System.out.println("✅ Record in new subfolder created! UID: " + recordInNewFolderUid);
            System.out.println("    Parent Folder UID: " + newFolderUid);

            System.out.println("\n🎉 All creation operations complete. Check your Keeper Vault!");

        } catch (Exception e) {
            System.err.println("❌ Error during creation operations: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
w```{{copy}}

## 3. Configure Shared Folder UID

-   In `CreateSecrets.java`:
    -   **Crucial**: Replace `[YOUR_SHARED_FOLDER_UID_HERE]` with the UID of a Shared Folder in your Keeper Vault where your KSM application has **"Can Edit"** permissions. You can get this UID from the Keeper Vault by selecting the folder, clicking options (three dots), and choosing "Folder Info".
    -   If needed, update `[ONE_TIME_TOKEN_IF_NEEDED]`.

## 4. Run the Application

```bash
gradle -PmainClass=com.keepersecurity.ksmsdk.javatutorial.CreateSecrets run --console=plain
```
`gradle -PmainClass=com.keepersecurity.ksmsdk.javatutorial.CreateSecrets run --console=plain`{{execute}}

### Expected Output:

You should see confirmation messages with the UIDs of the newly created records and folder.

```
🚀 Creating new records and folders...

--- Creating New Login Record ---
✅ Login Record created successfully! UID: ...
    Title: My Automated Login - Java SDK

--- Creating New Bank Card Record ---
✅ Bank Card Record created successfully! UID: ...

--- Creating New Folder ---
✅ Folder created successfully! Name: Java SDK Automated Subfolder, UID: ...
    This folder is inside Shared Folder: YOUR_SHARED_FOLDER_UID_HERE

--- Creating Record in New Subfolder ---
✅ Record in new subfolder created! UID: ...
    Parent Folder UID: ...

🎉 All creation operations complete. Check your Keeper Vault!
```

**Verify in your Keeper Vault**: You should find the new records and the new subfolder (containing one record) inside the target shared folder you specified.

## Understanding the Code

-   **`KeeperRecordData`**: This class is used to define the structure of a new record, including its `title`, `type`, standard `fields`, `custom` fields, and `notes`.
    -   Standard fields (like `Login`, `Password`, `Url`, `Text`) are instantiated and added to a list.
    -   Custom fields are also represented by classes like `Text` (or others like `HiddenField`, `Date`, etc., depending on the type) and require a `label` in addition to the `value`.
-   **`SecretsManager.createSecret(options, parentFolderUid, recordData)`**: Creates a new record.
    -   `parentFolderUid`: The UID of the folder (either a shared folder or a subfolder) where the new record will be placed.
    -   It returns the UID of the newly created record.
-   **`SecretsManager.createFolder(options, parentSharedFolderUid, folderName, subFolderUid)`**: Creates a new folder.
    -   `parentSharedFolderUid`: The UID of the Shared Folder under which this new folder will be created.
    -   `folderName`: The name for the new folder.
    -   `subFolderUid`: (Optional, typically `null` for top-level creation within a shared folder) The UID of an existing subfolder if you want to create a folder within another non-shared subfolder. For creating directly under a shared folder, this is usually `null`.
    -   It returns the UID of the newly created folder.
-   **Permissions**: The KSM application (defined by your `ksm-config.json`) must have "Can Edit" permissions on the `TARGET_SHARED_FOLDER_UID` to create records and subfolders within it.

## Important Notes on Field Types

-   The Java SDK provides specific classes for various standard field types (e.g., `Login`, `Password`, `Url`, `Name`, `Phone`, `Address`, `PaymentCard`, `Text`, `Multiline`, `Date`, `HiddenField`, etc.).
-   When creating fields, instantiate the appropriate class. For custom fields, you often use `Text` or a more specific type if available, providing a `label` for identification.
-   Refer to the `RecordData.kt` in the SDK source (specifically the sealed class `KeeperRecordField` and its implementations) for a full list of available field types and their constructors.

## Next Steps

In the next step, you'll learn how to manage file attachments, including uploading files to records and downloading them.
