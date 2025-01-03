### Folder Operations

```
touch src/main/java/com/keepersecurity/ksmsample/KSMFolderOperations.java
```{{execute}}

#### Place this code in the created file:

```java
package com.keepersecurity.ksmsample;

import com.keepersecurity.secretsManager.core.*;
import java.util.List;
import java.util.Arrays;

public class KSMFolderOperations {

    public static void listFolders() {
        KeyValueStorage storage = new LocalConfigStorage("ksm-config.json");
        try {
            SecretsManagerOptions options = new SecretsManagerOptions(storage);
            
            // Get all folders
            List<KeeperFolder> folders = SecretsManager.getFolders(options);
            
            System.out.println("Found " + folders.size() + " folders:");
            for (KeeperFolder folder : folders) {
                System.out.println("Folder: " + folder.getName() + 
                                 " (UID: " + folder.getFolderUid() + ")" +
                                 (folder.getParentUid() != null ? 
                                  " Parent: " + folder.getParentUid() : ""));
            }
        } catch (Exception e) {
            System.out.println("Error: " + e.getMessage());
        }
    }

    public static void createFolder() {
        KeyValueStorage storage = new LocalConfigStorage("ksm-config.json");
        try {
            SecretsManagerOptions options = new SecretsManagerOptions(storage);
            
            // Specify parent folder
            CreateOptions createOpts = new CreateOptions(
                "[SHARED_FOLDER_UID]",  // Parent shared folder UID
                null                    // Optional subfolder UID
            );
            
            // Create the new folder
            String newFolderUid = SecretsManager.createFolder(
                options,
                createOpts,
                "My New Folder"  // Folder name
            );
            
            System.out.println("Created folder with UID: " + newFolderUid);
            
        } catch (Exception e) {
            System.out.println("Error: " + e.getMessage());
        }
    }

    public static void updateFolder() {
        KeyValueStorage storage = new LocalConfigStorage("ksm-config.json");
        try {
            SecretsManagerOptions options = new SecretsManagerOptions(storage);
            
            // Update folder name
            SecretsManager.updateFolder(
                options,
                "[FOLDER_UID]",        // Folder to update
                "Updated Folder Name"   // New name
            );
            
            System.out.println("Folder name updated successfully");
            
        } catch (Exception e) {
            System.out.println("Error: " + e.getMessage());
        }
    }

    public static void deleteFolder() {
        KeyValueStorage storage = new LocalConfigStorage("ksm-config.json");
        try {
            SecretsManagerOptions options = new SecretsManagerOptions(storage);
            
            // Delete folders
            SecretsManagerDeleteResponse response = SecretsManager.deleteFolder(
                options,
                Arrays.asList("[FOLDER_UID]"),  // List of folder UIDs to delete
                true                            // Force deletion if not empty
            );
            
            System.out.println("Folder deletion completed");
            
        } catch (Exception e) {
            System.out.println("Error: " + e.getMessage());
        }
    }

    public static void main(String[] args) {
        if (args.length == 0) {
            listFolders();
            return;
        }
        
        switch (args[0]) {
            case "create": createFolder(); break;
            case "update": updateFolder(); break;
            case "delete": deleteFolder(); break;
            default: listFolders();
        }
    }
}
```{{copy}}