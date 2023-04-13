Let's create new file with some code in it:

## Create new folder

`mkdir ksm-example-1`{{execute}}

## Change directory

`cd ksm-example-1`{{execute}}

## Initialize go module

`go mod init ksm-example-1`{{execute}}

## Create new code file:

`touch ksm-example-1.go`{{execute}}

## Paste the following code into the file

```golang
package main

// Import Secrets Manager
import ksm "github.com/keeper-security/secrets-manager-go/core"

func main() {

    sm := ksm.NewSecretsManagerFromSettings("[ONE TIME TOKEN]", "", true)

    allRecords, _ := sm.GetSecrets([]string{})          // Retrieve all records from Secrets Manager
    
    password := allRecords[0].Password()                // Get password from first record

    print("My password from Keeper: ", password, "\n")  // WARNING: Avoid logging sensitive data
}
```{{copy}}

## In Terminal, navigate to ksm-sample folder:

`cd ksm-sample`{{execute}}

## Run Go Mod Tidy (will import all dependencies)

`go mod tidy`{{execute}}

## Run application

`go run ksm-example-ott.go`{{execute}}
