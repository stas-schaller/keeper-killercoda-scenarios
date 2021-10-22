Let's create a new file that will have code example with the initialized config json

<pre class="file" data-filename="ksm-example-initconf.go" data-target="replace">

package main

// Import Secrets Manager
import ksm "github.com/keeper-security/secrets-manager-go/core"

func main() {

    // JUST FOR DEMO PURPOSE, WE ARE PLACING THIS HARDCODED STRING IN THE CODE
    // NEVER PASTE YOUR CONFIGURATION OR ONE TIME TOKE.
    // ALWAYS USE SOME OTHER SECURE STORAGE TO KEEP THIS VALUES SECURE
    configStr := `{
      "appKey": "8Kxn5SvtkRSsaYIur7mHKtLq3NFNB7AZRa9cqi2PSQE=",
      "clientId": "AQmmLePs6I9Vcr23MclXzvNJ0ZV3x6deAPyuHD9zrDmXv03JnO6Aadalikg17Px7u+DLbeY29C/OVoe4AcyfIA==",
      "privateKey": "MIGHAgEAMBMGByqGSM49AgEGCCaGSM49AwEHBG0wawIBAQQgWR9b5lm9NCGRysQuLsx6lSBJd63x1TjwCSZnSmBRpn6hbANCAAR4iL27W2Qbzqv/2e4i37boapTQc4aBDuf8XlMy5w84X0vz/yLvluXwLGzKZnYg/gYhCnbCXdftIGICOA9deZcP",
      "serverPublicKeyId": "7"
    }`

    config := ksm.NewMemoryKeyValueStorage(configStr)   // Credentials in Base64 or Json
    sm := ksm.NewSecretsManagerFromConfig(config)
    
    allRecords, _ := sm.GetSecrets([]string{})          // Retrieve all records from Secrets Manager

    password := allRecords[0].Password()                // Get password from first record

    print("My password from Keeper: ", password, "\n")  // WARNING: Avoid logging sensitive data
}

</pre>

## Run application

`go run ksm-example-initconf.go`{{execute}}
