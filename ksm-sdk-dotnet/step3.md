### 1. Overwrite existing application code
_Note: This will erase your existing code_

<pre class="file" data-filename="ksm-sample-project/Program.cs" data-target="replace">
using SecretsManager;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace ConsoleApp1
{
    public static class Program
    {
        private static void Main()
        {
            GetSecrets().Wait();
        }

        const string FOLDER_UID = "[FOLDER UID]";

        private static async Task GetSecrets()
        {

            // Note: Reusing configuration that was generated in the first step
            var storage = new LocalConfigStorage("ksm-config-demo3.json");
            SecretsManagerClient.InitializeStorage(storage, ONE_TIME_TOKEN);

            var options = new SecretsManagerOptions(storage);

            var newRecord = new KeeperRecordData();
            newRecord.type = "MyCustomType";
            newRecord.title = "Sample Katacoda KSM Record (Custom record type)";
            newRecord.fields = new[]
            {
                new KeeperRecordField { type = "login", value = new[] { "username@email.com" }, required = true, label = "My Login"},
                new KeeperRecordField { type = "password", value = new[] { "Pa$$word123" }, required = true, label = "My Password"},
                new KeeperRecordField { type = "securityQuestion", value = new[]
                    {
                        new Dictionary&lt;string, string&gt;
                        {
                            {"question", "What is the question?"}, 
                            { "answer", "This is the answer!" }
                        }
                    }, label = "My Security Question & Answer", privacyScreen = false},
                new KeeperRecordField { type = "phone", value = new[]
                    {
                        new Dictionary&lt;string,string&gt;
                        {
                            { "region", "US" },
                            { "number", "510-444-3333" },
                            { "ext", "2345" },
                            { "type", "Mobile" }
                        }
                    }, label = "My Private Phone", privacyScreen = true
                },
                new KeeperRecordField { type = "date", value = new[] {(object) 1641934793000 }, label = "My Birthdate" },
                new KeeperRecordField { type = "name", value = new[]
                    {
                        new Dictionary&lt;string, string&gt;
                        {
                            {"first", "John"},
                            {"middle", "Patrick"},
                            {"last", "Smith"}
                        }
                    }
                },
                new KeeperRecordField { 
                    type = "otp", 
                    value = new[] { "otpauth://totp/Example:alice@google.com?secret=JBSWY3DPEHPK3PXP&issuer=Example"}, 
                    label = "MyTOTP"
                }
            };
            newRecord.notes = "\tThis custom type record was created\n\tvia KSM Katacoda .NET C# Example";
            
            var recordUid = (await SecretsManagerClient.CreateSecret(options, FOLDER_UID, newRecord));
            
            Console.WriteLine("Saved record UID: [" + recordUid + "]");

            // Retrieve saved record from the server
            var savedSecret = await SecretsManagerClient.GetSecrets(options, new []{recordUid});
            
            var oneTimeCodeUrl = Notation.GetValue(savedSecret, "keeper://" + recordUid + "/field/MyTOTP");
            
            var oneTimeCode = CryptoUtils.GetTotpCode(oneTimeCodeUrl);

            Console.Write("One time code: " + oneTimeCode.Code + " (TTL: " + oneTimeCode.TimeLeft + " sec.)");
        }
    }
}
</pre>

### 4. Replace Token

Replace the following placeholders:

- `[FOLDER UID]` - UID of the shared folder that is shared to the Application

### 5. Build and run project
`dotnet run`{{execute}}