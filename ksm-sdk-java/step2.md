# Step 2: Retrieving Specific Secrets & Fields

In this step, you'll learn how to fetch specific records from Keeper Secrets Manager and access their individual fields. This is essential for integrating targeted secret retrieval into your Java applications.

## 1. Prepare Your Environment

Ensure you have:
- Completed Step 1 and have a working `ksm-config.json` (or are using a valid One-Time Token for the first run of new examples).
- At least one record shared with your KSM application in the Keeper Vault. For this step, ensure this record has:
    - A unique title (e.g., "My Test Login").
    - Standard fields like login, password, and URL.
    - A custom field (e.g., label: "API Key", type: text, value: "mysecretapikey123").

## 2. Create Java Class: GetSpecificSecret

Create a new Java class to demonstrate fetching specific secrets.

```bash
touch src/main/java/com/keepersecurity/ksmsdk/javatutorial/GetSpecificSecret.java
```
`touch src/main/java/com/keepersecurity/ksmsdk/javatutorial/GetSpecificSecret.java`{{execute}}

### Add the Java Code

Paste the following code into `src/main/java/com/keepersecurity/ksmsdk/javatutorial/GetSpecificSecret.java`:

```java
package com.keepersecurity.ksmsdk.javatutorial;

import com.keepersecurity.secretsManager.core.*;
import static com.keepersecurity.secretsManager.core.SecretsManager.initializeStorage;
import java.util.List;
import java.util.Optional;

public class GetSpecificSecret {

    // ⚠️ If ksm-config.json doesn't exist, replace with your One-Time Token
    private static final String ONE_TIME_TOKEN = "[ONE_TIME_TOKEN_IF_NEEDED]";
    private static final String CONFIG_FILE_NAME = "ksm-config.json";

    // Replace with the UID or Title of a record shared with your KSM Application
    private static final String TARGET_RECORD_UID = "[YOUR_RECORD_UID_HERE]";
    private static final String TARGET_RECORD_TITLE = "[YOUR_RECORD_TITLE_HERE]"; // e.g., "My Test Login"

    public static void main(String[] args) {
        System.out.println("🚀 Retrieving specific secrets and fields...");
        LocalConfigStorage storage = new LocalConfigStorage(CONFIG_FILE_NAME);

        try {
            // Initialize storage if ksm-config.json doesn't exist or token is provided
            if (!new java.io.File(CONFIG_FILE_NAME).exists() || !ONE_TIME_TOKEN.startsWith("[")) {
                 System.out.println("🔑 Initializing KSM storage...");
                initializeStorage(storage, ONE_TIME_TOKEN);
            }
            SecretsManagerOptions options = new SecretsManagerOptions(storage);

            // Option 1: Get all secrets and then find by UID or Title (less efficient for single record)
            System.out.println("\n--- Method 1: Fetching all then filtering ---");
            KeeperSecrets allSecrets = SecretsManager.getSecrets(options);

            KeeperRecord recordByUid_m1 = allSecrets.getRecordByUid(TARGET_RECORD_UID);
            if (recordByUid_m1 != null) {
                System.out.println("Found record by UID (Method 1): " + recordByUid_m1.getTitle());
                displayRecordDetails(recordByUid_m1);
            } else {
                System.out.println("Record with UID '" + TARGET_RECORD_UID + "' not found (Method 1).");
            }

            KeeperRecord recordByTitle_m1 = allSecrets.getSecretByTitle(TARGET_RECORD_TITLE);
            if (recordByTitle_m1 != null) {
                System.out.println("Found record by Title (Method 1): " + recordByTitle_m1.getTitle());
                // displayRecordDetails(recordByTitle_m1); // Avoid redundant display if UID and Title match same record
            } else {
                System.out.println("Record with Title '" + TARGET_RECORD_TITLE + "' not found (Method 1).");
            }

            // Option 2: Get specific secrets by UID (more efficient for single record)
            // Note: getSecrets can take a list of UIDs to fetch.
            System.out.println("\n--- Method 2: Fetching specific record by UID ---");
            KeeperSecrets specificSecrets = SecretsManager.getSecrets(options, List.of(TARGET_RECORD_UID));
            KeeperRecord recordByUid_m2 = specificSecrets.getRecordByUid(TARGET_RECORD_UID); // Or specificSecrets.getRecords().get(0) if sure it exists

            if (recordByUid_m2 != null) {
                System.out.println("Found record by UID (Method 2): " + recordByUid_m2.getTitle());
                displayRecordDetails(recordByUid_m2);
            } else {
                System.out.println("Record with UID '" + TARGET_RECORD_UID + "' not found (Method 2).");
            }

        } catch (Exception e) {
            System.err.println("❌ Error: " + e.getMessage());
            e.printStackTrace();
        }
    }

    private static void displayRecordDetails(KeeperRecord record) {
        System.out.printf("    Record UID: %s%n", record.getRecordUid());
        System.out.printf("    Title: %s%n", record.getTitle());
        System.out.printf("    Type: %s%n", record.getType());

        // Accessing Standard Fields (e.g., login, password, url for a 'login' type record)
        System.out.println("    Fields:");
        // The actual KeeperRecordData object holds the fields
        KeeperRecordData recordData = record.getData();

        // Example: Get Login field (if record type is login)
        Optional<Login> loginField = recordData.getFields().stream()
                .filter(f -> f instanceof Login)
                .map(f -> (Login) f)
                .findFirst();
        loginField.ifPresent(lf -> System.out.printf("      - Login: %s%n", lf.getValue().isEmpty() ? "<empty>" : lf.getValue().get(0)));

        // Example: Get Password field (using the convenience method on KeeperRecord)
        String password = record.getPassword(); // Convenience for login type records
        if (password != null) {
            System.out.printf("      - Password: %s%n", password.isEmpty() ? "<empty>" : "********" ); // Mask password in output
        }

        // Example: Get a URL field
        Optional<Url> urlField = recordData.getFields().stream()
                .filter(f -> f instanceof Url)
                .map(f -> (Url) f)
                .findFirst();
        urlField.ifPresent(uf -> System.out.printf("      - URL: %s%n", uf.getValue().isEmpty() ? "<empty>" : uf.getValue().get(0)));

        // Accessing Custom Fields by Label
        System.out.println("    Custom Fields:");
        if (recordData.getCustom() != null) {
            for (KeeperRecordField customField : recordData.getCustom()) {
                String label = customField.getLabel();
                String value = "<complex type or empty>"; // Default for unknown/complex types
                if (customField instanceof Text) { // Check if it's a Text custom field
                    Text textField = (Text) customField;
                    if (!textField.getValue().isEmpty()) {
                        value = textField.getValue().get(0);
                    }
                } else if (customField instanceof Password) { // For custom password fields
                     Password passField = (Password) customField;
                     if (!passField.getValue().isEmpty()) {
                         value = "********"; // Mask password
                     }
                }
                // Add more instanceof checks for other custom field types as needed
                System.out.printf("      - %s: %s%n", label != null ? label : "<no label>", value);
            }
        } else {
            System.out.println("      <No custom fields>");
        }

        // Accessing Notes
        String notes = recordData.getNotes();
        if (notes != null && !notes.isEmpty()) {
            System.out.printf("    Notes: %s%n", notes.substring(0, Math.min(notes.length(), 50)) + (notes.length() > 50 ? "..." : ""));
        } else {
            System.out.println("    Notes: <No notes>");
        }
        System.out.println("---");
    }
}
```{{copy}}

## 3. Configure Target Record

-   In `GetSpecificSecret.java`:
    -   Replace `[YOUR_RECORD_UID_HERE]` with the actual UID of a record in your vault.
    -   Replace `[YOUR_RECORD_TITLE_HERE]` with the title of that same record.
    -   If your `ksm-config.json` is not yet created (i.e., this is the first time running any example after setup), replace `[ONE_TIME_TOKEN_IF_NEEDED]` with a valid One-Time Token.

## 4. Run the Application

```bash
gradle -PmainClass=com.keepersecurity.ksmsdk.javatutorial.GetSpecificSecret run --console=plain
```
`gradle -PmainClass=com.keepersecurity.ksmsdk.javatutorial.GetSpecificSecret run --console=plain`{{execute}}

### Expected Output:

You should see details of the targeted record, including its standard and custom fields.

```
🚀 Retrieving specific secrets and fields...

--- Method 1: Fetching all then filtering ---
Found record by UID (Method 1): My Test Login
    Record UID: YOUR_RECORD_UID_HERE
    Title: My Test Login
    Type: login
    Fields:
      - Login: testuser@example.com
      - Password: ********
      - URL: https://example.com
    Custom Fields:
      - API Key: mysecretapikey123
    Notes: Sample notes for testing...
---
...
```

## Understanding the Code

-   **Fetching Strategies**: 
    -   Method 1 (`SecretsManager.getSecrets(options)` then filter): Fetches all records and then filters locally. Simpler for multiple lookups after an initial fetch, but less efficient if you only need one specific record initially.
    -   Method 2 (`SecretsManager.getSecrets(options, List.of(UID))`) : Directly requests specific records by their UIDs. This is more efficient for targeted lookups.
-   **Accessing Record Data**: The `KeeperRecord` object contains a `getData()` method which returns a `KeeperRecordData` object. This `KeeperRecordData` object holds the actual `title`, `type`, `notes`, `fields` (list of standard fields), and `custom` (list of custom fields).
-   **Standard Fields**: Standard fields like `Login`, `Password`, `Url` are classes that extend `KeeperRecordField`. You can iterate through `record.getData().getFields()` and use `instanceof` to identify and cast them to their specific types to access their `value`.
    -   The `KeeperRecord` class provides a convenience method `record.getPassword()` for login-type records.
-   **Custom Fields**: Custom fields are also in a list, typically `record.getData().getCustom()`. You usually access them by iterating and checking their `label`. Their values are also retrieved via their specific type (e.g., `Text`, `Password`).
-   **Optional Fields**: Many fields or their values can be null or empty. Always check for nulls or use `Optional` where appropriate (though the SDK often uses nullable types or empty lists directly).

## Next Steps

In the next step, you'll learn how to programmatically create new records and folders within your Keeper Vault using the Java SDK.
