using SecretsManager;
using System;
using System.IO;
using System.Threading.Tasks;

namespace QuickTest
{
    public static class ProgramTestFolders
    {
        // private static void Main()
        // {
        //     try
        //     {
        //         GetSecretsAndFolders().Wait();
        //     }
        //     catch (Exception e)
        //     {
        //         Console.WriteLine(e);
        //     }
        // }

        private static async Task GetSecretsAndFolders()
        {
            var configJson = "eyJob3N0bmFtZSI6ImtlZXBlcnNlY3VyaXR5LmNvbSIsImNsaWVudElkIjoiT1NsdkppVEx6R3VpQXpsdFZyYzlORHk0a01HOERhNFV1WVZiS3U5QStHTS9TT1k3SG1rRTViMWtIRnpuM2lRcndybFoyU0tJbis0QmJ4aHRxeGFXR2c9PSIsInByaXZhdGVLZXkiOiJNSUdIQWdFQU1CTUdCeXFHU000OUFnRUdDQ3FHU000OUF3RUhCRzB3YXdJQkFRUWd1dWZKdVZvSGZnK0pJVXRjdGNjQkFkZXU3Y3FjcVBKNTZnRjJvdWVvQ0JLaFJBTkNBQVRTK3ZPckYvQ2V3NnUyKzZRdjJqUjM0ZGFTTjA3KzhXdFJib0JDSStPSlIxLzRibHhYdlFBSzNHS3RCa24xZ3pINU9DQkJSbGxVcGNTc0Z5RmFna0lqIiwic2VydmVyUHVibGljS2V5SWQiOiIxMCIsImFwcEtleSI6Im5wMnhRYkdvMzVrY2FEZVF1WWNnYS9rbStVdm5hMlBQV3Vna2lNcis4N0E9IiwiYXBwT3duZXJQdWJsaWNLZXkiOiJCQndtcVJzYXpXQ3NEZ3ZUYUtuOG5HMEgwb0pZeTY2ejV3UWRIODdUOHJONGI2N3o2UnpGSUZJMmRhTDl6SDAzL2ErbTlicTErUnF0Ky9RNWVlamZ0bEU9In0=";
            var storage = new InMemoryStorage(configJson);
            // ReSharper disable once StringLiteralTypo
            var options = new SecretsManagerOptions(storage);
            // var options = new SecretsManagerOptions(storage, SecretsManagerClient.CachingPostFunction);
            var secrets = await SecretsManagerClient.GetSecrets(options);
            var folders = await SecretsManagerClient.GetFolders(options);

            foreach (var keeperFolder in folders)
            {
                Console.WriteLine(keeperFolder.Name);
            }

            // var password = Notation.GetValue(secrets, "RECORD_UID/field/password");
            var firstRecord = secrets.Records[0];
            // Console.WriteLine(firstRecord.);
            var password = firstRecord.FieldValue("password").ToString();
            Console.WriteLine(password);
            // if (firstRecord.FolderUid != null)
            // {
            //     firstRecord.Data.title += ".Net Copy";
            //     var recordUid = await SecretsManagerClient.CreateSecret(options, firstRecord.FolderUid, firstRecord.Data, secrets);
            //     Console.WriteLine(recordUid);
            // }
            // var fileBytes = SecretsManagerClient.DownloadFile(firstRecord.Files[0]);
            // Console.WriteLine(fileBytes.Length);
            // firstRecord.UpdateFieldValue("password", "111111111");
            // await SecretsManagerClient.UpdateSecret(options, firstRecord);
            
            // get file data to upload
            var bytes = await File.ReadAllBytesAsync("/Users/mustinov/Source/secrets-manager/sdk/dotNet/global.json");
            var myFile = new KeeperFileUpload(
                "my-file1.json", 
                "My File", 
                null, 
                bytes
            );
       
            // upload file to selected record                     
            var recUid = await SecretsManagerClient.UploadFile(options, firstRecord, myFile);
            
            Console.WriteLine("File uid: " + recUid);
        }
    }
}