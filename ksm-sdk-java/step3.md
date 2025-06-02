# Step 3: Creating Records & Folders with Password Generation

This step demonstrates how to programmatically create new records (including generating strong passwords) and folders in your Keeper Vault using the KSM Java SDK.

## 1. Prepare Your Environment

-   Ensure you have a working `ksm-config.json` from previous steps.
-   You'll need the UID of a **Shared Folder** in your Keeper Vault where your KSM application has **"Can Edit"** permission. New records and folders will be created within this shared folder.

## 2. Create Java Class: CreateSecretsAndFolders

Create a new Java class for this example, or modify the existing one.

```bash
# Example: touch src/main/java/com/keepersecurity/ksmsdk/javatutorial/CreateSecretsAndFolders.java
# Ensure your package structure matches if creating a new file.
```
` # For this tutorial, we assume you are modifying the existing CreateSecrets.java or a similar file`{{execute}}

### Add/Modify the Java Code

Update your Java file (e.g., `CreateSecrets.java`) with the following code. Key changes include adding password generation.

```java
package com.keepersecurity.ksmsdk.javatutorial;

import com.keepersecurity.secretsManager.core.*;
import static com.keepersecurity.secretsManager.core.SecretsManager.initializeStorage;
import java.util.List;
import java.util.ArrayList;

public class CreateSecretsAndFolders { // Renamed class for clarity

    private static final String ONE_TIME_TOKEN = "[ONE_TIME_TOKEN_IF_NEEDED]"; // Only if ksm-config.json doesn't exist
    private static final String CONFIG_FILE_NAME = "ksm-config.json";

    // ⚠️ Replace with the UID of a Shared Folder where your KSM App has "Can Edit" permission
    private static final String TARGET_SHARED_FOLDER_UID = "[YOUR_SHARED_FOLDER_UID_HERE]";

    public static void main(String[] args) {
        System.out.println("🚀 Creating new records (with password generation) and folders...");
        LocalConfigStorage storage = new LocalConfigStorage(CONFIG_FILE_NAME);
        SecretsManagerOptions options = null;

        try {
            if (!new java.io.File(CONFIG_FILE_NAME).exists() || (ONE_TIME_TOKEN != null && !ONE_TIME_TOKEN.startsWith("["))) {
                System.out.println("🔑 Initializing KSM storage...");
                initializeStorage(storage, ONE_TIME_TOKEN);
            }
            options = new SecretsManagerOptions(storage);

            // --- 1. Create a New Login Record with Generated Password ---
            System.out.println("\n--- Creating New Login Record with Generated Password ---");
            
            // Generate a strong password
            // PasswordGeneratorOptions can be used for more control (length, char types)
            // Default generatePassword() creates a 16-character password with mix of types.
            String generatedPassword = SecretsManager.generatePassword(); 
            System.out.println("🔒 Generated Password: " + generatedPassword + " (Note: Do not log passwords in production)");

            KeeperRecordData newLoginData = new KeeperRecordData(
                    "My Secure Login - Java SDK",     // Title
                    "login",                         // Record Type
                    new ArrayList<>(List.of(        // Standard Fields
                            new Login("secure_java_user@example.com"),
                            new Password(generatedPassword), // Use the generated password
                            new Url("https://secure.java.example.com")
                    )),
                    new ArrayList<>(List.of(        // Custom Fields
                            new Text("GenSource", "Password Generation Source", new ArrayList<>(List.of("Java SDK")))
                    )),
                    "Login record with SDK-generated password." // Notes
            );

            String newLoginRecordUid = SecretsManager.createSecret(options, TARGET_SHARED_FOLDER_UID, newLoginData);
            System.out.println("✅ Login Record created successfully! UID: " + newLoginRecordUid);
            System.out.println("    Title: " + newLoginData.getTitle());

            // --- 2. Create a New Bank Card Record (remains same as before) ---
            System.out.println("\n--- Creating New Bank Card Record ---");
            List<KeeperRecordField> cardFields = new ArrayList<>();
            cardFields.add(new Text("cardholderName", "Cardholder Name", new ArrayList<>(List.of("Java SDK User"))));
            cardFields.add(new Text("bankCard", "Card Number", new ArrayList<>(List.of("4000123456789010")))); 
            cardFields.add(new Text("bankCard", "Expiration Date", new ArrayList<>(List.of("12/2025")))); 
            cardFields.add(new Text("bankCard", "Security Code", new ArrayList<>(List.of("123"))));

            KeeperRecordData newCardData = new KeeperRecordData(
                "My Automated Bank Card - Java SDK", "bankCard", cardFields, null, "Automated bank card entry.");
            String newCardRecordUid = SecretsManager.createSecret(options, TARGET_SHARED_FOLDER_UID, newCardData);
            System.out.println("✅ Bank Card Record created successfully! UID: " + newCardRecordUid);

            // --- 3. Create a New Folder (Subfolder) ---
            System.out.println("\n--- Creating New Folder ---");
            String newFolderName = "Java SDK Auto Subfolder - " + System.currentTimeMillis();
            String newFolderUid = SecretsManager.createFolder(options, TARGET_SHARED_FOLDER_UID, newFolderName, null);
            System.out.println("✅ Folder created successfully! Name: " + newFolderName + ", UID: " + newFolderUid);

            // --- 4. Create a record inside the newly created subfolder ---
            System.out.println("\n--- Creating Record in New Subfolder ---");
             KeeperRecordData recordInNewFolderData = new KeeperRecordData(
                    "Record in Auto Subfolder - Java SDK", "login", 
                    new ArrayList<>(List.of(new Login("subfolder_user2@example.com"))), null, "Inside SDK-created folder.");
            String recordInNewFolderUid = SecretsManager.createSecret(options, newFolderUid, recordInNewFolderData);
            System.out.println("✅ Record in new subfolder created! UID: " + recordInNewFolderUid);

            System.out.println("\n🎉 All creation operations complete. Check your Keeper Vault!");

        } catch (Exception e) {
            System.err.println("❌ Error during creation operations: " + e.getMessage());
            e.printStackTrace();
        }
    }
}

```{{copy}}

## 3. Configure Shared Folder UID

-   In your Java file (e.g., `CreateSecretsAndFolders.java`):
    -   **Crucial**: Replace `[YOUR_SHARED_FOLDER_UID_HERE]` with the UID of a Shared Folder in your Keeper Vault where your KSM application has **"Can Edit"** permissions.
    -   If needed, update `[ONE_TIME_TOKEN_IF_NEEDED]` for initial `ksm-config.json` setup.

## 4. Run the Application

Ensure your `build.gradle` file is configured to run the correct main class (e.g., `com.keepersecurity.ksmsdk.javatutorial.CreateSecretsAndFolders`).

```bash
gradle -PmainClass=com.keepersecurity.ksmsdk.javatutorial.CreateSecretsAndFolders run --console=plain
```
`gradle -PmainClass=com.keepersecurity.ksmsdk.javatutorial.CreateSecretsAndFolders run --console=plain`{{execute}}

### Expected Output:

```
🚀 Creating new records (with password generation) and folders...

--- Creating New Login Record with Generated Password ---
🔒 Generated Password: <A_GENERATED_PASSWORD_HERE> (Note: Do not log passwords in production)
✅ Login Record created successfully! UID: ...
    Title: My Secure Login - Java SDK

--- Creating New Bank Card Record ---
✅ Bank Card Record created successfully! UID: ...

--- Creating New Folder ---
✅ Folder created successfully! Name: Java SDK Auto Subfolder - ..., UID: ...

--- Creating Record in New Subfolder ---
✅ Record in new subfolder created! UID: ...

🎉 All creation operations complete. Check your Keeper Vault!
```

**Verify in your Keeper Vault**: You should find the new records (one with a generated password) and the new subfolder inside your target shared folder.

## Understanding the Code Changes

-   **`SecretsManager.generatePassword()`**: This static method from the `SecretsManager` class is used to generate a strong, random password. 
    -   By default, it produces a 16-character password with a mix of uppercase, lowercase, digits, and special characters.
    -   For more control over password length and character types, you can use `SecretsManager.generatePassword(PasswordGeneratorOptions options)`.
-   The generated password is then used when creating the `Password` field for the new login record.

## Important Notes on Field Types

-   The Java SDK provides specific classes for various standard field types (e.g., `Login`, `Password`, `Url`, `Name`, `Phone`, `Address`, `PaymentCard`, `Text`, `Multiline`, `Date`, `HiddenField`, etc.).
-   When creating fields, instantiate the appropriate class. For custom fields, you often use `Text` or a more specific type if available, providing a `label` for identification.
-   Refer to the SDK source (e.g., `KeeperRecordField.java` and its subclasses) for a full list of available field types and their constructors.

## Next Steps

In the next step, you'll learn how to manage file attachments, including uploading files to records and downloading them, as well as updating existing records.
