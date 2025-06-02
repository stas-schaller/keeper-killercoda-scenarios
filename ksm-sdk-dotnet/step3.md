# Step 3: Record Operations, Files & Password Generation

This step covers creating and updating records, full file management (upload, download, delete), and password generation using the KSM .NET SDK.

## 1. Prepare Your Environment

-   Ensure a working `ksm-config.json` or a valid One-Time Token for initial setup.
-   Have the UID of a Shared Folder where your KSM application has **"Can Edit"** permissions.
-   Create a sample file for upload, e.g., `dotnet-sample-upload.txt`.

```bash
echo "This is a .NET SDK test file for upload - Version 2." > dotnet-sample-upload.txt
```
`echo "This is a .NET SDK test file for upload - Version 2." > dotnet-sample-upload.txt`{{execute}}

## 2. Create/Modify C# Class: ManageRecordsAndFiles

```bash
# Example: touch ManageRecordsAndFiles.cs 
# Ensure your Program.cs calls the Main method of this class.
```
`# We will assume you are modifying an existing class or Program.cs directly for this step.`{{execute}}

### Add/Modify the C# Code

Update your C# file with the following. This code demonstrates record creation with password generation, record updates, and full file lifecycle management.

```csharp
using System;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Collections.Generic;
using SecretsManager;
using SecretsManager.Storage; // Required for LocalConfigStorage/MemoryKeyValueStorage

public class ManageRecordsAndFiles // Renamed for clarity
{
    private const string OneTimeToken = "[ONE_TIME_TOKEN_IF_NEEDED]";
    private const string ConfigFileName = "ksm-config.json";
    private const string TargetSharedFolderUid = "[YOUR_SHARED_FOLDER_UID_HERE]"; // ⚠️ Replace
    private const string FileToUploadName = "dotnet-sample-upload.txt";
    private const string DownloadedFileName = "downloaded-dotnet-sample.txt";

    public static async Task Main(string[] args)
    {
        Console.WriteLine("🚀 Record Ops, File Management & Password Generation (.NET SDK)...");
        var storage = new LocalConfigStorage(ConfigFileName);
        SecretsManagerOptions options = null;

        try
        {
            if (!File.Exists(ConfigFileName) && OneTimeToken != "[ONE_TIME_TOKEN_IF_NEEDED]" && !string.IsNullOrEmpty(OneTimeToken))
            {
                Console.WriteLine("🔑 Initializing KSM storage with One-Time Token...");
                SecretsManagerClient.InitializeStorage(storage, OneTimeToken);
            }
            options = new SecretsManagerOptions(storage);

            // --- 1. Create a New Login Record with Generated Password ---
            Console.WriteLine("\n--- Creating New Login Record with Generated Password ---");
            string generatedPassword = SecretsManagerClient.GeneratePassword(length: 20, useUppercase: true, useLowercase: true, useDigits: true, useSpecial: true);
            Console.WriteLine($"🔒 Generated Password: {generatedPassword} (Note: Do not log passwords in production)");

            var newLoginRecordData = new KeeperRecordData
            {
                type = "login",
                title = "My .NET SDK Secure Login",
                notes = "Record with SDK-generated password.",
                fields = new List<KeeperRecordField>
                {
                    new KeeperRecordField { type = "login", value = new object[] { "dotnet.secure@example.com" } },
                    new KeeperRecordField { type = "password", value = new object[] { generatedPassword } },
                    new KeeperRecordField { type = "url", value = new object[] { "https://secure.dotnet.example.com" } }
                }.ToArray()
            };
            string newRecordUid = await SecretsManagerClient.CreateSecretAsync(options, TargetSharedFolderUid, newLoginRecordData);
            Console.WriteLine($"✅ Login Record created! UID: {newRecordUid}, Title: {newLoginRecordData.title}");

            // --- 2. Update the Created Record ---
            Console.WriteLine("\n--- Updating Record Notes & Adding Custom Field ---");
            var secretsForUpdate = await SecretsManagerClient.GetSecretsAsync(options, new[] { newRecordUid });
            var recordToUpdate = secretsForUpdate.Records.FirstOrDefault();
            if (recordToUpdate != null)
            {
                recordToUpdate.Data.notes += "\nUpdated by .NET SDK file/update test.";
                var customFields = recordToUpdate.Data.custom?.ToList() ?? new List<KeeperRecordField>();
                customFields.Add(new KeeperRecordField { type = "text", label = "UpdateStatus", value = new object[] { "Updated " + DateTime.Now.ToString() } });
                recordToUpdate.Data.custom = customFields.ToArray();
                
                await SecretsManagerClient.UpdateSecretAsync(options, recordToUpdate);
                Console.WriteLine($"✅ Record UID: {recordToUpdate.RecordUid} updated successfully.");
            }
            else { Console.WriteLine($"❌ Could not fetch record {newRecordUid} for update."); }

            // --- 3. Upload a File to the Record ---
            Console.WriteLine("\n--- Uploading File ---");
            var targetRecordForUpload = recordToUpdate; // Use the (potentially updated) record object
            if (targetRecordForUpload != null && File.Exists(FileToUploadName))
            {
                var fileBytes = await File.ReadAllBytesAsync(FileToUploadName);
                var fileUpload = new KeeperFileUpload
                {
                    Name = Path.GetFileName(FileToUploadName),
                    Title = "Config Backup - .NET SDK - " + Path.GetFileName(FileToUploadName),
                    Data = fileBytes
                };
                await SecretsManagerClient.UploadFileAsync(options, targetRecordForUpload, fileUpload);
                Console.WriteLine($"✅ File '{fileUpload.Name}' uploaded to record UID: {targetRecordForUpload.RecordUid}.");
                // Re-fetch to get file details in record.Files
                targetRecordForUpload = (await SecretsManagerClient.GetSecretsAsync(options, new[] { newRecordUid })).Records.FirstOrDefault();
            }
            else if (targetRecordForUpload == null) { Console.WriteLine("❌ Target record not available for upload."); }
            else { Console.WriteLine($"❌ Sample file '{FileToUploadName}' not found for upload."); }

            // --- 4. Download the File ---
            KeeperFile fileToDownload = null;
            if (targetRecordForUpload?.Files != null && targetRecordForUpload.Files.Any()){
                fileToDownload = targetRecordForUpload.Files.FirstOrDefault(f => f.Data.name == FileToUploadName);
            }
            if (fileToDownload != null)
            {
                Console.WriteLine($"\n--- Downloading File: {fileToDownload.Data.title} ---");
                var downloadedBytes = await SecretsManagerClient.DownloadFileAsync(options, fileToDownload);
                await File.WriteAllBytesAsync(DownloadedFileName, downloadedBytes);
                Console.WriteLine($"✅ File downloaded to: {DownloadedFileName} (Size: {downloadedBytes.Length} bytes)");
            }
            else { Console.WriteLine("\nℹ️ File not found on record for download or record not available."); }

            // --- 5. Delete the File from Record ---
            if (fileToDownload != null) // We need the KeeperFile object or at least its UID
            {
                Console.WriteLine($"\n--- Deleting File: {fileToDownload.Data.title} (UID: {fileToDownload.Uid}) from record ---");
                // The DeleteFileAsync typically needs the record object and the file UID or KeeperFile object
                await SecretsManagerClient.DeleteFileAsync(options, targetRecordForUpload, fileToDownload.Uid);
                Console.WriteLine($"✅ File UID: {fileToDownload.Uid} deleted from record UID: {targetRecordForUpload.RecordUid}.");
                // Verify by re-fetching
                var recordAfterFileDelete = (await SecretsManagerClient.GetSecretsAsync(options, new[] { newRecordUid })).Records.FirstOrDefault();
                Console.WriteLine($"    Files remaining on record: {recordAfterFileDelete?.Files?.Count ?? 0}");
            }
            else { Console.WriteLine("\nℹ️ File not available on record for deletion."); }

            Console.WriteLine("\n🎉 Record operations, file management, and password generation examples complete.");
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

-   In your C# file (e.g., `ManageRecordsAndFiles.cs` or `Program.cs`):
    -   Replace `[ONE_TIME_TOKEN_IF_NEEDED]` if `ksm-config.json` doesn't exist.
    -   **Crucial**: Replace `[YOUR_SHARED_FOLDER_UID_HERE]` with the UID of a Shared Folder with "Can Edit" permissions.

## 4. Update `Program.cs` (if using a separate class)

If you created `ManageRecordsAndFiles.cs` separately, ensure `Program.cs` calls its `Main` method:
```csharp
// Program.cs
using System.Threading.Tasks;
public class Program
{
    public static async Task Main(string[] args)
    {
        await ManageRecordsAndFiles.Main(args);
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
🚀 Record Ops, File Management & Password Generation (.NET SDK)...

--- Creating New Login Record with Generated Password ---
🔒 Generated Password: <A_STRONG_GENERATED_PASSWORD>
✅ Login Record created! UID: ..., Title: My .NET SDK Secure Login

--- Updating Record Notes & Adding Custom Field ---
✅ Record UID: ... updated successfully.

--- Uploading File ---
✅ File 'dotnet-sample-upload.txt' uploaded to record UID: ...

--- Downloading File: Config Backup - .NET SDK - dotnet-sample-upload.txt ---
✅ File downloaded to: downloaded-dotnet-sample.txt (Size: ... bytes)

--- Deleting File: Config Backup - .NET SDK - dotnet-sample-upload.txt (UID: ...) from record ---
✅ File UID: ... deleted from record UID: ...
    Files remaining on record: 0

🎉 Record operations, file management, and password generation examples complete.
```

## Understanding the Code

-   **`SecretsManagerClient.GeneratePassword()`**: Generates strong, random passwords. Overloads exist for more specific criteria.
-   **Record Creation (`SecretsManagerClient.CreateSecretAsync`)**: As before, but now using the generated password.
-   **Record Update (`SecretsManagerClient.UpdateSecretAsync`)**: 
    1.  Fetch the `KeeperRecord` to update.
    2.  Modify its `Data` properties (e.g., `record.Data.notes`, add/update `KeeperRecordField` in `record.Data.fields` or `record.Data.custom`).
    3.  Call `UpdateSecretAsync` with the modified `KeeperRecord` object.
-   **File Upload (`SecretsManagerClient.UploadFileAsync`)**: Uploads a `KeeperFileUpload` object to a `KeeperRecord`.
-   **File Download (`SecretsManagerClient.DownloadFileAsync`)**: Downloads a `KeeperFile` (obtained from `record.Files`) and returns its content as `byte[]`.
-   **File Deletion (`SecretsManagerClient.DeleteFileAsync`)**: Deletes a specific file from a record, usually by providing the `KeeperRecord` and the `fileUid` (from the `KeeperFile` object).

## Next Steps

In the next step, we'll cover Folder Management (create, list, update, delete folders) and demonstrate how to delete entire records.