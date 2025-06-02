# Step 1: Setup, Configuration & Basic Connection

This step will guide you through setting up a new Go project, fetching the Keeper Secrets Manager (KSM) Go SDK, and writing your first Go application to connect to Keeper. We'll cover different configuration methods (file-based, in-memory) and how to list basic information about all secrets shared with your KSM application.

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

## 3. Write Your First KSM Application: Configuration & Listing Secrets

Create a `main.go` file in your project directory:

```bash
touch main.go
```
`touch main.go`{{execute}}

Now, paste the following Go code into `main.go`. This program demonstrates initializing the KSM client using different storage options (file-based, in-memory) and lists all secrets shared with your KSM application.

```go
package main

import (
	"fmt"
	"log"
	"os"
	ksm "github.com/keeper-security/secrets-manager-go/core"
	klog "github.com/keeper-security/secrets-manager-go/core/logger" // Import for logging
)

// ⚠️ IMPORTANT: Replace with your actual One-Time Token from Keeper Vault for initial file-based setup
const oneTimeTokenForFile = "[ONE_TIME_TOKEN_FOR_FILE_CONFIG]"
const configFileName = "ksm-config.json" // Will be created by the SDK on first run with file storage

// ⚠️ IMPORTANT: Replace with your Base64 encoded KSM configuration for in-memory setup
// Obtain from Keeper Vault: Secrets Manager -> Applications -> (Your App) -> Devices -> Add Device -> Configuration File
const ksmConfigBase64 = "[YOUR_KSM_CONFIG_BASE64_STRING_HERE]" 

func main() {
	// Optional: Set log level for more detailed output from the SDK
	klog.SetLogLevel(klog.DebugLevel)

	fmt.Println("🚀 KSM Go SDK Tutorial - Step 1: Configuration & Listing Secrets")

	// --- Option 1: File-Based Configuration (using One-Time Token for first run) ---
	fmt.Println("\n--- Attempting File-Based Configuration ---")
	
	// Use NewFileKeyValueStorage for storing KSM configuration locally.
	fileStorage := ksm.NewFileKeyValueStorage(configFileName)
	
	// Initialize the SecretsManager client.
	// The oneTimeTokenForFile is only used for the very first initialization with file storage.
	// Subsequent runs will use the generated ksm-config.json.
	fmt.Println("🔑 Initializing KSM with File Storage (using token if first run)...")
	smFile := ksm.NewSecretsManager(&ksm.ClientOptions{
		Config: fileStorage,
		Token:  oneTimeTokenForFile, 
	})

	if smFile != nil {
		if _, err := os.Stat(configFileName); err == nil {
			fmt.Printf("💾 File storage initialized/verified. Using config: %s\n", configFileName)
		} else {
			fmt.Printf("💾 Attempting initial file storage setup. Config file %s will be created.\n", configFileName)
		}
		listAllSecrets(smFile, "File-Based Storage")

		// Example of setting up File-Based Caching
		fmt.Println("\n💿 Setting up File Cache for File-Based Storage instance...")
		fileCache := ksm.NewFileCache("my-ksm-cache.bin") // Cache will be stored in 'my-ksm-cache.bin'
		smFile.SetCache(fileCache)
		fmt.Println("CACHE: File cache configured. Subsequent GetSecrets calls might use the cache.")
		// First call will populate cache
		_, _ = smFile.GetSecrets(nil)
		// Second call might use cache
		listAllSecrets(smFile, "File-Based Storage (with File Cache)")


	} else {
		fmt.Println("❌ Failed to initialize KSM client with file-based storage. Check token if it's the first run.")
	}

	// --- Option 2: In-Memory Configuration (using Base64 encoded config string) ---
	fmt.Println("\n\n--- Attempting In-Memory Configuration ---")
	if ksmConfigBase64 != "" && ksmConfigBase64 != "[YOUR_KSM_CONFIG_BASE64_STRING_HERE]" {
		// NewMemoryKeyValueStorage can take the Base64 encoded JSON string directly.
		// The SDK handles parsing it.
		memoryStorage := ksm.NewMemoryKeyValueStorage(ksmConfigBase64)

		fmt.Println("🧠 Initializing KSM with In-Memory Storage (from Base64 string)...")
		smMemory := ksm.NewSecretsManager(&ksm.ClientOptions{
			Config: memoryStorage,
			// Token is not needed here as the Base64 config contains all necessary keys
		})

		if smMemory != nil {
			fmt.Println("💾 In-Memory storage initialized successfully from Base64 config.")
			listAllSecrets(smMemory, "In-Memory Storage")

			// Example of setting up Memory-Based Caching
			fmt.Println("\n🧠 Setting up Memory Cache for In-Memory Storage instance...")
			memCache := ksm.NewMemoryCache()
			smMemory.SetCache(memCache)
			fmt.Println("CACHE: Memory cache configured. Subsequent GetSecrets calls might use the cache.")
			// First call will populate cache
			_, _ = smMemory.GetSecrets(nil)
			// Second call might use cache
			listAllSecrets(smMemory, "In-Memory Storage (with Memory Cache)")

		} else {
			fmt.Println("❌ Failed to initialize KSM client with in-memory storage. Check Base64 config string.")
		}
	} else {
		fmt.Println("ℹ️ Skipping In-Memory Configuration example because KSM_CONFIG_BASE64 placeholder is not replaced.")
	}
}

// Helper function to list secrets
func listAllSecrets(sm *ksm.SecretsManager, configType string) {
	fmt.Printf("\n📡 Fetching all secrets using %s...\n", configType)
	// Get all secrets shared with the application
	// Pass an empty slice or nil for recordUids to fetch all records.
	secrets, err := sm.GetSecrets(nil)
	if err != nil {
		log.Fatalf("❌ Error fetching secrets with %s: %v\n💡 Troubleshooting Tips:\n- Ensure token/config is correct and KSM application has shared records.\n- Check network connectivity.", configType, err)
	}

	fmt.Printf("✅ Successfully fetched %d record(s) using %s:\n", len(secrets), configType)

	if len(secrets) == 0 {
		fmt.Println("\nℹ️ No records found. Ensure records are shared with your KSM application in the Keeper Vault.")
	} else {
		fmt.Printf("\n--- All Shared Records (%s) ---\n", configType)
		for i, record := range secrets {
			fmt.Printf("[%d] Record UID: %s\n", i+1, record.Uid())
			fmt.Printf("    Title: %s\n", record.Title())
			fmt.Printf("    Type: %s\n", record.Type())
			
			fieldCount := len(record.GetFieldsBySection(ksm.FieldSectionBoth))
			fmt.Printf("    Fields Count: %d\n", fieldCount)
			fmt.Printf("    Files Count: %d\n", len(record.Files))
			fmt.Println("---")
		}
	}
}

```{{copy}}

## 4. Configure Your Tokens/Strings

-   **For File-Based Configuration**: In your `main.go` file, replace `[ONE_TIME_TOKEN_FOR_FILE_CONFIG]` with a valid One-Time Token from your Keeper Vault. This is only needed for the *first run* to create `ksm-config.json`.
    -   To get a token: Log into Keeper Web Vault -> Secrets Manager -> Applications -> Select/Create Application -> Devices -> Add Device -> Method: One-Time Token.
-   **For In-Memory Configuration**: In `main.go`, replace `[YOUR_KSM_CONFIG_BASE64_STRING_HERE]` with the actual Base64 encoded configuration string for your KSM application.
    -   To get this string: Log into Keeper Web Vault -> Secrets Manager -> Applications -> Select/Create Application -> Devices -> (Select existing or Add New Device) -> View: Configuration File. Copy the Base64 string.

## 5. Run the Application

Execute your Go application from the terminal within your project directory:

```bash
go run main.go
```
`go run main.go`{{execute}}

### Expected Output:

You should see output for both file-based and in-memory (if configured) initializations, followed by a list of your shared secrets. If caching is active, subsequent calls to list secrets might be faster or indicate cache usage.

```
🚀 KSM Go SDK Tutorial - Step 1: Configuration & Listing Secrets

--- Attempting File-Based Configuration ---
🔑 Initializing KSM with File Storage (using token if first run)...
💾 Storage initialized/verified. Using config: ksm-config.json

📡 Fetching all secrets using File-Based Storage...
✅ Successfully fetched X record(s) using File-Based Storage:
... (list of records) ...

💿 Setting up File Cache for File-Based Storage instance...
CACHE: File cache configured. Subsequent GetSecrets calls might use the cache.

📡 Fetching all secrets using File-Based Storage (with File Cache)...
✅ Successfully fetched X record(s) using File-Based Storage (with File Cache):
... (list of records) ...

--- Attempting In-Memory Configuration ---
🧠 Initializing KSM with In-Memory Storage (from Base64 string)...
💾 In-Memory storage initialized successfully from Base64 config.

📡 Fetching all secrets using In-Memory Storage...
✅ Successfully fetched Y record(s) using In-Memory Storage:
... (list of records) ...

🧠 Setting up Memory Cache for In-Memory Storage instance...
CACHE: Memory cache configured. Subsequent GetSecrets calls might use the cache.

📡 Fetching all secrets using In-Memory Storage (with Memory Cache)...
✅ Successfully fetched Y record(s) using In-Memory Storage (with Memory Cache):
... (list of records) ...
```

## Understanding the Code

-   **`ksm.NewFileKeyValueStorage(configFileName)`**: For file-based configuration. Manages `ksm-config.json`.
-   **`ksm.NewMemoryKeyValueStorage(ksmConfigBase64)`**: For in-memory configuration. Takes a Base64 JSON string.
-   **`ksm.NewSecretsManager(&ksm.ClientOptions{...})`**: Initializes the KSM client.
    -   `Config`: The storage mechanism (file or memory).
    -   `Token`: One-Time Token for initial file-based binding. Not needed if Base64 config is complete.
-   **`sm.SetCache(cacheImplementation)`**: Configures client-side caching.
    -   `ksm.NewFileCache("my-ksm-cache.bin")`: Stores cache on disk.
    -   `ksm.NewMemoryCache()`: Stores cache in memory.
-   **`sm.GetSecrets(nil)`**: Fetches all records.
-   **Record Access**: `record.Uid()`, `record.Title()`, `record.Type()`, `record.Files` (direct slice access), `record.GetFieldsBySection(ksm.FieldSectionBoth)` to get all fields.

## Troubleshooting

-   **Token/Config Errors**: Ensure your One-Time Token (for file setup) or Base64 string (for in-memory) is correct and from the intended KSM application.
-   **No Records Found**: Verify records are shared with your KSM application in the Keeper Vault.

In the next step, we'll explore how to create new records, including generating passwords.
