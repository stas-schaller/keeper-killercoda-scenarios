# Step 1: Setup & Basic Connection

This step will guide you through setting up a new Go project, fetching the Keeper Secrets Manager (KSM) Go SDK, and writing your first Go application to connect to Keeper and list basic information about all secrets shared with your KSM application.

## 1. Create a New Go Project

Open your terminal and create a new directory for your project. Then, initialize a Go module.

```bash
mkdir ksm-go-tutorial
cd ksm-go-tutorial
go mod init ksm-go-tutorial
```
`mkdir ksm-go-tutorial && cd ksm-go-tutorial && go mod init ksm-go-tutorial`{{execute}}

This creates a `go.mod` file in your `ksm-go-tutorial` directory, marking it as a Go module.

## 2. Get the KSM Go SDK Dependency

Add the Keeper Secrets Manager Go SDK to your project's dependencies:

```bash
go get github.com/keeper-security/secrets-manager-go/core
```
`go get github.com/keeper-security/secrets-manager-go/core`{{execute}}

This command downloads the SDK package and adds it to your `go.mod` and `go.sum` files.

## 3. Write Your First KSM Application: List All Secrets

Create a `main.go` file in your project directory:

```bash
touch main.go
```
`touch main.go`{{execute}}

Now, paste the following Go code into `main.go`. This program initializes the KSM client using a One-Time Token and lists all secrets shared with your KSM application.

```go
package main

import (
	"fmt"
	"log"
	"os"
	ksm "github.com/keeper-security/secrets-manager-go/core"
)

// ⚠️ IMPORTANT: Replace with your actual One-Time Token from Keeper Vault
const oneTimeToken = "[ONE_TIME_TOKEN_HERE]"
const configFileName = "ksm-config.json" // Will be created by the SDK on first run

func main() {
	fmt.Println("🚀 Attempting to connect to Keeper and list secrets...")

	// Use LocalConfigStorage for storing KSM configuration locally.
	// The SDK will create and manage this file.
	storage := ksm.NewFileKeyValueStorage(configFileName)

	// Initialize the SecretsManager client.
	// The oneTimeToken is only used for the very first initialization.
	// Subsequent runs will use the generated ksm-config.json.
	fmt.Println("🔑 Initializing KSM storage with token (if first run)...")
	sm := ksm.NewSecretsManager(&ksm.SecretsManagerOptions{
		Storage: storage,
		Token:   oneTimeToken, // Token is primarily for initial binding
	})

	// Check if the config file was created (indicates successful initialization if it was the first run)
	// On subsequent runs, the token is not strictly needed if ksm-config.json exists and is valid.
	// However, NewSecretsManager will handle re-binding if necessary (e.g. config is old/invalid).
	if _, err := os.Stat(configFileName); err == nil {
		fmt.Printf("💾 Storage initialized/verified. Using config: %s\n", configFileName)
	} else {
		fmt.Printf("💾 Attempting initial storage setup with token. Config file %s will be created.\n", configFileName)
	}

	fmt.Println("📡 Fetching all secrets...")
	// Get all secrets shared with the application
	// Pass an empty slice or nil for recordUids to fetch all records.
	secrets, err := sm.GetSecrets(nil)
	if err != nil {
		log.Fatalf("❌ Error fetching secrets: %v\n💡 Troubleshooting Tips:\n- Ensure ONE_TIME_TOKEN is correct and unused.\n- Check network connectivity.\n- Verify records are shared in Keeper Vault.", err)
	}

	fmt.Printf("✅ Successfully fetched %d record(s):\n", len(secrets))

	if len(secrets) == 0 {
		fmt.Println("\nℹ️ No records found. Ensure records are shared with your KSM application in the Keeper Vault.")
	} else {
		fmt.Println("\n--- All Shared Records ---")
		for i, record := range secrets {
			fmt.Printf("[%d] Record UID: %s\n", i+1, record.Uid())
			// Accessing Title and Type requires getting the record.Record (which is KeeperRecordData)
			// The Go SDK structure might be: record.Record.Title, record.Record.Type
			// Or via methods like record.Title(), record.Type() - checking SDK source is best.
			// For now, we'll assume direct access or simple methods as per general KSM patterns.
			// Based on common patterns, title and type might be directly on the record or nested.
			// Let's use placeholder access; we will confirm with SDK source if needed.
			fmt.Printf("    Title: %s\n", record.Title()) // Assumes a Title() method
			fmt.Printf("    Type: %s\n", record.Type())   // Assumes a Type() method
			
			// Count fields (standard + custom)
			fieldCount := 0
			if record.Record != nil {
			    fieldCount += len(record.Record.Fields)
			    fieldCount += len(record.Record.Custom)
			}
			fmt.Printf("    Fields Count: %d\n", fieldCount)
			fmt.Printf("    Files Count: %d\n", len(record.Files())) // Assumes a Files() method returning a slice
			fmt.Println("---")
		}
	}
}
```{{copy}}

## 4. Configure Your One-Time Token

-   In your `main.go` file, **replace `[ONE_TIME_TOKEN_HERE]`** with a valid One-Time Token obtained from your Keeper Vault.
    -   To get a token: Log into Keeper Web Vault -> Secrets Manager -> Applications -> Select/Create Application -> Devices -> Add Device -> Method: One-Time Token.

## 5. Run the Application

Execute your Go application from the terminal within your project directory:

```bash
go run main.go
```
`go run main.go`{{execute}}

### Expected Output:

You should see a list of your shared secrets' UIDs, titles, and types, or an appropriate error message if issues occur.

```
🚀 Attempting to connect to Keeper and list secrets...
🔑 Initializing KSM storage with token (if first run)...
💾 Storage initialized/verified. Using config: ksm-config.json
📡 Fetching all secrets...
✅ Successfully fetched X record(s):

--- All Shared Records ---
[1] Record UID: abcXYZ123...
    Title: My Sample Go Record
    Type: login
    Fields Count: 2
    Files Count: 0
---
...
```

## Understanding the Code

-   **`ksm.NewFileKeyValueStorage(configFileName)`**: This creates a storage object that will manage the `ksm-config.json` file locally. This file securely stores the application's keys and connection details after the first successful initialization.
-   **`ksm.NewSecretsManager(&ksm.SecretsManagerOptions{...})`**: Initializes the KSM client.
    -   `Storage`: The storage mechanism (file-based in this case).
    -   `Token`: The One-Time Token, primarily used for the initial binding process. If `ksm-config.json` already exists and is valid, the token might not be strictly needed for subsequent runs, but the SDK handles this gracefully.
-   **`sm.GetSecrets(nil)`**: Fetches all records shared with the KSM application. Passing `nil` or an empty slice `[]string{}` for the `recordUids` parameter retrieves all accessible records.
-   **Record Access**: The `secrets` variable is a slice of `*ksm.KeeperRecord`. Each `KeeperRecord` has methods like:
    -   `Uid()`: Returns the Record UID.
    -   `Title()`: Returns the record title (likely accesses `record.Record.Title`).
    -   `Type()`: Returns the record type (likely accesses `record.Record.Type`).
    -   `Record.Fields` and `Record.Custom`: Slices containing standard and custom field data, respectively (likely nested within `record.Record`).
    -   `Files()`: Returns a slice of file attachments.
    *(API details for fields/files will be refined by checking Go SDK source in next steps)*.

## Troubleshooting

-   **"token is invalid" or similar authentication errors**: Ensure your One-Time Token is new, correctly copied, and hasn't been used before.
-   **"no such host" or network errors**: Check your internet connection and any firewalls that might block access to Keeper servers.
-   **No Records Found**: Verify in your Keeper Vault that records are actually shared with the KSM application whose token you are using.
-   **Dependency Issues**: Ensure `go get` successfully downloaded the SDK. Check your `go.mod` file.

In the next step, we'll explore how to retrieve specific secrets and access their individual fields in detail.
