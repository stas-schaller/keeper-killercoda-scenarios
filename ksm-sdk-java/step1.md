### 1. Create Java Project

```
gradle init \
--project-name ksmsample \
--package com.keepersecurity.ksmsample \
--type java-application \
--dsl groovy \
--test-framework junit
```{{execute}}

### 2. Replace `build.gradle` with KSM dependency:

<pre class="file" data-filename="build.gradle" data-target="replace">
plugins {
    id 'java'
    id 'application'
}

group 'com.keepersecurity.secrets-manager'
version '1.0-SNAPSHOT'

repositories {
    mavenCentral()
}

dependencies {
    implementation 'com.keepersecurity.secrets-manager:core:16.2.+'
}

application {
    // Define the main class for the application.
    mainClassName = project.hasProperty("mainClass") ? project.getProperty("mainClass") : "NULL"
}
</pre>

### 3. Create Java class to list records:

<pre class="file" data-filename="src/main/java/com/keepersecurity/ksmsample/KSMListRecords.java" data-target="replace">
package com.keepersecurity.ksmsample;

import com.keepersecurity.secretsManager.core.*;
import static com.keepersecurity.secretsManager.core.SecretsManager.initializeStorage;
import java.util.List;

public class KSMListRecords {

    public static void getSecrets(){
        // oneTimeToken is used only once to initialize the storage
        // after the first run, subsequent calls will use ksm-config.txt
        String oneTimeToken = "[ONE TIME TOKEN]";
        LocalConfigStorage storage = new LocalConfigStorage("ksm-config1.txt");
        try {
            initializeStorage(storage, oneTimeToken);
            SecretsManagerOptions options = new SecretsManagerOptions(storage);

            KeeperSecrets secrets = SecretsManager.getSecrets(options);

            //get records from secrets
            List&lt;KeeperRecord&gt; records = secrets.getRecords();

            for (KeeperRecord record : records) {
                System.out.println(record.getRecordUid());
            }

        } catch (Exception e) {
            System.out.println(e.getMessage());
        }
    }

    public static void main(String[] args) {
        getSecrets();
    }
}
</pre>

### 4. Modify code

Replace `[ONE TIME TOKEN]` with the code you have generated in the Keeper Web Vault

### 5. Execute Java code:

`gradle -PmainClass=com.keepersecurity.ksmsample.KSMListRecords run`{{execute}}
