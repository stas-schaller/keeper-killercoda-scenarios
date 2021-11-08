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
            // var KSM_CONFIG = "eyJob3N0bm[...]BXZXdmMDNMTEdlb2VpMD0ifQ==";
            // var storage = new InMemoryStorage(KSM_CONFIG);

            // Method 2: File storage
            var storage = new LocalConfigStorage("ksm-config-demo1.json");
            SecretsManagerClient.InitializeStorage(storage, "US:thkNOvIfLwntTdWNKMSKjALM2GqQ6mbvPMmfd1AB3N8");

            var options = new SecretsManagerOptions(storage);

            // Get all secrets
            var secrets = await SecretsManagerClient.GetSecrets(options);

            var firstRecord = secrets.Records[0]; 

            Console.Write(firstRecord);

            var secrets = await SecretsManagerClient.GetSecrets(options, new []{"jvUbA86LjuiV3W1IKxL5OA"});

            var firstRecord = secrets.Records[0];
            var oneTimeCodeUrl = Notation.GetValue(secrets, "keeper://jvUbA86LjuiV3W1IKxL5OA/field/oneTimeCode");
            
            var oneTimeCode = CryptoUtils.GetTotpCode(oneTimeCodeUrl);

            Console.Write(oneTimeCode);

        }
    }
}
</pre>

Build and run project
`dotnet run`{{execute}}
