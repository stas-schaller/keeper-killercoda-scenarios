# Step 1: Setup, Configuration & Basic Connection

This step guides you through creating a .NET application, installing the KSM SDK, and connecting to Keeper using both file-based (token-initialized) and in-memory (Base64 string) configurations to list shared secrets.

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

## 3. Write Your KSM Application: Configuration Options

Replace the content of `Program.cs` with the following C# code:

```csharp
using System;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using SecretsManager;
using SecretsManager.Storage;

public class Program
{
    // --- Option 1: File-Based Configuration (using One-Time Token for first run) ---
    // Replace with your actual One-Time Token for initial file setup
    private const string OneTimeTokenFile = "[ONE_TIME_TOKEN_FOR_FILE_CONFIG]"; 
    private const string ConfigFileName = "ksm-config.json";

    // --- Option 2: In-Memory Configuration (using Base64 encoded config string) ---
    // Replace with your Base64 encoded KSM configuration string
    // Obtain from Keeper Vault: Secrets Manager -> Applications -> (Your App) -> Devices -> Add Device -> Configuration File
    private const string KsmConfigBase64 = "[YOUR_KSM_CONFIG_BASE64_STRING_HERE]";

    public static async Task Main(string[] args)
    {
        Console.WriteLine("🚀 KSM .NET SDK Tutorial - Step 1: Configuration & Listing Secrets");

        // --- Try File-Based Configuration ---
        Console.WriteLine("\n--- Attempting File-Based Configuration ---");
        try
        {
            var fileStorage = new LocalConfigStorage(ConfigFileName);
            // Initialize storage if the config file doesn't exist and a valid token is provided.
            if (!File.Exists(ConfigFileName) && !string.IsNullOrEmpty(OneTimeTokenFile) && OneTimeTokenFile != "[ONE_TIME_TOKEN_FOR_FILE_CONFIG]")
            {
                Console.WriteLine("🔑 Initializing KSM File Storage with One-Time Token...");
                SecretsManagerClient.InitializeStorage(fileStorage, OneTimeTokenFile);
                Console.WriteLine($"💾 File Storage initialized. Config will be saved to: {ConfigFileName}");
            } 
            else if (File.Exists(ConfigFileName))
            {
                 Console.WriteLine($"💾 Using existing File Storage config: {ConfigFileName}");
            }
            else
            {
                Console.WriteLine("ℹ️ Skipping File-Based initialization: Token not provided or placeholder not replaced, and no existing config file.");
                // Optionally, attempt to use it anyway if file might exist without prior init log
            }
            
            // Proceed if config file exists or was just initialized
            if (File.Exists(ConfigFileName) || (fileStorage != null && SecretsManagerClient.IsStorageInitialized(fileStorage))) // Second check might be redundant if init creates file
            {
                var fileOptions = new SecretsManagerOptions(fileStorage);
                await ListSecretsAsync(fileOptions, "File-Based Config");
            }
            else
            {
                 Console.WriteLine("❌ File-based storage not initialized or config file not found.");
            }
        }
        catch (Exception ex)
        {
            Console.ForegroundColor = ConsoleColor.Red;
            Console.WriteLine($"❌ Error with File-Based Config: {ex.Message}");
            Console.ResetColor();
        }

        // --- Try In-Memory Configuration ---
        Console.WriteLine("\n\n--- Attempting In-Memory Configuration ---");
        if (!string.IsNullOrEmpty(KsmConfigBase64) && KsmConfigBase64 != "[YOUR_KSM_CONFIG_BASE64_STRING_HERE]")
        {
            try
            {
                Console.WriteLine("🧠 Initializing KSM with In-Memory Storage (from Base64 string)...");
                var memoryStorage = new MemoryKeyValueStorage(KsmConfigBase64);
                // Token is not needed here as the Base64 config contains all necessary keys
                var memoryOptions = new SecretsManagerOptions(memoryStorage);
                Console.WriteLine("💾 In-Memory storage initialized successfully from Base64 config.");
                await ListSecretsAsync(memoryOptions, "In-Memory Config (Base64)");
            }
            catch (Exception ex)
            {
                Console.ForegroundColor = ConsoleColor.Red;
                Console.WriteLine($"❌ Error with In-Memory Config: {ex.Message}");
                Console.ResetColor();
            }
        }
        else
        {
            Console.WriteLine("ℹ️ Skipping In-Memory Configuration example because KSM_CONFIG_BASE64 placeholder is not replaced or is empty.");
        }
    }

    // Helper function to list secrets
    private static async Task ListSecretsAsync(SecretsManagerOptions options, string configTypeName)
    {
        Console.WriteLine($"\n📡 Fetching all secrets using {configTypeName}...");
        var secrets = await SecretsManagerClient.GetSecretsAsync(options);
        Console.WriteLine($"✅ Successfully fetched {secrets.Records.Count} record(s) using {configTypeName}:");

        if (!secrets.Records.Any())
        {
            Console.WriteLine("\nℹ️ No records found. Ensure records are shared with your KSM application.");
        }
        else
        {
            Console.WriteLine("\n--- All Shared Records ---");
            int count = 0;
            foreach (var record in secrets.Records)
            {
                count++;
                Console.WriteLine($"[{count}] Record UID: {record.RecordUid}");
                Console.WriteLine($"    Title: {record.Data?.title}");
                Console.WriteLine($"    Type: {record.Data?.type}");
                Console.WriteLine($"    Fields Count: {(record.Data?.fields?.Length ?? 0) + (record.Data?.custom?.Length ?? 0)}");
                Console.WriteLine($"    Files Count: {record.Files?.Count ?? 0}");
                Console.WriteLine("---");
            }
        }
    }
}
```{{copy}}

## 4. Configure Your Token and/or Base64 String

-   **For File-Based Configuration (Option 1)**: 
    -   In `Program.cs`, replace `[ONE_TIME_TOKEN_FOR_FILE_CONFIG]` with a valid One-Time Token. This is only needed for the *first run* to create `ksm-config.json` if it doesn't already exist.
-   **For In-Memory Configuration (Option 2)**: 
    -   In `Program.cs`, replace `[YOUR_KSM_CONFIG_BASE64_STRING_HERE]` with the actual Base64 encoded configuration string for your KSM application.

## 5. Run the Application

Execute your .NET application from the terminal:

```bash
dotnet run
```
`dotnet run`{{execute}}

### Expected Output:

You should see output for both file-based (if token was provided for first run or `ksm-config.json` exists) and in-memory (if Base64 string was provided) initializations, followed by a list of your shared secrets for each successful configuration.

## Understanding the Code

-   **`LocalConfigStorage`**: Manages `ksm-config.json` for persistent configuration.
-   **`SecretsManagerClient.InitializeStorage(storage, oneTimeToken)`**: Used for the initial binding with a One-Time Token for file-based storage.
-   **`MemoryKeyValueStorage(base64ConfigString)`**: Initializes storage directly in memory from a Base64 encoded JSON configuration string. No file is created or read from disk.
-   **`SecretsManagerOptions(storage)`**: Configures the KSM client with the chosen storage (either file-based or memory-based).
-   **`SecretsManagerClient.GetSecretsAsync(options)`**: Fetches secrets using the provided options.

## Next Steps

Now that you can connect using different configurations, the next step will detail retrieving specific secrets and accessing their individual field values and files.

```
🚀 KSM .NET SDK Tutorial - Step 1: Configuration & Listing Secrets

--- Attempting File-Based Configuration ---
🔑 Initializing KSM File Storage with One-Time Token...
💾 File Storage initialized. Config will be saved to: ksm-config.json
💾 Using existing File Storage config: ksm-config.json
📡 Fetching all secrets using File-Based Config...
✅ Successfully fetched X record(s) using File-Based Config:

--- All Shared Records ---
[1] Record UID: abcXYZ123...
    Title: My Sample Login
    Type: login
    Fields Count: 2
    Files Count: 1
---
...

--- Attempting In-Memory Configuration ---
🧠 Initializing KSM with In-Memory Storage (from Base64 string)...
💾 In-Memory storage initialized successfully from Base64 config.
📡 Fetching all secrets using In-Memory Config (Base64)...
✅ Successfully fetched X record(s) using In-Memory Config (Base64):

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

-   **`LocalConfigStorage`**: Manages `ksm-config.json` for persistent configuration.
-   **`SecretsManagerClient.InitializeStorage(storage, oneTimeToken)`**: Used for the initial binding with a One-Time Token for file-based storage.
-   **`MemoryKeyValueStorage(base64ConfigString)`**: Initializes storage directly in memory from a Base64 encoded JSON configuration string. No file is created or read from disk.
-   **`SecretsManagerOptions(storage)`**: Configures the KSM client with the chosen storage (either file-based or memory-based).
-   **`SecretsManagerClient.GetSecretsAsync(options)`**: Fetches secrets using the provided options.

## Next Steps

Now that you can connect using different configurations, the next step will detail retrieving specific secrets and accessing their individual field values and files.