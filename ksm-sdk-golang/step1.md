

Install Secrets Manager Package 

`go get github.com/keeper-security/secrets-manager-go/core`{{execute}}


Navigate to the project folder

`cd ksm-sample`{{execute}}

Create sample application file
`touch main.go`{{execute}}


Open file in Editor:

`main.go`{{open}}


Sample Secrets Manager application code
Paste into `main.go` file

```golang
package main

// Import Secrets Manager
import ksm "github.com/keeper-security/secrets-manager-go/core"

func main() {

    // SM from One Time Token:
    // One time tokens can be used only once - afterwards use the generated config file
    sm := ksm.NewSecretsManagerFromSettings("<ONE TIME TOKEN>", "", true)


    // SM from CONFIG

    // configStr := `{
    //  "appKey": "8Kxn5SvtkRSsaYIur7mHKtLq3NFNB7AZRa9cqi2PSQE=",
    //  "clientId": "AQmmLePs6I9Vcr23MclXzvNJ0ZV3x6deAPyuHD9zrDmXv03JnO6Aadalikg17Px7u+DLbeY29C/OVoe4AcyfIA==",
    //  "privateKey": "MIGHAgEAMBMGByqGSM49AgEGCCaGSM49AwEHBG0wawIBAQQgWR9b5lm9NCGRysQuLsx6lSBJd63x1TjwCSZnSmBRpn6hbANCAAR4iL27W2Qbzqv/2e4i37boapTQc4aBDuf8XlMy5w84X0vz/yLvluXwLGzKZnYg/gYhCnbCXdftIGICOA9deZcP",
    //  "serverPublicKeyId": "7"
    // }`

    // config := ksm.NewMemoryKeyValueStorage(configStr) // creds is string B64 or JSON
    // sm := ksm.NewSecretsManagerFromConfig(config)



    // Retrieve all password records
    allRecords, _ := sm.GetSecrets([]string{})

    // Get password from first record:
    password := allRecords[0].Password()

    // WARNING: Avoid logging sensitive data
    print("My password from Keeper: ", password, "\n")
}
```{{copy}}


Run application

`go run main.go`{{execute}}
