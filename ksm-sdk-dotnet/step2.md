

### 1. Overwrite existing application code
_Note: This will erase your existing code_

<pre class="file" data-filename="ksm-sample-project/Program.cs" data-target="replace">
using System;
using System.Threading.Tasks;
using SecretsManager;
using System.Text.Json;

namespace ConsoleApp1
{
    public static class Program
    {
        const string FOLDER_UID = "[FOLDER UID]";

        private static void Main()
        {
            CreateLoginRecord().Wait();
        }

        private static async Task CreateLoginRecord()
        {
            
            // Note: Reusing configuration that was generated in the first step
            var storage = new LocalConfigStorage("ksm-config-demo.json");
            var options = new SecretsManagerOptions(storage);

            var newRecord = new KeeperRecordData();
            newRecord.type = "login";
            newRecord.title = "Sample Katacoda KSM Record";
            newRecord.fields = new[]
            {
                new KeeperRecordField { type = "login", value = new[] { "username@email.com" } },
                new KeeperRecordField { type = "password", value = new[] { "Pa$$word123" } },
            };
            newRecord.notes = "\tThis record was created\n\tvia KSM Katacoda .NET C# Example";

            var recordUid = await SecretsManagerClient.CreateSecret(options, FOLDER_UID, newRecord);
            
            Console.WriteLine("Saved record UID: [" + recordUid + "]");
        }
    }
}
</pre>

### 4. Replace Token

Replace the following placeholders:

- `[FOLDER UID]` - UID of the shared folder that is shared to the Application

### 5. Build and run project
`dotnet run`{{execute}}