# Step 3: Creating Records & Files, and Advanced Config

This step covers creating new records with various field types, managing file attachments, and introduces the concept of in-memory configuration for secure deployments using the KSM .NET SDK.

## 1. Prepare Your Environment

-   Ensure a working `ksm-config.json` or a valid One-Time Token for initial setup.
-   Have the UID of a Shared Folder where your KSM application has **"Can Edit"** permissions. New records will be created here.
-   Create a sample file for upload, e.g., `dotnet-sample-upload.txt`.

```bash
echo "This is a .NET SDK test file for upload." > dotnet-sample-upload.txt
```
`echo "This is a .NET SDK test file for upload." > dotnet-sample-upload.txt`{{execute}}

## 2. Create C# Class: CreateAndManageSecrets

```bash
touch CreateAndManageSecrets.cs
```
`touch CreateAndManageSecrets.cs`{{execute}}

### Add the C# Code

Paste the following into `CreateAndManageSecrets.cs`. This class demonstrates creating records, adding fields, and uploading files.

```csharp
using System;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using System.Collections.Generic;
using SecretsManager;

public class CreateAndManageSecrets
{
    private const string OneTimeToken = "[ONE_TIME_TOKEN_IF_NEEDED]";
    private const string ConfigFileName = "ksm-config.json";
    // ⚠️ Replace with UID of a Shared Folder with "Can Edit" permissions for your KSM App
    private const string TargetSharedFolderUid = "[YOUR_SHARED_FOLDER_UID_HERE]";
    private const string FileToUploadName = "dotnet-sample-upload.txt";

    public static async Task Main(string[] args)
    {
        Console.WriteLine("🚀 Creating records, managing files, and discussing advanced config...");
        var storage = new LocalConfigStorage(ConfigFileName);

        try
        {
            if (!File.Exists(ConfigFileName) || OneTimeToken != "[ONE_TIME_TOKEN_IF_NEEDED]")
            {
                Console.WriteLine("🔑 Initializing KSM storage...");
                SecretsManagerClient.InitializeStorage(storage, OneTimeToken);
            }
            var options = new SecretsManagerOptions(storage);

            // --- 1. Create a New Login Record with Standard and Custom Fields ---
            Console.WriteLine("\n--- Creating New Login Record ---");
            var newLoginRecord = new KeeperRecordData
            {
                type = "login",
                title = "My .NET Auto-Created Login",
                notes = "This record was created by the .NET KSM SDK tutorial.",
                fields = new List<KeeperRecordField>
                {
                    new KeeperRecordField { type = "login", value = new object[] { "dotnet_user@example.com" } },
                    new KeeperRecordField { type = "password", value = new object[] { SecretsManagerClient.GeneratePassword() } }, // Generate a secure password
                    new KeeperRecordField { type = "url", value = new object[] { "https://autogen.example.com" } }
                }.ToArray(),
                custom = new List<KeeperRecordField>
                {
                    new KeeperRecordField { type = "text", label = "ServiceID", value = new object[] { "svc-dotnet-12345" } },
                    new KeeperRecordField { type = "secret", label = "APISecretKey", value = new object[] { SecretsManagerClient.GeneratePassword(24) } } // Custom secret field
                }.ToArray()
            };

            string newLoginRecordUid = await SecretsManagerClient.CreateSecretAsync(options, TargetSharedFolderUid, newLoginRecord);
            Console.WriteLine($"✅ Login Record created successfully! UID: {newLoginRecordUid}, Title: {newLoginRecord.title}");

            // --- 2. Upload a File to the Newly Created Login Record ---
            Console.WriteLine("\n--- Uploading File to New Login Record ---");
            if (File.Exists(FileToUploadName))
            {
                var fileBytes = await File.ReadAllBytesAsync(FileToUploadName);
                var fileUpload = new KeeperFileUpload
                {
                    Name = Path.GetFileName(FileToUploadName),
                    Title = "Config Backup - .NET SDK",
                    // Type = "text/plain", // SDK often infers or it can be set
                    Data = fileBytes
                };

                // Fetch the record we just created to ensure we have the full KeeperRecord object
                var secretsForUpload = await SecretsManagerClient.GetSecretsAsync(options, new[] { newLoginRecordUid });
                var targetRecordForUpload = secretsForUpload.Records.FirstOrDefault();

                if (targetRecordForUpload != null)
                {
                    await SecretsManagerClient.UploadFileAsync(options, targetRecordForUpload, fileUpload);
                    Console.WriteLine($"✅ File '{fileUpload.Name}' uploaded successfully to record UID: {newLoginRecordUid}.");

                    // Verify by listing files for that record
                    var updatedRecordSecrets = await SecretsManagerClient.GetSecretsAsync(options, new[] { newLoginRecordUid });
                    var updatedRecord = updatedRecordSecrets.Records.FirstOrDefault();
                    if (updatedRecord?.Files != null && updatedRecord.Files.Any(f => f.Data.name == FileToUploadName))
                    {
                        Console.WriteLine("    Verification: File found on record after upload.");
                    }
                }
                else { Console.WriteLine($"❌ Could not re-fetch record {newLoginRecordUid} for file upload.");}
            }
            else
            {
                Console.WriteLine($"❌ Sample file '{FileToUploadName}' not found for upload.");
            }
            
            // --- 3. In-Memory Configuration (Conceptual Overview) ---
            Console.WriteLine("\n--- In-Memory Configuration (Conceptual) ---");
            Console.WriteLine("For production, especially in containers or serverless, use InMemoryStorage.");
            Console.WriteLine("1. Get Base64 config string from Keeper Vault (Application -> Devices -> Add Device -> Configuration File).");
            Console.WriteLine("2. Store this string securely (e.g., environment variable, managed config service).");
            Console.WriteLine("3. Initialize: var inMemStorage = new InMemoryStorage(yourBase64ConfigString);");
            Console.WriteLine("4. var opts = new SecretsManagerOptions(inMemStorage);");
            Console.WriteLine("This avoids needing ksm-config.json on the filesystem.");

            // --- 4. Caching (Conceptual Overview) ---
            Console.WriteLine("\n--- Caching Secrets (Conceptual) ---");
            Console.WriteLine("To enable caching, set ClientSideCacheRefreshIntervalSeconds in SecretsManagerOptions:");
            Console.WriteLine("var optionsWithCache = new SecretsManagerOptions(storage, clientSideCacheRefreshIntervalSeconds: 60);");
            Console.WriteLine("SDK then handles caching data using the provided storage for 60 seconds.");

            Console.WriteLine("\n🎉 Record creation and file management examples complete. Check your Keeper Vault!");
        }
        catch (Exception ex)
        {
            Console.ForegroundColor = ConsoleColor.Red;
            Console.WriteLine($"❌ Error: {ex.Message}");
            Console.ResetColor();
        }
    }
}
```{{copy}}

## 3. Configure Shared Folder UID

-   In `CreateAndManageSecrets.cs`:
    -   **Crucial**: Replace `[YOUR_SHARED_FOLDER_UID_HERE]` with the UID of a Shared Folder in your Keeper Vault where your KSM application has **"Can Edit"** permissions.
    -   If needed, update `[ONE_TIME_TOKEN_IF_NEEDED]`.

## 4. Update `Program.cs` to Run This Example

Modify `Program.cs` to call the `Main` method of `CreateAndManageSecrets`.

```csharp
using System.Threading.Tasks;

public class Program
{
    public static async Task Main(string[] args)
    {
        // Comment out other examples if you ran them
        // await ListAllSecrets.Main(args);
        // await GetSpecificDotNetSecret.Main(args);
        
        // Current example: Step 3 - CreateAndManageSecrets
        await CreateAndManageSecrets.Main(args);
    }
}
```{{copy}}

## 5. Run the Application

```bash
dotnet run
```
`dotnet run`{{execute}}

### Expected Output:

```
🚀 Creating records, managing files, and discussing advanced config...

--- Creating New Login Record ---
✅ Login Record created successfully! UID: ..., Title: My .NET Auto-Created Login

--- Uploading File to New Login Record ---
✅ File 'dotnet-sample-upload.txt' uploaded successfully to record UID: ...
    Verification: File found on record after upload.

--- In-Memory Configuration (Conceptual) ---
...

--- Caching Secrets (Conceptual) ---
...

🎉 Record creation and file management examples complete. Check your Keeper Vault!
```

**Verify**: Check your Keeper Vault. A new record titled "My .NET Auto-Created Login" should exist in your target shared folder, with fields populated and `dotnet-sample-upload.txt` attached.

## Understanding the Code

-   **`KeeperRecordData`**: This class is used to define the structure for a new record.
    -   `type`: Specifies the record type (e.g., "login", "bankAccount", or a custom type string).
    -   `title`: The display title of the record.
    -   `fields`: An array of `KeeperRecordField` objects for standard fields.
    -   `custom`: An array of `KeeperRecordField` objects for custom fields.
    -   `notes`: Text notes for the record.
-   **`KeeperRecordField`**: 
    -   `type`: The specific type of the field (e.g., "login", "password", "text", "url", "secret").
    -   `label`: For custom fields, this is the label you see in the UI. For standard fields, it can often be omitted if the `type` is self-descriptive.
    -   `value`: An `object[]` array. For simple text-based fields, this usually contains a single string element (e.g., `new object[] { "your_value" }`).
-   **`SecretsManagerClient.GeneratePassword()`**: A utility to generate strong, random passwords.
-   **`SecretsManagerClient.CreateSecretAsync(options, folderUid, recordData)`**: Creates the new record in the specified `folderUid`.
-   **`KeeperFileUpload`**: Prepares a file for upload, including its `Name` (filename), `Title` (display name in Keeper), and `Data` (byte array of file content).
-   **`SecretsManagerClient.UploadFileAsync(options, keeperRecord, fileUpload)`**: Uploads the file to the specified `KeeperRecord`.
    -   **Important**: You typically need to fetch/re-fetch the `KeeperRecord` object before uploading to ensure you have its full, up-to-date state from the server, especially its `RecordKey` which is used in the encryption process for the file.
-   **In-Memory Configuration**: The code includes a conceptual overview. The key is `new InMemoryStorage(yourBase64ConfigString)` passed to `SecretsManagerOptions`. This avoids file system dependency for the KSM config.
-   **Caching**: Also a conceptual overview. Enable by setting `ClientSideCacheRefreshIntervalSeconds` in `SecretsManagerOptions`. For example, `new SecretsManagerOptions(storage, clientSideCacheRefreshIntervalSeconds: 60)` enables caching for 60 seconds.

## Conclusion

This step demonstrated creating records with diverse field types, handling file attachments, and introduced advanced configuration patterns like in-memory storage and caching. These capabilities allow for powerful and secure automation of secret management within your .NET applications.

This completes the KSM .NET SDK tutorial! Please review the `finish.md` tab for a summary of what you've learned and best practices for production.