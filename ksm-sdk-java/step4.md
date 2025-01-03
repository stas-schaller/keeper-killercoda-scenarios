### 1. Create Java class for file operations:

```
touch src/main/java/com/keepersecurity/ksmsample/KSMFileOperations.java
```{{execute}}

#### Place this code in the created file:

```java
package com.keepersecurity.ksmsample;

import com.keepersecurity.secretsManager.core.*;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.util.List;

public class KSMFileOperations {
    
    public static void uploadFile() {
        // get pre-initialized storage
        KeyValueStorage storage = new LocalConfigStorage("ksm-config.json");
        try {
            SecretsManagerOptions options = new SecretsManagerOptions(storage);

            // create a filter with the UID of the record we want
            List<String> uidFilter = List.of("[RECORD_UID]");

            // fetch secrets with the filter
            KeeperSecrets secrets = SecretsManager.getSecrets(options, uidFilter);

            // get the desired secret to upload a file to
            KeeperRecord ownerRecord = secrets.getRecords().get(0);
        
            // get bytes from file to upload
            File file = new File("./myFile.txt");
            FileInputStream fl = new FileInputStream(file);
            byte[] fileBytes = new byte[(int)file.length()];
            fl.read(fileBytes);
            fl.close();
            
            // create a Keeper File to upload
            KeeperFileUpload myFile = new KeeperFileUpload(
                "myFile.txt",     // filename in Keeper
                "My Test File",   // title in Keeper
                "text/plain",     // mime type
                fileBytes         // file content
            );

            // upload the file
            String fileRecordUid = SecretsManager.uploadFile(options, ownerRecord, myFile);
            System.out.println("Uploaded file with UID: " + fileRecordUid);
            
        } catch (Exception e) {
            System.out.println("Error: " + e.getMessage());
        }
    }

    public static void downloadFile() {
        KeyValueStorage storage = new LocalConfigStorage("ksm-config.json");
        try {
            SecretsManagerOptions options = new SecretsManagerOptions(storage);
            
            List<String> uidFilter = List.of("[RECORD_UID]");
            KeeperSecrets secrets = SecretsManager.getSecrets(options, uidFilter);
            KeeperRecord record = secrets.getRecords().get(0);

            // get file reference by name
            KeeperFile file = record.getFileByName("myFile.txt");
            
            // download the file
            byte[] fileBytes = SecretsManager.downloadFile(file);
            
            // save to local filesystem
            FileOutputStream fos = new FileOutputStream("downloaded_" + file.getData().getName());
            fos.write(fileBytes);
            fos.close();
            
            System.out.println("Downloaded file: " + file.getData().getName());
            
        } catch (Exception e) {
            System.out.println("Error: " + e.getMessage());
        }
    }

    public static void main(String[] args) {
        if (args.length > 0 && args[0].equals("download")) {
            downloadFile();
        } else {
            uploadFile();
        }
    }
}
```{{copy}}