# Step 4: Folder Management, Record Deletion & Caching

This step covers managing folders (create, list, update, delete), deleting records, and implementing client-side caching using the KSM .NET SDK.

## 1. Prepare Your Environment

-   Ensure a working `ksm-config.json` or a valid One-Time Token for initial setup.
-   Have the UID of a Shared Folder where your KSM application has **"Can Edit"** permissions. This will be the parent for new folders.

## 2. Create/Modify C# Class: AdvancedKsmOperations

```bash
# Example: touch AdvancedKsmOperations.cs
# Ensure your Program.cs calls the Main method of this class.
```
`# We will assume you are modifying an existing class or Program.cs directly for this step.`{{execute}}

### Add/Modify the C# Code

Update your C# file with the following. This code demonstrates folder operations, record deletion, and caching.

```csharp
using System;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using System.Collections.Generic;
using SecretsManager;
using SecretsManager.Storage;

public class AdvancedKsmOperations // Renamed for clarity
{
    private const string OneTimeToken = "[ONE_TIME_TOKEN_IF_NEEDED]";
    private const string ConfigFileName = "ksm-config.json";
    private const string ParentSharedFolderUid = "[YOUR_PARENT_SHARED_FOLDER_UID_HERE]"; // ⚠️ Replace
    private static string _tempRecordUidForDeletionTest = null; // To store UID of record created for deletion test

    public static async Task Main(string[] args)
    {
        Console.WriteLine("🚀 Folder Management, Record Deletion & Caching (.NET SDK)...");
        var storage = new LocalConfigStorage(ConfigFileName);
        SecretsManagerOptions options = null;

        // --- Setup Caching Options ---
        // Cache for 60 seconds. The SDK uses the provided storage (e.g., LocalConfigStorage) to persist cache data.
        var optionsWithCache = new SecretsManagerOptions(storage, clientSideCacheRefreshIntervalSeconds: 60);

        try
        {
            if (!File.Exists(ConfigFileName) && OneTimeToken != "[ONE_TIME_TOKEN_IF_NEEDED]" && !string.IsNullOrEmpty(OneTimeToken))
            {
                Console.WriteLine("🔑 Initializing KSM storage with One-Time Token...");
                SecretsManagerClient.InitializeStorage(storage, OneTimeToken);
            }
            // Use optionsWithCache for all operations in this step to demonstrate caching
            options = optionsWithCache; 

            Console.WriteLine("\n--- Test Caching: First call (populates cache) ---");
            var initialSecrets = await SecretsManagerClient.GetSecretsAsync(options);
            Console.WriteLine($"    Fetched {initialSecrets.Records.Count} records initially.");

            Console.WriteLine("\n--- Test Caching: Second call (should use cache) ---");
            var cachedSecrets = await SecretsManagerClient.GetSecretsAsync(options);
            Console.WriteLine($"    Fetched {cachedSecrets.Records.Count} records from cache potentially.");


            // --- 1. Folder Management ---
            Console.WriteLine("\n--- Folder Management Operations ---");
            string newFolderUid = null;
            string createdFolderName = null;

            // a. Create a new folder
            string folderNameToCreate = $"DotNetSDK_DemoFolder_{DateTimeOffset.UtcNow.ToUnixTimeSeconds()}";
            Console.WriteLine($"📁 Creating folder: {folderNameToCreate} under parent UID: {ParentSharedFolderUid}");
            
            var createOptions = new FolderCreateOptions { FolderUid = ParentSharedFolderUid };
            var createdFolder = await SecretsManagerClient.CreateFolderAsync(options, createOptions, folderNameToCreate);
            newFolderUid = createdFolder.Uid;
            createdFolderName = createdFolder.Name; // Use the name from the response
            Console.WriteLine($"✅ Folder '{createdFolderName}' created! UID: {newFolderUid}");

            // b. List all folders
            Console.WriteLine("\n--- Listing Folders ---");
            var folders = await SecretsManagerClient.GetFoldersAsync(options);
            Console.WriteLine($"🔍 Found {folders.Count} folder(s):");
            foreach (var folder in folders)
            {
                Console.WriteLine($"  - Name: {folder.Name}, UID: {folder.Uid}, Parent UID: {folder.ParentUid}");
            }

            // c. Update (rename) the created folder
            string updatedFolderName = createdFolderName + "_Renamed";
            Console.WriteLine($"\n✏️ Renaming folder '{createdFolderName}' (UID: {newFolderUid}) to '{updatedFolderName}'");
            var folderUpdateOptions = new FolderUpdateOptions { Name = updatedFolderName };
            await SecretsManagerClient.UpdateFolderAsync(options, newFolderUid, folderUpdateOptions);
            Console.WriteLine($"✅ Folder {newFolderUid} renamed to '{updatedFolderName}'.");

            // --- 2. Create a Record in the New Folder (for deletion test) ---
            Console.WriteLine("\n--- Creating a Test Record for Deletion ---");
            var testRecordData = new KeeperRecordData
            {
                type = "login",
                title = "DotNetSDK_ToDelete_InFolder",
                fields = new List<KeeperRecordField> { new KeeperRecordField { type = "login", value = new object[] { "delete_me_dotnet@example.com" } } }.ToArray()
            };
            _tempRecordUidForDeletionTest = await SecretsManagerClient.CreateSecretAsync(options, newFolderUid, testRecordData);
            Console.WriteLine($"✅ Test record '{testRecordData.title}' created in folder {newFolderUid}. UID: {_tempRecordUidForDeletionTest}");

            // --- 3. Delete the Test Record ---
            if (!string.IsNullOrEmpty(_tempRecordUidForDeletionTest))
            {
                Console.WriteLine($"\n--- Deleting Test Record (UID: {_tempRecordUidForDeletionTest}) ---");
                var deleteResult = await SecretsManagerClient.DeleteSecretsAsync(options, new[] { _tempRecordUidForDeletionTest });
                if (deleteResult.Responses.Any(r => r.RecordUid == _tempRecordUidForDeletionTest && r.Status.Equals("success", StringComparison.OrdinalIgnoreCase)))
                {
                    Console.WriteLine($"✅ Record {_tempRecordUidForDeletionTest} deleted successfully.");
                }
                else { Console.WriteLine($"⚠️ Record {_tempRecordUidForDeletionTest} deletion may have failed: {string.Join("; ", deleteResult.Responses.Select(r => r.Message))}"); }
                _tempRecordUidForDeletionTest = null; // Clear it after deletion attempt
            }

            // --- 4. Delete the Created Folder ---
            // Note: Keeper typically requires folders to be empty before deletion unless a force option is used (SDK dependent)
            // The .NET SDK DeleteFolderAsync has a 'force' parameter.
            Console.WriteLine($"\n--- Deleting Folder '{updatedFolderName}' (UID: {newFolderUid}) ---");
            var folderDeleteResult = await SecretsManagerClient.DeleteFolderAsync(options, new[] { newFolderUid }, force: true);
            if (folderDeleteResult.Responses.Any(r => r.FolderUid == newFolderUid && r.Status.Equals("success", StringComparison.OrdinalIgnoreCase)))
            {
                Console.WriteLine($"✅ Folder {newFolderUid} deleted successfully.");
            }
            else { Console.WriteLine($"⚠️ Folder {newFolderUid} deletion may have failed: {string.Join("; ", folderDeleteResult.Responses.Select(r => r.Message))}"); }

            Console.WriteLine("\n🎉 Folder management, record deletion, and caching examples complete.");
        }
        catch (Exception ex)
        {
            Console.ForegroundColor = ConsoleColor.Red;
            Console.WriteLine($"❌ GENERAL ERROR: {ex.Message}\n{ex.StackTrace}");
            Console.ResetColor();
        }
    }
}
```{{copy}}

## 3. Configure Placeholders

-   In your C# file (e.g., `AdvancedKsmOperations.cs` or `Program.cs`):
    -   Replace `[ONE_TIME_TOKEN_IF_NEEDED]` if `ksm-config.json` doesn't exist.
    -   **Crucial**: Replace `[YOUR_PARENT_SHARED_FOLDER_UID_HERE]` with the UID of a Shared Folder where your KSM application has "Can Edit" permissions. This will be the parent for folders created in the script.

## 4. Update `Program.cs` (if using a separate class)

If you created `AdvancedKsmOperations.cs` separately, ensure `Program.cs` calls its `Main` method:
```csharp
// Program.cs
using System.Threading.Tasks;
public class Program
{
    public static async Task Main(string[] args)
    {
        // Comment out or remove previous step calls
        // await ManageRecordsAndFiles.Main(args); 
        await AdvancedKsmOperations.Main(args);
    }
}
```

## 5. Run the Application

```bash
dotnet run
```
`dotnet run`{{execute}}

### Expected Output:

```
🚀 Folder Management, Record Deletion & Caching (.NET SDK)...

--- Test Caching: First call (populates cache) ---
    Fetched X records initially.

--- Test Caching: Second call (should use cache) ---
    Fetched X records from cache potentially.

--- Folder Management Operations ---
📁 Creating folder: DotNetSDK_DemoFolder_...
✅ Folder 'DotNetSDK_DemoFolder_...' created! UID: ...

--- Listing Folders ---
🔍 Found Y folder(s):
  - Name: DotNetSDK_DemoFolder_..., UID: ..., Parent UID: YOUR_PARENT_SHARED_FOLDER_UID_HERE
  ...

✏️ Renaming folder 'DotNetSDK_DemoFolder_...' (UID: ...) to 'DotNetSDK_DemoFolder_..._Renamed'
✅ Folder ... renamed to 'DotNetSDK_DemoFolder_..._Renamed'.

--- Creating a Test Record for Deletion ---
✅ Test record 'DotNetSDK_ToDelete_InFolder' created in folder .... UID: ...

--- Deleting Test Record (UID: ...) ---
✅ Record ... deleted successfully.

--- Deleting Folder 'DotNetSDK_DemoFolder_..._Renamed' (UID: ...) ---
✅ Folder ... deleted successfully.

🎉 Folder management, record deletion, and caching examples complete.
```

## Understanding the Code

-   **Caching (`SecretsManagerOptions`)**: Caching is enabled by setting `clientSideCacheRefreshIntervalSeconds` in `SecretsManagerOptions`. The SDK uses the provided `storage` (e.g., `LocalConfigStorage`) to persist cached data if applicable (though for `LocalConfigStorage` the cache might primarily reside in memory for the duration of the client object if not explicitly file-backed by the SDK's cache implementation details).
-   **Folder Creation (`SecretsManagerClient.CreateFolderAsync`)**: Creates a new folder. Requires `FolderCreateOptions` to specify the parent shared folder context (`FolderUid`) and optionally a `SubFolderUid` for nesting.
-   **Listing Folders (`SecretsManagerClient.GetFoldersAsync`)**: Retrieves folders accessible to the KSM application.
-   **Updating Folders (`SecretsManagerClient.UpdateFolderAsync`)**: Renames a folder using `FolderUpdateOptions`.
-   **Record Deletion (`SecretsManagerClient.DeleteSecretsAsync`)**: Deletes records given an array of their UIDs.
-   **Folder Deletion (`SecretsManagerClient.DeleteFolderAsync`)**: Deletes folders. The `force: true` parameter attempts to delete non-empty folders (behavior can depend on backend rules).

## Conclusion

This step demonstrated folder management, record deletion, and client-side caching. These are essential for organizing secrets, cleaning up, and optimizing performance in your .NET applications using Keeper Secrets Manager.

This completes the KSM .NET SDK tutorial! Please review the `finish.md` tab for a summary and best practices. 