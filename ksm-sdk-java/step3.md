
### 1. Create new Java class to create a record

<pre class="file" data-filename="src/main/java/com/keepersecurity/ksmsample/KSMAddAdvancedRecord.java" data-target="replace">
package com.keepersecurity.ksmsample;

import com.keepersecurity.secretsManager.core.*;
import static com.keepersecurity.secretsManager.core.SecretsManager.initializeStorage;
import java.util.Arrays;
import java.util.List;

public class KSMAddAdvancedRecord {

    // oneTimeToken is used only once to initialize the storage
    // after the first run, subsequent calls will use ksm-config.txt
    static String oneTimeToken = "[ONE TIME TOKEN]";

    // Folder WHERE where the new record will be stored
    static String folderUid = "[FOLDER UID]";

    public static void addLoginRecord(){

        LocalConfigStorage storage = new LocalConfigStorage("ksm-config2.txt");
        initializeStorage(storage, oneTimeToken);
        SecretsManagerOptions options = new SecretsManagerOptions(storage);

        KeeperSecrets secrets = SecretsManager.getSecrets(options);

        KeeperRecordData newRecordData = new KeeperRecordData(
                "Sample Katacoda KSM Record (Custom record type) - Java",
                "MyCustomType",
                Arrays.asList(
                        new Login("My Login", true, false, Arrays.asList("username@email.com")), // OR new Login("username@email.com")
                        new Password("MyPassword123"),
                        new SecurityQuestions(new SecurityQuestion("What is the question?", "This is the answer!")),
                        new Phones(
                                new Phone("US", "510-444-3333", "2345", "Mobile")
                        ),
                        new Date(1641934793000L),
                        new Names(new Name("John", "Patrick", "Smith")),
                        new OneTimeCode("otpauth://totp/Example:alice@google.com?secret=JBSWY3DPEHPK3PXP&issuer=Example"),

                        new Hosts(
                                "My Custom Login lbl",
                                false,
                                false,
                                Arrays.asList(new Host("127.0.0.1", "8080"))
                        ), // OR new Hosts(Arrays.asList(new Host("127.0.0.1", "8080")))
                        // OR new Hosts("My Host Label", false, false, Arrays.asList(new Host("127.0.0.1", "8080"))),
                        new Login("login@email.com"),
                        new Url("http://localhost:8080/login")
                ),
                Arrays.asList(
                        new Phones(new Phone("US", "(510) 123-3456")),
                        new Phones(new Phone("US", "510-111-3333", "45674", "Mobile"))
                ),
                "\tThis custom type record was created\n\tvia KSM Katacoda Java Example"
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

`gradle -PmainClass=com.keepersecurity.ksmsample.KSMAddAdvancedRecord run`{{execute}}
