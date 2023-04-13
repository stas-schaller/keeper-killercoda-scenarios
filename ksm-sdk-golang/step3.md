Let's create a new file that will have code example with the initialized config json


```golang

package main

// Import Secrets Manager
import ksm "github.com/keeper-security/secrets-manager-go/core"

func main() {

    configStrBase64 := `[KSM CONFIG IN BASE64]`

    config := ksm.NewMemoryKeyValueStorage(configStrBase64)   // Credentials in Base64 or Json
    sm := ksm.NewSecretsManagerFromConfig(config)
    
    allRecords, _ := sm.GetSecrets([]string{})          // Retrieve all records from Secrets Manager

    title := allRecords[0].Title()                  // Get title from the first record

    print("My Title of the record: ", title, "\n")  
}

```
## Run application

`go run ksm-example-initconf.go`{{execute}}
