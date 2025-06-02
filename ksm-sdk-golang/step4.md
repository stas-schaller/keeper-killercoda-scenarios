# Step 4: Advanced Config & Caching

This final step explores advanced KSM Go SDK configurations: using in-memory storage for your KSM client configuration (ideal for ephemeral environments) and implementing client-side secret caching for performance optimization.

## 1. In-Memory Configuration Storage

Instead of relying on a `ksm-config.json` file, you can initialize the KSM Go SDK with a Base64 encoded configuration string directly in memory. This is especially useful for environments like Docker containers, serverless functions (e.g., AWS Lambda, Google Cloud Functions), or CI/CD pipelines where file system persistence might be restricted or undesirable.

### How to Get the Base64 Configuration String:
1.  Log into your Keeper Web Vault.
2.  Navigate to **Secrets Manager** -> **Applications**.
3.  Select or create your KSM application.
4.  Go to the **Devices** tab.
5.  Click **ADD DEVICE**.
6.  Choose **Method: Configuration File**.
7.  **Copy the displayed Base64 encoded string**. This string contains all necessary information for your application to authenticate with KSM.

### Create Go Application: `in_memory_config_demo.go`

```bash
touch in_memory_config_demo.go
```
`touch in_memory_config_demo.go`{{execute}}

### Add the Go Code for In-Memory Storage

Paste the following code into `in_memory_config_demo.go`:

```go
package main

import (
	"fmt"
	"log"

	ksm "github.com/keeper-security/secrets-manager-go/core"
)

// ⚠️ IMPORTANT: Replace with your actual Base64 encoded KSM configuration string
const ksmConfigBase64 = "[YOUR_KSM_CONFIG_BASE64_STRING_HERE]"

func main() {
	fmt.Println("🚀 Demonstrating In-Memory KSM Configuration with Go SDK...")

	if ksmConfigBase64 == "[YOUR_KSM_CONFIG_BASE64_STRING_HERE]" || ksmConfigBase64 == "" {
		log.Fatalln("❌ Error: Please replace '[YOUR_KSM_CONFIG_BASE64_STRING_HERE]' with your actual Base64 config string.\n    You can obtain this from the Keeper Vault (Secrets Manager -> Application -> Devices -> Add Device -> Configuration File).")
	}

	// Use NewSecretsManagerFromMemory to initialize with the Base64 config string.
	// No file-based storage object is needed for this initialization method.
	sm := ksm.NewSecretsManagerFromMemory(ksmConfigBase64)

	fmt.Println("💾 KSM Storage initialized in-memory.")
	fmt.Println("📡 Fetching all secrets using in-memory config...")

	secrets, err := sm.GetSecrets(nil) // Fetch all secrets
	if err != nil {
		log.Fatalf("❌ Error fetching secrets with in-memory config: %v", err)
	}

	fmt.Printf("✅ Successfully fetched %d record(s) using in-memory configuration:\n", len(secrets))

	if len(secrets) > 0 {
		// Display up to 3 records for brevity
		for i, record := range secrets {
			if i >= 3 {
				break
			}
			fmt.Printf("    [%d] UID: %s, Title: %s, Type: %s\n",
				i+1, record.Uid(), record.Title(), record.Type())
		}
	} else {
		fmt.Println("ℹ️ No records found for this configuration.")
	}
}
```{{copy}}

### Configure Base64 String
-   In `in_memory_config_demo.go`, **replace `[YOUR_KSM_CONFIG_BASE64_STRING_HERE]`** with the actual Base64 string you copied from the Keeper Vault.

### Run the In-Memory Demo

(Assuming you update `main.go` with this code, or build and run this file directly)
```bash
go run main.go 
# OR: go build in_memory_config_demo.go && ./in_memory_config_demo
```
`go run main.go`{{execute}}

## 2. Secret Caching for Performance

The KSM Go SDK allows for client-side caching of secrets to reduce API calls and improve retrieval times for frequently accessed data.

### Create Go Application: `caching_demo.go`

```bash
touch caching_demo.go
```
`touch caching_demo.go`{{execute}}

### Add the Go Code for Caching

Paste the following code into `caching_demo.go`:

```go
package main

import (
	"fmt"
	"log"
	"os"
	"time"

	ksm "github.com/keeper-security/secrets-manager-go/core"
)

const oneTimeTokenStep4 = "[ONE_TIME_TOKEN_IF_NEEDED]" // Only if ksm-config.json doesn't exist
const configFileStep4 = "ksm-config.json"
const cacheFile = "ksm_cache.bin" // File for persisting the cache

func main() {
	fmt.Println("🚀 Demonstrating KSM Secret Caching with Go SDK...")

	// Standard file-based storage for the main KSM config
	storage := ksm.NewFileKeyValueStorage(configFileStep4)

	// Configure caching options
	// Cache will be stored in `ksm_cache.bin` and refresh every 60 seconds.
	cacheRefreshIntervalSeconds := time.Duration(60) * time.Second
	optionsWithCache := &ksm.SecretsManagerOptions{
		Storage:                            storage,
		ClientSideCacheRefreshInterval: cacheRefreshIntervalSeconds,
		Cache:                              ksm.NewFileCache(cacheFile), // Use FileCache for persistence
	}

	if _, err := os.Stat(configFileStep4); os.IsNotExist(err) && oneTimeTokenStep4 != "[ONE_TIME_TOKEN_IF_NEEDED]" {
		fmt.Println("🔑 Initial KSM storage setup with token...")
		optionsWithCache.Token = oneTimeTokenStep4
	}
	sm := ksm.NewSecretsManager(optionsWithCache)

	// --- First secrets fetch (populates cache) ---
	fmt.Println("\n--- First secrets fetch (populates cache) ---")
	startTime := time.Now()
	secrets1, err := sm.GetSecrets(nil)
	if err != nil {
		log.Fatalf("Error on first fetch: %v", err)
	}
	duration1 := time.Since(startTime)
	fmt.Printf("✅ Fetched %d records in %s (from server, cache populated).\n", len(secrets1), duration1)

	// --- Second secrets fetch (should be from cache) ---
	fmt.Println("\n--- Second secrets fetch (should be from cache) ---")
	startTime = time.Now()
	secrets2, err := sm.GetSecrets(nil)
	if err != nil {
		log.Fatalf("Error on second fetch: %v", err)
	}
	duration2 := time.Since(startTime)
	fmt.Printf("✅ Fetched %d records in %s (from cache).\n", len(secrets2), duration2)

	if duration2 < duration1 {
		fmt.Println("⚡️ Performance improvement observed due to caching!")
	}

	fmt.Printf("\nWaiting for cache to expire (configured for %s)...\n", cacheRefreshIntervalSeconds)
	time.Sleep(cacheRefreshIntervalSeconds + (5 * time.Second)) // Wait a bit longer

	// --- Third secrets fetch (cache expired, should fetch from server again) ---
	fmt.Println("\n--- Third secrets fetch (cache expired, server fetch) ---")
	startTime = time.Now()
	secrets3, err := sm.GetSecrets(nil)
	if err != nil {
		log.Fatalf("Error on third fetch: %v", err)
	}
	duration3 := time.Since(startTime)
	fmt.Printf("✅ Fetched %d records in %s (from server, cache repopulated).\n", len(secrets3), duration3)

	// Clean up cache file for the demo
	os.Remove(cacheFile)
	fmt.Printf("\n🧹 Cache file '%s' removed for demo purposes.\n", cacheFile)
}
```{{copy}}

### Configure Token (if needed for `ksm-config.json`)
-   In `caching_demo.go`, update `[ONE_TIME_TOKEN_IF_NEEDED]` if your `ksm-config.json` is not yet created from previous steps.

### Run the Caching Demo

(Assuming you update `main.go` with this code, or build and run this file directly)
```bash
go run main.go 
# OR: go build caching_demo.go && ./caching_demo
```
`go run main.go`{{execute}}

### Expected Output:

```
🚀 Demonstrating KSM Secret Caching with Go SDK...

--- First secrets fetch (populates cache) ---
✅ Fetched X records in Yms (from server, cache populated).

--- Second secrets fetch (should be from cache) ---
✅ Fetched X records in Zms (from cache).
⚡️ Performance improvement observed due to caching!

Waiting for cache to expire (configured for 60s)...

--- Third secrets fetch (cache expired, server fetch) ---
✅ Fetched X records in Wms (from server, cache repopulated).

🧹 Cache file 'ksm_cache.bin' removed for demo purposes.
```
(Timings `Y`, `Z`, `W` will vary. `Z` should be significantly faster.)

## Understanding Advanced Configurations

-   **`ksm.NewSecretsManagerFromMemory(base64ConfigString)`**: This function initializes the KSM client directly from a Base64 encoded configuration string. It bypasses the need for `FileKeyValueStorage` or an on-disk `ksm-config.json` file, making it ideal for secure, stateless environments.
-   **Caching (`SecretsManagerOptions`)**: To enable client-side caching:
    -   Set `ClientSideCacheRefreshInterval` in `SecretsManagerOptions` to a `time.Duration` (e.g., `60 * time.Second`).
    -   Provide a `Cache` implementation in `SecretsManagerOptions`. The SDK provides `ksm.NewFileCache("cache_filename.bin")` for file-based persistent caching and `ksm.NewMemoryCache()` for in-memory caching (non-persistent across application restarts).
    -   The SDK then automatically handles storing/retrieving secrets from the cache based on the refresh interval.

## Conclusion

This step covered advanced KSM Go SDK configurations, including in-memory storage for flexibility in various deployment models and client-side caching to optimize performance. With these tools, you can build highly secure and efficient Go applications leveraging Keeper Secrets Manager.

This completes the KSM Go SDK tutorial! Please review the `finish.md` tab for a summary and important next steps for production deployment.
