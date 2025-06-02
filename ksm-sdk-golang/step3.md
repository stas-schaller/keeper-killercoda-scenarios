# Step 3: Creating Records & Files

This step covers how to programmatically create new records with different field types and manage file attachments using the KSM Go SDK.

## 1. Prepare Your Environment

-   Ensure a working `ksm-config.json` from previous steps (or a One-Time Token for the first run).
-   Have the UID of a Shared Folder where your KSM application has **"Can Edit"** permissions. New records will be created here.
-   Create a sample file in your project directory for upload, e.g., `go-sample-upload.txt`.

```bash
echo "This is a Go SDK test file for upload purposes." > go-sample-upload.txt
ls -l go-sample-upload.txt
```
`echo "This is a Go SDK test file for upload purposes." > go-sample-upload.txt && ls -l go-sample-upload.txt`{{execute}}

## 2. Create Go Application: `create_manage_secrets.go`

In your `ksm-go-tutorial` project directory, create a new Go file.

```bash
touch create_manage_secrets.go
```
`touch create_manage_secrets.go`{{execute}}

### Add the Go Code

Paste the following code into `create_manage_secrets.go`. This program demonstrates creating records and uploading a file.

```go
package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"os"

	ksm "github.com/keeper-security/secrets-manager-go/core"
	"github.com/keeper-security/secrets-manager-go/core/fields"
)

const oneTimeTokenStep3 = "[ONE_TIME_TOKEN_IF_NEEDED]"
const configFileStep3 = "ksm-config.json"

// ⚠️ Replace with UID of a Shared Folder with "Can Edit" permissions for your KSM App
const targetSharedFolderUid = "[YOUR_SHARED_FOLDER_UID_HERE]"
const fileToUploadName = "go-sample-upload.txt"

func main() {
	fmt.Println("🚀 Creating records and managing files with Go SDK...")

	storage := ksm.NewFileKeyValueStorage(configFileStep3)
	options := &ksm.SecretsManagerOptions{
		Storage: storage,
	}
	if _, err := os.Stat(configFileStep3); os.IsNotExist(err) && oneTimeTokenStep3 != "[ONE_TIME_TOKEN_IF_NEEDED]" {
		fmt.Println("🔑 Initial KSM storage setup with token...")
		options.Token = oneTimeTokenStep3
	}
	sm := ksm.NewSecretsManager(options)

	// --- 1. Create a New Login Record ---
	fmt.Println("\n--- Creating New Login Record ---")

	// For creating records, you typically construct a KeeperRecordData-like object or use helper functions.
	// The Go SDK uses specific field type constructors from the `fields` sub-package.
	newLoginRecordData := ksm.NewRecordCreate("login", "Go SDK Auto-Login")
	newLoginRecordData.Notes = "Created via Go SDK with standard and custom fields."

	// Add Standard Fields
	// The New<FieldType> constructors (e.g., fields.NewLogin, fields.NewPassword) are used.
	// The first argument is the value, subsequent optional arguments might be label, required, privacyScreen.
	newLoginRecordData.Fields = append(newLoginRecordData.Fields, fields.NewLogin("gopher@example.com"))
	generatedPassword, _ := ksm.GeneratePassword(16, 0, 0, 4, 4) // length 16, any caps/lowercase, 4 digits, 4 special
	newLoginRecordData.Fields = append(newLoginRecordData.Fields, fields.NewPassword(generatedPassword))
	newLoginRecordData.Fields = append(newLoginRecordData.Fields, fields.NewUrl("https://golang.example.com"))

	// Add Custom Fields
	// For custom fields, you provide a label.
	customField1 := fields.NewText("myCustomGoValue123")
	customField1.Label = "GoCustomFieldLabel"
	newLoginRecordData.Custom = append(newLoginRecordData.Custom, customField1)

	customSecretField := fields.NewSecret("supersecretgokey") // `secret` type hides value by default
	customSecretField.Label = "GoAPIToken"
	newLoginRecordData.Custom = append(newLoginRecordData.Custom, customSecretField)

	// Create the secret. CreateSecretWithRecordData expects a folder UID and the RecordCreate object.
	// The first parameter (record UID) can be an empty string to let Keeper generate it.
	newLoginRecordUid, err := sm.CreateSecretWithRecordData("", targetSharedFolderUid, newLoginRecordData)
	if err != nil {
		log.Fatalf("❌ Error creating login record: %v", err)
	}
	fmt.Printf("✅ Login Record created successfully! UID: %s, Title: %s\n", newLoginRecordUid, newLoginRecordData.Title)

	// --- 2. Upload a File to the Newly Created Login Record ---
	fmt.Println("\n--- Uploading File to New Login Record ---")
	fileBytes, err := ioutil.ReadFile(fileToUploadName)
	if err != nil {
		log.Printf("❌ Error reading file %s for upload: %v. Skipping upload.\n", fileToUploadName, err)
	} else {
		// To upload a file, you need the actual KeeperRecord object, not just the UID.
		// So, we should fetch the record we just created.
		records, err := sm.GetSecrets([]string{newLoginRecordUid})
		if err != nil || len(records) == 0 {
			log.Fatalf("❌ Error fetching newly created record %s for file upload: %v", newLoginRecordUid, err)
		}
		ownerRecord := records[0]

		fileUpload := &ksm.KeeperFileUpload{
			Name:  fileToUploadName,
			Title: "Go SDK Uploaded Config",
			// Type: "text/plain", // MIME type, optional, SDK might infer
			Data:  fileBytes,
		}

		fmt.Printf("📎 Uploading '%s' to record UID: %s\n", fileUpload.Name, ownerRecord.Uid())
		_, err = sm.UploadFile(ownerRecord, fileUpload) // UploadFile returns file UID and error
		if err != nil {
			log.Fatalf("❌ Error uploading file: %v", err)
		}
		fmt.Printf("✅ File '%s' uploaded successfully to record UID: %s.\n", fileUpload.Name, ownerRecord.Uid())

		// Verify by listing files for that record
		updatedRecord, err := sm.GetSecretByUid(newLoginRecordUid) // Assuming GetSecretByUid exists
		if err == nil && updatedRecord != nil {
			found := false
			for _, f := range updatedRecord.Files() {
				if f.Name == fileToUploadName {
					fmt.Println("    Verification: File found on record after upload.")
					found = true
					break
				}
			}
			if !found {
				fmt.Println("    Verification: File NOT found on record after upload.")
			}
		} else {
			fmt.Println("    Verification: Could not re-fetch record to verify file upload.")
		}
	}

	fmt.Println("\n🎉 Record creation and file management examples complete. Check your Keeper Vault!")
}

```{{copy}}

## 3. Configure Shared Folder UID

-   In `create_manage_secrets.go`:
    -   **Crucial**: Replace `[YOUR_SHARED_FOLDER_UID_HERE]` with the UID of a Shared Folder in your Keeper Vault where your KSM application has **"Can Edit"** permissions.
    -   If needed (i.e., `ksm-config.json` doesn't exist from previous steps), update `[ONE_TIME_TOKEN_IF_NEEDED]`.

## 4. Update `main.go` to Run This Example (Optional)

As in Step 2, if you want to use `go run main.go`, copy the content of `create_manage_secrets.go` into `main.go`. Otherwise, build and run this specific file:

```bash
go build create_manage_secrets.go
./create_manage_secrets
```

## 5. Run the Application

Assuming you've updated `main.go` or are running `create_manage_secrets` directly:

```bash
go run main.go
# OR if you built it: ./create_manage_secrets
```
`go run main.go`{{execute}}

### Expected Output:

```
🚀 Creating records and managing files with Go SDK...

--- Creating New Login Record ---
✅ Login Record created successfully! UID: ..., Title: Go SDK Auto-Login

--- Uploading File to New Login Record ---
📎 Uploading 'go-sample-upload.txt' to record UID: ...
✅ File 'go-sample-upload.txt' uploaded successfully to record UID: ...
    Verification: File found on record after upload.

🎉 Record creation and file management examples complete. Check your Keeper Vault!
```

**Verify**: Check your Keeper Vault. A new record titled "Go SDK Auto-Login" should be in your target shared folder, with fields populated and `go-sample-upload.txt` attached to it.

## Understanding the Code

-   **Record Creation (`ksm.NewRecordCreate`)**: To create a new record, you first instantiate a `RecordCreate` struct, providing the record type (e.g., "login") and title.
-   **Adding Fields (`newRecordData.Fields`, `newRecordData.Custom`)**:
    -   Standard and custom fields are added to the `Fields` and `Custom` slices of the `RecordCreate` struct, respectively.
    -   The KSM Go SDK provides helper functions in the `fields` sub-package (e.g., `fields.NewLogin("value")`, `fields.NewPassword("value")`, `fields.NewText("value")`) to create field objects.
    -   For custom fields, you create a field (e.g., `customField := fields.NewText("value")`) and then set its `Label` property (e.g., `customField.Label = "My Custom Label"`).
-   **`sm.CreateSecretWithRecordData("", folderUid, recordData)`**: This function creates the record in the specified `folderUid`. Passing an empty string for the first argument (record UID) allows Keeper to generate it.
-   **File Upload (`*ksm.KeeperFileUpload`, `sm.UploadFile`)**:
    -   You create a `*ksm.KeeperFileUpload` struct, providing `Name` (filename), `Title` (display name in Keeper), and `Data` (a `[]byte` slice of the file content).
    -   The `sm.UploadFile(ownerRecord, fileUpload)` function uploads the file. It requires the `*ksm.KeeperRecord` object of the record to which the file will be attached (not just its UID), so you might need to fetch the record after creating it if you want to attach a file immediately.
-   **`ksm.GeneratePassword()`**: A utility function to generate strong random passwords.

## Next Steps

In the final step, we'll explore advanced configuration options for the Go SDK, such as in-memory configuration storage and client-side caching for performance.


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
