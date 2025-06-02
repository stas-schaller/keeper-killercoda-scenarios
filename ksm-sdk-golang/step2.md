# Step 2: Retrieving & Using Secrets

This step focuses on fetching specific records from Keeper Secrets Manager and accessing their various fields (standard, custom, notes) using the KSM Go SDK.

## 1. Prepare Your Environment

-   Ensure you have completed Step 1 and have a working `ksm-config.json` (or a valid One-Time Token if running examples for the first time).
-   Share at least one record with your KSM application in the Keeper Vault. For this step, this record should ideally have:
    -   A unique title (e.g., "My Go Test Record").
    -   Standard fields: e.g., a login field, a password field, a URL field.
    -   A custom field: e.g., Label: "GoAPIServiceKey", Type: Text, Value: "go_custom_api_key_456".
    -   Some text in the notes section.

## 2. Create Go Application: `get_specific_secret.go`

In your `ksm-go-tutorial` project directory, create a new Go file for this example.

```bash
touch get_specific_secret.go
```
`touch get_specific_secret.go`{{execute}}

### Add the Go Code

Paste the following code into `get_specific_secret.go`. This program will demonstrate fetching a specific record by UID or title and then display its details.

```go
package main

import (
	"fmt"
	"log"
	"os"
	"strings"

	ksm "github.com/keeper-security/secrets-manager-go/core"
)

// ⚠️ If ksm-config.json doesn't exist, replace with your One-Time Token
const oneTimeTokenStep2 = "[ONE_TIME_TOKEN_IF_NEEDED]"
const configFileStep2 = "ksm-config.json"

//  Replace with the UID or Title of a specific record shared with your KSM Application
const targetRecordUid = "[YOUR_SPECIFIC_RECORD_UID_HERE]"
const targetRecordTitle = "[YOUR_SPECIFIC_RECORD_TITLE_HERE]" // e.g., "My Go Test Record"

func main() {
	fmt.Println("🚀 Retrieving specific Go secrets and fields...")

	storage := ksm.NewFileKeyValueStorage(configFileStep2)
	options := &ksm.SecretsManagerOptions{
		Storage: storage,
	}

	// If config doesn't exist, token will be used for initialization by NewSecretsManager
	if _, err := os.Stat(configFileStep2); os.IsNotExist(err) && oneTimeTokenStep2 != "[ONE_TIME_TOKEN_IF_NEEDED]" {
		fmt.Println("🔑 Initial KSM storage setup with token...")
		options.Token = oneTimeTokenStep2
	}
	sm := ksm.NewSecretsManager(options)

	var record *ksm.KeeperRecord
	var err error

	fmt.Printf("\n--- Attempting to fetch record by UID: %s ---\n", targetRecordUid)
	// Efficiently fetch only the specified record(s) by UID
	// GetSecrets takes a slice of UIDs.
	var secretsByUid []*ksm.KeeperRecord
	if targetRecordUid != "[YOUR_SPECIFIC_RECORD_UID_HERE]" {
		secretsByUid, err = sm.GetSecrets([]string{targetRecordUid})
		if err != nil {
			log.Printf("Warning: Error fetching record by UID %s: %v\n", targetRecordUid, err)
		} else if len(secretsByUid) > 0 {
			record = secretsByUid[0]
		}
	}

	if record == nil && targetRecordTitle != "[YOUR_SPECIFIC_RECORD_TITLE_HERE]" {
		fmt.Printf("Record with UID '%s' not found or UID not provided. Trying by title: %s\n", targetRecordUid, targetRecordTitle)
		// Fallback: If not found by UID, try fetching by title
		// GetSecretByTitle returns the first match or an error if not found.
		record, err = sm.GetSecretByTitle(targetRecordTitle)
		if err != nil {
			log.Printf("Warning: Error fetching record by title '%s': %v\n", targetRecordTitle, err)
		}
	}

	if record != nil {
		fmt.Printf("✅ Found record: %s (UID: %s)\n", record.Title(), record.Uid())
		displayRecordDetails(record)
	} else {
		fmt.Printf("❌ Record with UID '%s' or Title '%s' not found.\n", targetRecordUid, targetRecordTitle)
	}
}

func displayRecordDetails(record *ksm.KeeperRecord) {
	fmt.Printf("    Type: %s\n", record.Type())

	// Accessing Standard Fields
	// The KeeperRecord struct has a field named `Record` of type `*KeeperRecordData`
	// which then contains `Fields` and `Custom` slices.
	fmt.Println("    Standard Fields:")
	if record.Record != nil && len(record.Record.Fields) > 0 {
		for _, field := range record.Record.Fields {
			// The Value of a field is an interface{}, often a slice of strings or more complex for typed fields.
			// We need to assert the type or use helper methods.
			fieldValueStr := valueToString(field.Value, field.Type)
			fmt.Printf("      - Type: %s, Label: %s, Value: %s\n", field.Type, field.Label, fieldValueStr)
		}
	} else {
		fmt.Println("      <No standard fields>")
	}

	// Simplified access using helper methods on KeeperRecord
	fmt.Println("    Helper/Direct Access Examples:")
	fmt.Printf("      - Login: %s\n", record.Login())
	fmt.Printf("      - Password: %s***\n", firstNChars(record.Password(), 3)) // Mask password

	// Accessing Custom Fields
	fmt.Println("    Custom Fields:")
	if record.Record != nil && len(record.Record.Custom) > 0 {
		for _, customField := range record.Record.Custom {
			customValueStr := valueToString(customField.Value, customField.Type)
			fmt.Printf("      - Label: %s, Type: %s, Value: %s\n", customField.Label, customField.Type, customValueStr)
		}
	} else {
		fmt.Println("      <No custom fields>")
	}

	// Accessing Notes
	notes := record.Notes()
	if notes != "" {
		fmt.Printf("    Notes: %s...\n", firstNChars(notes, 70))
	} else {
		fmt.Println("    Notes: <No notes>")
	}
	fmt.Println("---")
}

// Helper to convert field value (interface{}) to a displayable string
// The actual value structure depends on the field type (e.g., []string for login, complex struct for Name)
func valueToString(value interface{}, fieldType string) string {
	if value == nil {
		return "<empty or not set>"
	}

	lowerFieldType := strings.ToLower(fieldType)
	if lowerFieldType == "password" || lowerFieldType == "secret" || lowerFieldType == "hidden" || lowerFieldType == "onetimetoken" {
		return "********" // Mask sensitive fields
	}

	switch v := value.(type) {
	case []string:
		if len(v) > 0 {
			return strings.Join(v, ", ")
		}
		return "<empty list>"
	case string:
		return v
	default:
		// For complex types, you might use reflection or specific type assertions
		// For simplicity, we'll just use Sprintf here.
		return fmt.Sprintf("%v", v) // Generic representation
	}
}

func firstNChars(s string, n int) string {
	if len(s) > n {
		return s[:n]
	}
	return s
}

```{{copy}}

## 3. Configure Target Record Details

-   In `get_specific_secret.go`:
    -   **Crucial**: Replace `[YOUR_SPECIFIC_RECORD_UID_HERE]` with the UID of the specific record you want to fetch.
    -   Replace `[YOUR_SPECIFIC_RECORD_TITLE_HERE]` with the title of that same record (this is used as a fallback).
    -   If your `ksm-config.json` isn't created yet from Step 1, update `[ONE_TIME_TOKEN_IF_NEEDED]` with a valid One-Time Token.

## 4. Update `main.go` to Run This Example (Optional)

If you want to run this example directly via `go run main.go`, you can copy the content of `get_specific_secret.go` into `main.go`. Alternatively, you can build and run `get_specific_secret.go` separately:

```bash
go build get_specific_secret.go
./get_specific_secret
```
For simplicity in KillerCoda, we'll assume you replace the content of `main.go` with the code above for this step when you want to run it.

## 5. Run the Application

Assuming you've updated `main.go` with the content from `get_specific_secret.go` (or are running `get_specific_secret` directly):

```bash
go run main.go 
# OR if you built it: ./get_specific_secret
```
`go run main.go`{{execute}}

### Expected Output:

Details of the specified record, including its standard and custom fields, should be displayed.

```
🚀 Retrieving specific Go secrets and fields...

--- Attempting to fetch record by UID: YOUR_SPECIFIC_RECORD_UID_HERE ---
✅ Found record: My Go Test Record (UID: YOUR_SPECIFIC_RECORD_UID_HERE)
    Type: login
    Standard Fields:
      - Type: login, Label: Login, Value: go_user@example.com
      - Type: password, Label: Password, Value: ********
      - Type: url, Label: URL, Value: https://go.example.com
    Helper/Direct Access Examples:
      - Login: go_user@example.com
      - Password: MyG***
    Custom Fields:
      - Label: GoAPIServiceKey, Type: text, Value: go_custom_api_key_456
    Notes: Notes for the Go test record...
---
```

## Understanding the Code

-   **Fetching Specific Records**:
    -   `sm.GetSecrets([]string{TARGET_RECORD_UID})`: Efficiently fetches one or more records if their UIDs are known. It returns a slice of `*ksm.KeeperRecord`.
    -   `sm.GetSecretByTitle(TARGET_RECORD_TITLE)`: Fetches the first record matching the given title. Returns `*ksm.KeeperRecord` and an error.
-   **Accessing Record Data**: 
    -   The `*ksm.KeeperRecord` struct provides methods like `Uid()`, `Title()`, `Type()`, `Notes()`, `Password()`, `Login()`, `Url()`, etc.
    -   For general field access, `record.Record` (which is of type `*ksm.KeeperRecordData`) contains `Fields` (slice of `*ksm.KeeperFieldType`) and `Custom` (slice of `*ksm.KeeperFieldType`).
-   **`*ksm.KeeperFieldType`**: Each field object has:
    -   `Type`: The field type string (e.g., "login", "password", "text").
    -   `Label`: The user-defined label for the field.
    -   `Value`: An `interface{}`, which typically needs to be type-asserted to its actual underlying type (e.g., `[]string`, `string`, or a more complex struct for typed fields like `Name`, `Phone`).
-   **`valueToString` Helper**: This utility function demonstrates basic type assertion for converting `interface{}` field values to strings for display, including masking passwords.

## Next Steps

In the next step, you'll learn how to create new records, define various field types, and manage file attachments for your Go applications using the KSM SDK.
