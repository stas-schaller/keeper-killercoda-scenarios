# Step 1: Setup & Basic Connection

This step will guide you through creating a new .NET Console Application, installing the Keeper Secrets Manager (KSM) .NET SDK via NuGet, and writing your first C# program to connect to Keeper and list all shared secrets.

## 1. Create a New .NET Project

Open your terminal or command prompt and create a new .NET console application:

```bash
dotnet new console -o KsmNetTutorial -f net8.0
cd KsmNetTutorial
```
`dotnet new console -o KsmNetTutorial -f net8.0 && cd KsmNetTutorial`{{execute}}

This creates a new project named `KsmNetTutorial` targeting .NET 8 and navigates into the project directory.

## 2. Install the KSM .NET SDK NuGet Package

Add the `Keeper.SecretsManager` package to your project:

```bash
dotnet add package Keeper.SecretsManager
```
`dotnet add package Keeper.SecretsManager`{{execute}}

This command fetches the latest stable version of the SDK from NuGet and adds it as a dependency to your project.

## 3. Write Your First KSM Application: List All Secrets

Now, replace the content of your `Program.cs` file with the following C# code. This program will initialize the KSM client, connect to Keeper, and list basic information about all secrets shared with your KSM application.

```csharp
using System;
using System.Linq;
using System.Text.Json;
using System.Threading.Tasks;
using SecretsManager;

public class Program
{
    // ⚠️ IMPORTANT: Replace with your actual One-Time Token from Keeper Vault
    private const string OneTimeToken = "[ONE_TIME_TOKEN_HERE]";
    private const string ConfigFileName = "ksm-config.json";

    public static async Task Main(string[] args)
    {
        Console.WriteLine("🚀 Attempting to connect to Keeper and list secrets...");

        // Use LocalConfigStorage for storing KSM configuration locally
        var storage = new LocalConfigStorage(ConfigFileName);

        try
        {
            // Initialize storage with the One-Time Token (only needed for the first run)
            // Subsequent runs will use the generated ksm-config.json
            Console.WriteLine("🔑 Initializing KSM storage with token (if first run)...");
            SecretsManagerClient.InitializeStorage(storage, OneTimeToken);
            Console.WriteLine($"💾 Storage initialized. Using config: {ConfigFileName}");

            // Set up options for the SecretsManager client
            var options = new SecretsManagerOptions(storage);

            // Retrieve all secrets shared with this application
            Console.WriteLine("📡 Fetching all secrets...");
            var secrets = await SecretsManagerClient.GetSecretsAsync(options);

            Console.WriteLine($"✅ Successfully fetched {secrets.Records.Count} record(s):");

            if (!secrets.Records.Any())
            {
                Console.WriteLine("\nℹ️ No records found. Ensure records are shared with your KSM application in the Keeper Vault.");
            }
            else
            {
                Console.WriteLine("\n--- All Shared Records ---");
                int count = 0;
                foreach (var record in secrets.Records)
                {
                    count++;
                    Console.WriteLine($"[{count}] Record UID: {record.RecordUid}");
                    Console.WriteLine($"    Title: {record.Data?.title}"); // Access title via record.Data.title
                    Console.WriteLine($"    Type: {record.Data?.type}");   // Access type via record.Data.type
                    Console.WriteLine($"    Fields Count: {(record.Data?.fields?.Length ?? 0) + (record.Data?.custom?.Length ?? 0)}");
                    Console.WriteLine($"    Files Count: {record.Files?.Count ?? 0}");
                    Console.WriteLine("---");
                }
            }
        }
        catch (Exception ex)
        {
            Console.ForegroundColor = ConsoleColor.Red;
            Console.WriteLine($"❌ Error: {ex.Message}");
            Console.ResetColor();
            Console.WriteLine("\n💡 Troubleshooting Tips:");
            Console.WriteLine("- Ensure your ONE_TIME_TOKEN is correct and has not been used before.");
            Console.WriteLine("- Check network connectivity to Keeper servers.");
            Console.WriteLine("- Verify that records are shared with the KSM application in your Keeper Vault.");
            // For more details, you might want to log ex.ToString() in a real application
        }
    }
}
```{{copy}}

## 4. Configure Your One-Time Token

-   In the `Program.cs` file, **replace `[ONE_TIME_TOKEN_HERE]`** with a valid One-Time Token from your Keeper Vault.
    -   To get a token: Log into Keeper Web Vault -> Secrets Manager -> Applications -> Select/Create Application -> Devices -> Add Device -> Method: One-Time Token.

## 5. Run the Application

Execute your .NET application from the terminal:

```bash
dotnet run
```
`dotnet run`{{execute}}

### Expected Output:

You should see a list of your shared secrets' UIDs, titles, and types, or an appropriate error message.

```
🚀 Attempting to connect to Keeper and list secrets...
🔑 Initializing KSM storage with token (if first run)...
💾 Storage initialized. Using config: ksm-config.json
📡 Fetching all secrets...
✅ Successfully fetched X record(s):

--- All Shared Records ---
[1] Record UID: abcXYZ123...
    Title: My Sample Login
    Type: login
    Fields Count: 2
    Files Count: 1
---
...
```

## Understanding the Code

-   **`LocalConfigStorage`**: This class manages the `ksm-config.json` file, which stores encrypted application keys and connection details locally after the first successful token-based initialization.
-   **`SecretsManagerClient.InitializeStorage(storage, OneTimeToken)`**: Crucial for the first run. It uses the One-Time Token to securely establish a persistent configuration in `ksm-config.json`.
-   **`SecretsManagerOptions`**: Configures the KSM client, primarily by providing the storage mechanism.
-   **`SecretsManagerClient.GetSecretsAsync(options)`**: Asynchronously fetches all records shared with the KSM application.
-   **`KeeperSecrets` & `KeeperRecord`**: 
    -   `KeeperSecrets.Records` is a list of `KeeperRecord` objects.
    -   Each `KeeperRecord` object has a `RecordUid` property and a `Data` property of type `KeeperRecordData`.
    -   The `KeeperRecordData` object contains `title`, `type`, `notes`, `fields` (an array of standard fields), and `custom` (an array of custom fields).
    -   Files are accessed via `KeeperRecord.Files`.

## Troubleshooting

-   **Token Already Used/Invalid**: Ensure your One-Time Token is new and correctly copied.
-   **No Records Found**: Verify in your Keeper Vault that records are shared with the KSM application whose token you are using.
-   **Network Issues**: Check internet connectivity and any firewalls that might block access to Keeper servers (typically `keepersecurity.com` or regional variants).
-   **.NET Build Errors**: Ensure the `Keeper.SecretsManager` NuGet package is correctly installed. Run `dotnet restore` if needed.

In the next step, we'll dive deeper into retrieving specific secrets and accessing their field values in detail.