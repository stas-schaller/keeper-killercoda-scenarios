Install KSM Package:

`dotnet add package Keeper.SecretsManager`{{execute}}

Modify `Program.cs`{{open}} file

<pre class="file" data-filename="ksm-sample-project/Program.cs" data-target="replace">
using System;
using System.Threading.Tasks;
using SecretsManager;

namespace ConsoleApp1
{
    public static class Program
    {
        private static void Main()
        {
            GetSecrets().Wait();
        }

        private static async Task GetSecrets()
        {

            // Method 1: In-Memory config
            //           Make sure to escape special characters in JSON config
            var KSM_CONFIG = "{\"hostname\": \"keepersecurity.eu\", \"c[...]xt1Qhc=\"}"
            var storage = new InMemoryStorage(KSM_CONFIG);

            // Method 2: File storage
            //var storage = new LocalConfigStorage("ksm-config-demo1.json");
            //SecretsManagerClient.InitializeStorage(storage, "thkNOvIfLwntTdWNKMSKjALM2GqQ6mbvPMmfd1AB3N8", "keepersecurity.com");

            var options = new SecretsManagerOptions(storage);

            // Get all secrets
            var secrets = await SecretsManagerClient.GetSecrets(options);

            var firstRecord = secrets.Records[0]; 

            Console.Write(firstRecord);
        }
    }
}
</pre>