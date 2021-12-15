
### 1. Generate the standard console application
`dotnet new console`{{execute}}

### 2. Install KSM Package:

`dotnet add package Keeper.SecretsManager`{{execute}}


### 3. Modify a program file

<pre class="file" data-filename="ksm-sample-project/Program.cs" data-target="replace">
using System;
using System.Threading.Tasks;
using SecretsManager;
using System.Text.Json;

namespace ConsoleApp1
{
    public static class Program
    {
        const string ONE_TIME_TOKEN = "[ONE TIME TOKEN]";
        
        private static void Main()
        {
            GetSecrets().Wait();
        }

        private static async Task GetSecrets()
        {

            var storage = new LocalConfigStorage("ksm-config-demo.json");
            SecretsManagerClient.InitializeStorage(storage, ONE_TIME_TOKEN);

            var options = new SecretsManagerOptions(storage);

            // Get all secrets
            var secrets = await SecretsManagerClient.GetSecrets(options);

            // Get first record
            var firstRecord = secrets.Records[0]; 

            // Turn record to json string
            string jsonString = JsonSerializer.Serialize(firstRecord, new JsonSerializerOptions { WriteIndented = true });

            Console.WriteLine(jsonString);
        }
    }
}
</pre>

### 4. Replace Token

Replace the following placeholders:

- `[ONE TIME TOKEN]` - with the code you have generated in the Keeper Web Vault


### 5. Build and run project
`dotnet run`{{execute}}