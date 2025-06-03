using SecretsManager;
using System;
using System.IO;
using System.Threading.Tasks;

namespace QuickTest
{
    public static class ProgramAddRecord
    {
        private static void Main()
        {
            try
            {
                GetSecrets().Wait();
            }
            catch (Exception e)
            {
                Console.WriteLine(e);
            }
        }

        private static async Task GetSecrets()
        {
            var configJson =
                "ew0KICAiYXBwS2V5IjogIjhWTHpoNVhZMVBsNlh0ckt4WmVsTDZ1REpueG93ZEd3dUNsQkM1SzdER1E9IiwNCiAgImFwcE93bmVyUHVibGljS2V5IjogIkJFdkVZWVZpSlI1UHhWODBhQitGVVRlMkJhUWtvSHI3QXpBNVY2dXZmMUhwUE9YbWFlXC9SUDk3c3dwVk9YQUMzU2VHKzdlXC9HaXNZZDdcLzRJTGVUYVB6TT0iLA0KICAiY2xpZW50SWQiOiAia0tESVRwbmtXOXRHZTFFbnhJM0NhYVJJaHFDZm42aUZ2NlFDWjZhRCtNTUJidTJyTFhOMis1UU5ZM1I2TGZqQjloR0d5eHJiT0pzcnN6eWY3Sk1VU0E9PSIsDQogICJob3N0bmFtZSI6ICJkZXYua2VlcGVyc2VjdXJpdHkuY29tIiwNCiAgInByaXZhdGVLZXkiOiAiTUlHVEFnRUFNQk1HQnlxR1NNNDlBZ0VHQ0NxR1NNNDlBd0VIQkhrd2R3SUJBUVFnbkNVYWs0MllROFJtME9qOFlqY3N5UGx1ZE5kTjN2TFRmSXp2UXJHRmxiU2dDZ1lJS29aSXpqMERBUWVoUkFOQ0FBUUczNGlSSnZQbkxQZEFDQ3NVRjI0MXl3T3JtaHhnNXJcL04wU2NcL3JNMllMSmNGUlNzVmJYWG9acXgzaEt6MTFJMnp6dFZPOXkwUm5pcGtPZGFEeFVhQiIsDQogICJzZXJ2ZXJQdWJsaWNLZXlJZCI6ICI3Ig0KfQ==";
            var storage = new InMemoryStorage(configJson);
            // ReSharper disable once StringLiteralTypo
            var options = new SecretsManagerOptions(storage);
            // var options = new SecretsManagerOptions(storage, SecretsManagerClient.CachingPostFunction);
            var secrets = await SecretsManagerClient.GetSecrets(options);
            // var password = Notation.GetValue(secrets, "RECORD_UID/field/password");
            var firstRecord = secrets.Records[0];
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