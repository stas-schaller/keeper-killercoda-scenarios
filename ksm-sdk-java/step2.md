
### 1. Create new Java class to create a record

<pre class="file" data-filename="src/main/java/com/keepersecurity/ksmsample/KSMAddRecord.java" data-target="replace">
package com.keepersecurity.ksmsample;

import com.keepersecurity.secretsManager.core.*;
import static com.keepersecurity.secretsManager.core.SecretsManager.initializeStorage;
import java.util.List;

public class KSMAddRecord {

    // oneTimeToken is used only once to initialize the storage
    // after the first run, subsequent calls will use ksm-config.txt
    String oneTimeToken = "[ONE TIME TOKEN]";

    // Folder WHERE where the new record will be stored
    String folderUid = "[FOLDER UID]";

    public static void addLoginRecord(){

        LocalConfigStorage storage = new LocalConfigStorage("ksm-config2.txt");
        initializeStorage(storage, oneTimeToken);
        SecretsManagerOptions options = new SecretsManagerOptions(storage);

        KeeperSecrets secrets = SecretsManager.getSecrets(options);

        KeeperRecordData newRecordData = new KeeperRecordData(
                "Sample Katacoda KSM Record",
                "login",
                List.of(
                        new Login("username@email.com"),
                        new Password("Pa$$word123")
                ),
                null,
                "\tThis record was created\n\tvia KSM Katacoda Java Example"
                );

        SecretsManager.createSecret(options, folderUid, newRecordData, secrets);
    }

    public static void main(String[] args) {
        addLoginRecord();
    }
}
</pre>


### 2. Modify code

Replace the following placeholders:

- `[ONE TIME TOKEN]` - with the code you have generated in the Keeper Web Vault
- `[FOLDER UID]` - UID of the shared folder that is shared to the Application

### 3. Execute Java code:

`gradle -PmainClass=com.keepersecurity.ksmsample.KSMAddRecord run`{{execute}}
