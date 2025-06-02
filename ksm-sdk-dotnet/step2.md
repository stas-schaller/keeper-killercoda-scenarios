# Step 2: Retrieving & Using Secrets

This step focuses on how to retrieve specific records from Keeper and access their various field types, including standard fields, custom fields, and notes, using the KSM .NET SDK.

## 1. Prepare Your Environment

-   Ensure you have completed Step 1 and have a working `ksm-config.json` (or a valid One-Time Token if running examples for the first time).
-   Share at least one record with your KSM application in the Keeper Vault. This record should ideally have:
    -   A unique title (e.g., "My .NET Test Record").
    -   Standard fields: e.g., a `login` field, a `password` field, a `url` field.
    -   A custom field: e.g., Label: "API_Service_Key", Type: Text, Value: "dotnetcustomkey789".
    -   Some text in the notes section.

## 2. Create C# Class: GetSpecificDotNetSecret

In your `KsmNetTutorial` project, create a new C# class file for this example.

```bash
touch GetSpecificDotNetSecret.cs
```
`touch GetSpecificDotNetSecret.cs`{{execute}}

### Add the C# Code

Paste the following code into `GetSpecificDotNetSecret.cs`. This class will demonstrate fetching a specific record and accessing its diverse data components.

```csharp
using System;
using System.Linq;
using System.Text.Json;
using System.Threading.Tasks;
using System.Collections.Generic;
using SecretsManager;

public class GetSpecificDotNetSecret
{
    // ⚠️ If ksm-config.json doesn't exist, replace with your One-Time Token
    private const string OneTimeToken = "[ONE_TIME_TOKEN_IF_NEEDED]";
    private const string ConfigFileName = "ksm-config.json";

    //  Replace with the UID or Title of a specific record shared with your KSM Application
    private const string TargetRecordUid = "[YOUR_SPECIFIC_RECORD_UID_HERE]";
    private const string TargetRecordTitle = "[YOUR_SPECIFIC_RECORD_TITLE_HERE]"; // e.g., "My .NET Test Record"

    public static async Task Main(string[] args)
    {
        Console.WriteLine("🚀 Retrieving specific .NET secrets and fields...");
        var storage = new LocalConfigStorage(ConfigFileName);

        try
        {
            if (!System.IO.File.Exists(ConfigFileName) || OneTimeToken != "[ONE_TIME_TOKEN_IF_NEEDED]")
            {
                 Console.WriteLine("🔑 Initializing KSM storage...");
                SecretsManagerClient.InitializeStorage(storage, OneTimeToken);
            }
            var options = new SecretsManagerOptions(storage);

            Console.WriteLine($"\n--- Attempting to fetch record by UID: {TargetRecordUid} ---");
            // Efficiently fetch only the specified record(s) by UID
            var secretsByUid = await SecretsManagerClient.GetSecretsAsync(options, new[] { TargetRecordUid });
            KeeperRecord record = secretsByUid.Records.FirstOrDefault(); // Assuming UID is unique

            if (record == null)
            {
                Console.WriteLine($"Record with UID '{TargetRecordUid}' not found. Trying by title: {TargetRecordTitle}");
                // Fallback: If not found by UID (or if UID wasn't known), try fetching all and filtering by title
                var allSecrets = await SecretsManagerClient.GetSecretsAsync(options);
                record = allSecrets.Records.FirstOrDefault(r => r.Data?.title == TargetRecordTitle);
            }

            if (record != null)
            {
                Console.WriteLine($"✅ Found record: {record.Data?.title} (UID: {record.RecordUid})");
                DisplayRecordDetails(record);
            }
            else
            {
                Console.WriteLine($"❌ Record with UID '{TargetRecordUid}' or Title '{TargetRecordTitle}' not found.");
            }
        }
        catch (Exception ex)
        {
            Console.ForegroundColor = ConsoleColor.Red;
            Console.WriteLine($"❌ Error: {ex.Message}");
            Console.ResetColor();
        }
    }

    private static void DisplayRecordDetails(KeeperRecord record)
    {
        Console.WriteLine($"    Type: {record.Data?.type}");

        // Accessing Standard Fields
        Console.WriteLine("    Standard Fields:");
        if (record.Data?.fields != null)
        {
            foreach (var field in record.Data.fields)
            {
                string fieldValueString = FieldValueToString(field.value, field.type);
                Console.WriteLine($"      - Type: {field.type}, Label: {field.label ?? "<no label>"}, Value: {fieldValueString}");
            }
        }
        else
        {
            Console.WriteLine("      <No standard fields>");
        }

        // Simplified access using helper methods (if available or implemented)
        // For .NET SDK, direct field access is common, but you can wrap it for convenience.
        Console.WriteLine("    Helper/Direct Access Examples:");
        Console.WriteLine($"      - Login: {record.GetLogin()}"); // Uses extension method GetLogin()
        Console.WriteLine($"      - Password: {record.GetPassword()?.Substring(0, Math.Min(record.GetPassword()?.Length ?? 0, 3))}***"); // Uses GetPassword() and masks

        // Accessing Custom Fields
        Console.WriteLine("    Custom Fields:");
        if (record.Data?.custom != null && record.Data.custom.Any())
        {
            foreach (var customField in record.Data.custom)
            {
                string fieldValueString = FieldValueToString(customField.value, customField.type);
                Console.WriteLine($"      - Label: {customField.label ?? "<no label>"}, Type: {customField.type}, Value: {fieldValueString}");
            }
        }
        else
        {
            Console.WriteLine("      <No custom fields>");
        }

        // Accessing Notes
        Console.WriteLine($"    Notes: {(string.IsNullOrEmpty(record.Data?.notes) ? "<No notes>" : record.Data.notes.Substring(0, Math.Min(record.Data.notes.Length, 70)) + "...")}");
        Console.WriteLine("---");
    }

    // Helper to convert field value (object[]) to a displayable string
    private static string FieldValueToString(object[] values, string fieldType)
    {
        if (values == null || !values.Any())
            return "<empty or not set>";

        if (fieldType?.ToLower() == "password" || fieldType?.ToLower() == "secret" || fieldType?.ToLower() == "hidden")
            return "********"; // Mask sensitive fields
        
        // For complex objects like Name, Address, etc., JsonSerializer can be used.
        // For simple string arrays, join them.
        if (values.All(v => v is JsonElement))
        {
            var elements = values.Cast<JsonElement>().ToList();
            if (elements.All(e => e.ValueKind == JsonValueKind.String))
            {
                return string.Join(", ", elements.Select(e => e.GetString()));
            }
             // Attempt to serialize complex field types for display
            try {
                return JsonSerializer.Serialize(values, new JsonSerializerOptions { WriteIndented = false });
            }
            catch { /* Fallback if serialization fails */ }
        }
        
        return string.Join(", ", values.Select(v => v?.ToString() ?? "<null>"));
    }
}

// Helper extension methods for KeeperRecord for easier field access
public static class KeeperRecordExtensions
{
    public static string GetLogin(this KeeperRecord record)
    {
        return record?.Data?.fields?.FirstOrDefault(f => f.type == "login")?.value?.FirstOrDefault()?.ToString();
    }

    public static string GetPassword(this KeeperRecord record)
    {
        return record?.Data?.fields?.FirstOrDefault(f => f.type == "password")?.value?.FirstOrDefault()?.ToString();
    }

    public static string GetFieldValue(this KeeperRecord record, string fieldTypeOrLabel, bool isCustom = false)
    {
        var fieldArray = isCustom ? record?.Data?.custom : record?.Data?.fields;
        var field = fieldArray?.FirstOrDefault(f => (isCustom && f.label == fieldTypeOrLabel) || (!isCustom && f.type == fieldTypeOrLabel));
        return field?.value?.FirstOrDefault()?.ToString();
    }
}
```{{copy}}

## 3. Configure Target Record Details

-   In `GetSpecificDotNetSecret.cs`:
    -   **Crucial**: Replace `[YOUR_SPECIFIC_RECORD_UID_HERE]` with the UID of the specific record you want to fetch.
    -   Replace `[YOUR_SPECIFIC_RECORD_TITLE_HERE]` with the title of that same record (this is used as a fallback).
    -   If your `ksm-config.json` isn't created yet, update `[ONE_TIME_TOKEN_IF_NEEDED]` with a valid One-Time Token.

## 4. Update `Program.cs` to Run This Example

Modify your main `Program.cs` to call the `Main` method of `GetSpecificDotNetSecret`.

```csharp
using System.Threading.Tasks;

public class Program
{
    public static async Task Main(string[] args)
    {
        // To run Step 1 example (ListAllSecrets), comment out the line below and uncomment the Step 1 call.
        // await ListAllSecrets.Main(args); 
        
        // Current example: Step 2 - GetSpecificDotNetSecret
        await GetSpecificDotNetSecret.Main(args);
    }
}
```{{copy}}

## 5. Run the Application

```bash
dotnet run
```
`dotnet run`{{execute}}

### Expected Output:

Details of the specified record, including its standard and custom fields, should be displayed.

```
🚀 Retrieving specific .NET secrets and fields...

--- Attempting to fetch record by UID: YOUR_SPECIFIC_RECORD_UID_HERE ---
✅ Found record: My .NET Test Record (UID: YOUR_SPECIFIC_RECORD_UID_HERE)
    Type: login
    Standard Fields:
      - Type: login, Label: <no label>, Value: testuser@example.com
      - Type: password, Label: <no label>, Value: ********
      - Type: url, Label: <no label>, Value: https://test.example.com
    Helper/Direct Access Examples:
      - Login: testuser@example.com
      - Password: Sec***
    Custom Fields:
      - Label: API_Service_Key, Type: text, Value: dotnetcustomkey789
    Notes: This is a note for the .NET test record...
---
```

## Understanding the Code

-   **Fetching Specific Records**: 
    -   `SecretsManagerClient.GetSecretsAsync(options, new[] { TargetRecordUid })` is the most efficient way to get one or more specific records if you know their UIDs.
    -   If UIDs are unknown, you can fetch all records and then use LINQ (`FirstOrDefault(r => r.Data?.title == TargetRecordTitle)`) to find a record by its title.
-   **Accessing Record Data**: 
    -   `KeeperRecord.Data` (of type `KeeperRecordData`) holds the main content: `title`, `type`, `notes`.
    -   `KeeperRecord.Data.fields` is an array of `KeeperRecordField` objects representing standard fields.
    -   `KeeperRecord.Data.custom` is an array of `KeeperRecordField` objects for custom fields.
-   **`KeeperRecordField`**: Each field object has:
    -   `type`: The field type (e.g., "login", "password", "text", "url").
    -   `label`: The user-defined label for the field (especially relevant for custom fields).
    -   `value`: An `object[]` containing the actual value(s) of the field. Most simple fields store their value as the first element (e.g., `field.value[0]`).
-   **Helper Extension Methods**: The example includes simple extension methods (`GetLogin()`, `GetPassword()`, `GetFieldValue()`) on `KeeperRecord` to demonstrate how you can encapsulate common field retrieval logic for cleaner code.
-   **`FieldValueToString` Helper**: This utility method demonstrates how to safely convert the `object[] value` of a field into a displayable string, including masking for sensitive types like "password". For complex field types (like `Name`, `Address`), `JsonSerializer.Serialize` can be used if you need a string representation of the structured data.

## Next Steps

In the next step, you'll learn how to create new records, define various field types, and manage file attachments for your .NET applications using the KSM SDK.