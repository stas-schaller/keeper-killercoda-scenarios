Let's create new file with some code in it:

<pre class="file" data-filename="ksm-example-ott.go" data-target="replace">

package main

// Import Secrets Manager
import ksm "github.com/keeper-security/secrets-manager-go/core"

func main() {

    sm := ksm.NewSecretsManagerFromSettings("[ONE TIME TOKEN]", "", true)

    allRecords, _ := sm.GetSecrets([]string{})          // Retrieve all records from Secrets Manager
    
    password := allRecords[0].Password()                // Get password from first record

    print("My password from Keeper: ", password, "\n")  // WARNING: Avoid logging sensitive data
}
</pre>

## In Terminal, navigate to ksm-sample folder:

`cd ksm-sample`{{execute}}

## Run application

`go run ksm-example-ott.go`{{execute}}
