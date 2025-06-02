# Step 5: Advanced Configuration & Caching

This final step explores advanced KSM Java SDK configurations: using in-memory storage for your KSM client configuration and implementing secret caching for performance optimization.

## 1. In-Memory Configuration Storage

Instead of relying on a `ksm-config.json` file, you can initialize the KSM SDK with a Base64 encoded configuration string directly in memory. This is highly useful for environments where file system persistence is not desired or easily managed (e.g., containers, AWS Lambda, CI/CD pipelines).

### How to Get the Base64 Configuration String:
1.  Log into your Keeper Web Vault.
2.  Navigate to **Secrets Manager** -> **Applications**.
3.  Select or create your KSM application.
4.  Go to the **Devices** tab.
5.  Click **ADD DEVICE**.
6.  Choose **Method: Configuration File**.
7.  **Copy the displayed Base64 encoded string**. This string contains all necessary information to initialize your KSM application.

### Create Java Class: InMemoryConfigDemo

```bash
touch src/main/java/com/keepersecurity/ksmsdk/javatutorial/InMemoryConfigDemo.java
```
`touch src/main/java/com/keepersecurity/ksmsdk/javatutorial/InMemoryConfigDemo.java`{{execute}}

### Add the Java Code for In-Memory Storage

Paste the following code into `src/main/java/com/keepersecurity/ksmsdk/javatutorial/InMemoryConfigDemo.java`:

```java
package com.keepersecurity.ksmsdk.javatutorial;

import com.keepersecurity.secretsManager.core.*;
import java.util.List;

public class InMemoryConfigDemo {

    // ⚠️ IMPORTANT: Replace with your actual Base64 encoded KSM configuration string
    private static final String KSM_CONFIG_BASE64 = "[YOUR_KSM_CONFIG_BASE64_STRING_HERE]";

    public static void main(String[] args) {
        System.out.println("🚀 Demonstrating In-Memory KSM Configuration...");

        if (KSM_CONFIG_BASE64.startsWith("[")) {
            System.err.println("❌ Error: Please replace '[YOUR_KSM_CONFIG_BASE64_STRING_HERE]' with your actual Base64 config string.");
            System.err.println("    You can obtain this from the Keeper Vault (Secrets Manager -> Application -> Devices -> Add Device -> Configuration File).");
            return;
        }

        // Use InMemoryStorage and pass the Base64 configuration string directly
        InMemoryStorage inMemoryStorage = new InMemoryStorage(KSM_CONFIG_BASE64);
        SecretsManagerOptions options = new SecretsManagerOptions(inMemoryStorage);

        try {
            System.out.println("💾 Storage initialized in-memory.");
            System.out.println("📡 Fetching all secrets using in-memory config...");
            KeeperSecrets secrets = SecretsManager.getSecrets(options);

            List<KeeperRecord> records = secrets.getRecords();
            System.out.println("✅ Successfully fetched " + records.size() + " record(s) using in-memory configuration:");

            if (!records.isEmpty()) {
                for (int i = 0; i < Math.min(records.size(), 3); i++) { // Display up to 3 records
                    KeeperRecord record = records.get(i);
                    System.out.printf("    [%d] UID: %s, Title: %s, Type: %s%n",
                            i + 1, record.getRecordUid(), record.getTitle(), record.getType());
                }
            } else {
                System.out.println("ℹ️ No records found for this configuration.");
            }

        } catch (Exception e) {
            System.err.println("❌ Error with in-memory configuration: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
```{{copy}}

### Configure Base64 String
-   In `InMemoryConfigDemo.java`, **replace `[YOUR_KSM_CONFIG_BASE64_STRING_HERE]`** with the actual Base64 string you copied from the Keeper Vault.

### Run the In-Memory Demo

```bash
gradle -PmainClass=com.keepersecurity.ksmsdk.javatutorial.InMemoryConfigDemo run --console=plain
```
`gradle -PmainClass=com.keepersecurity.ksmsdk.javatutorial.InMemoryConfigDemo run --console=plain`{{execute}}

## 2. Secret Caching for Performance

The KSM SDK supports caching of secrets to reduce latency and the number of API calls to Keeper servers for frequently accessed secrets.

### Create Java Class: CachingDemo

```bash
touch src/main/java/com/keepersecurity/ksmsdk/javatutorial/CachingDemo.java
```
`touch src/main/java/com/keepersecurity/ksmsdk/javatutorial/CachingDemo.java`{{execute}}

### Add the Java Code for Caching

Paste the following code into `src/main/java/com/keepersecurity/ksmsdk/javatutorial/CachingDemo.java`:

```java
package com.keepersecurity.ksmsdk.javatutorial;

import com.keepersecurity.secretsManager.core.*;
import static com.keepersecurity.secretsManager.core.SecretsManager.initializeStorage;
import java.util.List;
import java.util.concurrent.TimeUnit;

public class CachingDemo {

    private static final String ONE_TIME_TOKEN = "[ONE_TIME_TOKEN_IF_NEEDED]"; // Only if ksm-config.json doesn't exist
    private static final String CONFIG_FILE_NAME = "ksm-config.json";

    public static void main(String[] args) throws InterruptedException {
        System.out.println("🚀 Demonstrating KSM Secret Caching...");
        LocalConfigStorage storage = new LocalConfigStorage(CONFIG_FILE_NAME);

        try {
            if (!new java.io.File(CONFIG_FILE_NAME).exists() || !ONE_TIME_TOKEN.startsWith("[")) {
                System.out.println("🔑 Initializing KSM storage...");
                initializeStorage(storage, ONE_TIME_TOKEN);
            }

            // Configure caching. Cache for 60 seconds in this example.
            // The cache uses the same storage (e.g., ksm-config.json) to persist cached data securely.
            long cacheRefreshIntervalSeconds = 60;
            SecretsManagerOptions optionsWithCache = new SecretsManagerOptions(storage, null, false, cacheRefreshIntervalSeconds);

            System.out.println("\n--- First secrets fetch (populates cache) ---");
            long startTime = System.nanoTime();
            KeeperSecrets secrets1 = SecretsManager.getSecrets(optionsWithCache);
            long duration1 = TimeUnit.NANOSECONDS.toMillis(System.nanoTime() - startTime);
            System.out.println("✅ Fetched " + secrets1.getRecords().size() + " records in " + duration1 + " ms (from server, cache populated).");

            System.out.println("\n--- Second secrets fetch (should be from cache) ---");
            startTime = System.nanoTime();
            KeeperSecrets secrets2 = SecretsManager.getSecrets(optionsWithCache);
            long duration2 = TimeUnit.NANOSECONDS.toMillis(System.nanoTime() - startTime);
            System.out.println("✅ Fetched " + secrets2.getRecords().size() + " records in " + duration2 + " ms (from cache).");

            if (duration2 < duration1) {
                System.out.println("⚡️ Performance improvement observed due to caching!");
            }

            System.out.println("\nWaiting for cache to expire (configured for " + cacheRefreshIntervalSeconds + " seconds)...");
            TimeUnit.SECONDS.sleep(cacheRefreshIntervalSeconds + 5); // Wait a bit longer than cache interval

            System.out.println("\n--- Third secrets fetch (cache expired, should fetch from server again) ---");
            startTime = System.nanoTime();
            KeeperSecrets secrets3 = SecretsManager.getSecrets(optionsWithCache);
            long duration3 = TimeUnit.NANOSECONDS.toMillis(System.nanoTime() - startTime);
            System.out.println("✅ Fetched " + secrets3.getRecords().size() + " records in " + duration3 + " ms (from server, cache repopulated).");

        } catch (Exception e) {
            System.err.println("❌ Error during caching demo: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
```{{copy}}

### Configure Token (if needed)
-   In `CachingDemo.java`, update `[ONE_TIME_TOKEN_IF_NEEDED]` if your `ksm-config.json` is not yet created.

### Run the Caching Demo

```bash
gradle -PmainClass=com.keepersecurity.ksmsdk.javatutorial.CachingDemo run --console=plain
```
`gradle -PmainClass=com.keepersecurity.ksmsdk.javatutorial.CachingDemo run --console=plain`{{execute}}

### Expected Output:

```
🚀 Demonstrating KSM Secret Caching...

--- First secrets fetch (populates cache) ---
✅ Fetched X records in Y ms (from server, cache populated).

--- Second secrets fetch (should be from cache) ---
✅ Fetched X records in Z ms (from cache).
⚡️ Performance improvement observed due to caching!

Waiting for cache to expire (configured for 60 seconds)...

--- Third secrets fetch (cache expired, should fetch from server again) ---
✅ Fetched X records in W ms (from server, cache repopulated).
```
Note: `Y`, `Z`, `W` will be actual timings. `Z` should be significantly smaller than `Y` and `W`.

## Understanding Advanced Configurations

-   **`InMemoryStorage(base64ConfigString)`**: This constructor of `InMemoryStorage` allows direct initialization from a Base64 string, bypassing the need for `initializeStorage` and a file.
    -   The Base64 string is obtained from the Keeper Vault when setting up a KSM application device with the "Configuration File" method.
    -   This method is ideal for secure, stateless environments.
-   **Caching (`SecretsManagerOptions` constructor)**: 
    -   The `SecretsManagerOptions` constructor has an overload: `SecretsManagerOptions(storage, queryFunction, allowUnverifiedCertificate, clientSideCacheRefreshIntervalSeconds)`.
    -   Setting `clientSideCacheRefreshIntervalSeconds` to a positive value (e.g., `60` for 60 seconds) enables client-side caching.
    -   Cached data is securely stored using the provided `storage` (e.g., in `ksm-config.json` if `LocalConfigStorage` is used).
    -   The SDK automatically manages cache validity. If secrets are fetched and the cache is valid, data is served from the cache. If expired, data is fetched from the server and the cache is updated.

## Conclusion

This step covered advanced KSM SDK configurations. Using in-memory storage is critical for many modern deployment patterns, and caching can significantly enhance the performance of your applications by reducing reliance on network calls for frequently accessed secrets.

This concludes the KSM Java SDK tutorial! Refer to the `finish.md` tab for a summary and next steps.

### Folder Operations

```
touch src/main/java/com/keepersecurity/ksmsample/KSMFolderOperations.java
```{{execute}}

#### Place this code in the created file:

```java
package com.keepersecurity.ksmsample;

import com.keepersecurity.secretsManager.core.*;
import java.util.List;
import java.util.Arrays;

public class KSMFolderOperations {

    public static void listFolders() {
        KeyValueStorage storage = new LocalConfigStorage("ksm-config.json");
        try {
            SecretsManagerOptions options = new SecretsManagerOptions(storage);
            
            // Get all folders
            List<KeeperFolder> folders = SecretsManager.getFolders(options);
            
            System.out.println("Found " + folders.size() + " folders:");
            for (KeeperFolder folder : folders) {
                System.out.println("Folder: " + folder.getName() + 
                                 " (UID: " + folder.getFolderUid() + ")" +
                                 (folder.getParentUid() != null ? 
                                  " Parent: " + folder.getParentUid() : ""));
            }
        } catch (Exception e) {
            System.out.println("Error: " + e.getMessage());
        }
    }

    public static void createFolder() {
        KeyValueStorage storage = new LocalConfigStorage("ksm-config.json");
        try {
            SecretsManagerOptions options = new SecretsManagerOptions(storage);
            
            // Specify parent folder
            CreateOptions createOpts = new CreateOptions(
                "[SHARED_FOLDER_UID]",  // Parent shared folder UID
                null                    // Optional subfolder UID
            );
            
            // Create the new folder
            String newFolderUid = SecretsManager.createFolder(
                options,
                createOpts,
                "My New Folder"  // Folder name
            );
            
            System.out.println("Created folder with UID: " + newFolderUid);
            
        } catch (Exception e) {
            System.out.println("Error: " + e.getMessage());
        }
    }

    public static void updateFolder() {
        KeyValueStorage storage = new LocalConfigStorage("ksm-config.json");
        try {
            SecretsManagerOptions options = new SecretsManagerOptions(storage);
            
            // Update folder name
            SecretsManager.updateFolder(
                options,
                "[FOLDER_UID]",        // Folder to update
                "Updated Folder Name"   // New name
            );
            
            System.out.println("Folder name updated successfully");
            
        } catch (Exception e) {
            System.out.println("Error: " + e.getMessage());
        }
    }

    public static void deleteFolder() {
        KeyValueStorage storage = new LocalConfigStorage("ksm-config.json");
        try {
            SecretsManagerOptions options = new SecretsManagerOptions(storage);
            
            // Delete folders
            SecretsManagerDeleteResponse response = SecretsManager.deleteFolder(
                options,
                Arrays.asList("[FOLDER_UID]"),  // List of folder UIDs to delete
                true                            // Force deletion if not empty
            );
            
            System.out.println("Folder deletion completed");
            
        } catch (Exception e) {
            System.out.println("Error: " + e.getMessage());
        }
    }

    public static void main(String[] args) {
        if (args.length == 0) {
            listFolders();
            return;
        }
        
        switch (args[0]) {
            case "create": createFolder(); break;
            case "update": updateFolder(); break;
            case "delete": deleteFolder(); break;
            default: listFolders();
        }
    }
}
```{{copy}}

### 2. Modify the Code
Replace the following placeholders in the code:

- [SHARED_FOLDER_UID] - UID of the parent shared folder
- [FOLDER_UID] - UID of the folder to update/delete

### 3. List All Folders

Run the code to list existing folders:

```
gradle -PmainClass=com.keepersecurity.ksmsample.KSMFolderOperations run
```{{execute}}

### 4. Create a New Folder

Run the code to create a new folder:

```
gradle -PmainClass=com.keepersecurity.ksmsample.KSMFolderOperations run --args="create"
```{{execute}}

### 5. Update Folder Name

Run the code to update a folder's name:

```
gradle -PmainClass=com.keepersecurity.ksmsample.KSMFolderOperations run --args="update"
```{{execute}}