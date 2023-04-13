# Caching

Currently caching is only available as a beta feature.


## Create new folder

`mkdir ksm-example-cache`{{execute}}

## Change directory

`cd ksm-example-cache`{{execute}}

## Initialize go module

`go mod init ksm-example-cache`{{execute}}

## Install the beta version of the SDK that includes caching

`go get github.com/keeper-security/secrets-manager-go/core@beta-caching`{{execute}}

## Create new code file:

`touch ksm-example-cache.go`{{execute}}

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

```

## Run Go Mod Tidy to find all referenced to the imported packages

`go mod tidy`{{execute}}

## Run application

`go run ksm-example-cache.go`{{execute}}
