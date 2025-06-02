# Step 4: Folder Management & Record Deletion

This step covers managing folders (create, list, update, delete) and deleting records using the KSM Go SDK.

## 1. Prepare Your Environment

-   Ensure a working `ksm-config.json` from previous steps (or a One-Time Token for the first run).
-   Have the UID of a Shared Folder where your KSM application has **"Can Edit"** permissions. This will be the parent for new folders created by the script.

## 2. Create Go Application: `manage_folders_records.go`

In your `ksm-go-tutorial` project directory, create a new Go file.

```bash
touch manage_folders_records.go
```
`touch manage_folders_records.go`{{execute}}

### Add the Go Code

Paste the following code into `manage_folders_records.go`:

```go
package main

import (
	"fmt"
	"log"
	"os"

	ksm "github.com/keeper-security/secrets-manager-go/core"
	"github.com/keeper-security/secrets-manager-go/core/fields"
)

const oneTimeTokenStep4 = "[ONE_TIME_TOKEN_IF_NEEDED]"
const configFileStep4 = "ksm-config.json"

// ⚠️ Replace with UID of a Shared Folder with "Can Edit" permissions for your KSM App
// This will serve as the root/parent for folders created in this demo.
const parentSharedFolderUid = "[YOUR_PARENT_SHARED_FOLDER_UID_HERE]"

func main() {
	fmt.Println("🚀 Managing folders and deleting records with Go SDK...")

	storage := ksm.NewFileKeyValueStorage(configFileStep4)
	options := &ksm.ClientOptions{
		Config: storage,
	}
	if _, err := os.Stat(configFileStep4); os.IsNotExist(err) && oneTimeTokenStep4 != "[ONE_TIME_TOKEN_IF_NEEDED]" {
		fmt.Println("🔑 Initial KSM storage setup with token...")
		options.Token = oneTimeTokenStep4
	}
	sm := ksm.NewSecretsManager(options)

	// --- 1. Folder Management ---
	fmt.Println("\n--- Folder Management Operations ---")
	var newFolderUid string
	var err error

	// a. Create a new folder
	newFolderName := "GoSDK_DemoFolder_" + fmt.Sprint(ksm.CurrentTimeMillis())
	fmt.Printf("📁 Creating folder: %s under parent UID: %s\n", newFolderName, parentSharedFolderUid)
	
	// CreateFolderOptions specifies parameters for folder creation
	// For creating a top-level folder within the app's view (under the main shared folder context):
	// - FolderUid: UID of the shared folder context (e.g., the one directly shared with the KSM app)
	// - SubFolderUid: Can be empty or nil if creating directly under the FolderUid context.
	//   If creating inside another folder that YOU created via SDK, then SubFolderUid would be that parent folder's UID.
	createOpts := &ksm.CreateFolderOptions{
		FolderUid: parentSharedFolderUid, // The shared context
		// SubFolderUid: "", // Or UID of an existing sub-folder to create within
	}
	createdFolder, err := sm.CreateFolder(createOpts, newFolderName, nil) // Pass nil for existing folders to avoid conflicts in this basic example
	if err != nil {
		log.Fatalf("❌ Error creating folder '%s': %v", newFolderName, err)
	}
	newFolderUid = createdFolder.Uid
	fmt.Printf("✅ Folder '%s' created successfully! UID: %s\n", createdFolder.Name, newFolderUid)

	// b. List all folders (within the application's scope)
	fmt.Println("\n--- Listing Folders ---")
	folders, err := sm.GetFolders()
	if err != nil {
		log.Printf("❌ Error listing folders: %v\n", err)
	} else {
		fmt.Printf("🔍 Found %d folder(s):\n", len(folders))
		for _, folder := range folders {
			fmt.Printf("  - Name: %s, UID: %s, Parent UID: %s\n", folder.Name, folder.Uid, folder.ParentUid)
		}
	}

	// c. Update the created folder (rename)
	updatedFolderName := newFolderName + "_Renamed"
	fmt.Printf("\n✏️ Renaming folder '%s' (UID: %s) to '%s'\n", newFolderName, newFolderUid, updatedFolderName)
	_, err = sm.UpdateFolder(newFolderUid, updatedFolderName, nil) // Pass nil for existing folders
	if err != nil {
		log.Printf("❌ Error renaming folder %s: %v\n", newFolderUid, err)
	} else {
		fmt.Printf("✅ Folder %s renamed successfully to %s.\n", newFolderUid, updatedFolderName)
	}

	// --- 2. Create a Record in the New Folder (for deletion test) ---
	fmt.Println("\n--- Creating a Test Record for Deletion ---")
	testRecordData := ksm.NewRecordCreate("login", "GoSDK_ToDelete")
	testRecordData.Fields = append(testRecordData.Fields, fields.NewLogin("delete_me@example.com"))
	testRecordUid, err := sm.CreateSecretWithRecordData("", newFolderUid, testRecordData) // Create in the new folder
	if err != nil {
		log.Fatalf("❌ Error creating test record for deletion: %v", err)
	}
	fmt.Printf("✅ Test record '%s' created successfully in folder %s. UID: %s\n", testRecordData.Title, newFolderUid, testRecordUid)

	// --- 3. Delete the Test Record ---
	fmt.Printf("\n--- Deleting Test Record (UID: %s) ---\n", testRecordUid)
	deleteResult, err := sm.DeleteSecrets([]string{testRecordUid})
	if err != nil {
		log.Printf("❌ Error deleting record %s: %v\n", testRecordUid, err)
	} else if len(deleteResult) > 0 && deleteResult[0].Status == "success" {
		fmt.Printf("✅ Record %s deleted successfully.\n", deleteResult[0].Uid)
	} else {
		fmt.Printf("⚠️ Record %s deletion may have failed or response format unexpected: %v\n", testRecordUid, deleteResult)
	}

	// --- 4. Delete the Created Folder (and its contents) ---
	// Note: Deleting a folder might require it to be empty or use a 'force' option.
	// The Go SDK's DeleteFolder takes `forceDelete bool`.
	fmt.Printf("\n--- Deleting Folder '%s' (UID: %s) ---\n", updatedFolderName, newFolderUid)
	deleteFolderResult, err := sm.DeleteFolder([]string{newFolderUid}, true) // Force delete if non-empty
	if err != nil {
		log.Printf("❌ Error deleting folder %s: %v\n", newFolderUid, err)
	} else if len(deleteFolderResult) > 0 && deleteFolderResult[0].Status == "success" {
		fmt.Printf("✅ Folder %s deleted successfully.\n", deleteFolderResult[0].Uid)
	} else {
		fmt.Printf("⚠️ Folder %s deletion may have failed or response format unexpected: %v\n", newFolderUid, deleteFolderResult)
	}

	fmt.Println("\n🎉 Folder management and record deletion examples complete. Check your Keeper Vault!")
}

```{{copy}}

## 3. Configure Parent Shared Folder UID

-   In `manage_folders_records.go`:
    -   **Crucial**: Replace `[YOUR_PARENT_SHARED_FOLDER_UID_HERE]` with the UID of a Shared Folder in your Keeper Vault where your KSM application has **"Can Edit"** permissions. This folder will act as the parent for the new folder created in this script.
    -   If needed (i.e., `ksm-config.json` doesn't exist from previous steps), update `[ONE_TIME_TOKEN_IF_NEEDED]`.

## 4. Update `main.go` to Run This Example (Optional)

Copy the content of `manage_folders_records.go` into `main.go`, or build and run this specific file:

```bash
go build manage_folders_records.go
./manage_folders_records
```

## 5. Run the Application

Assuming you've updated `main.go` or are running `manage_folders_records` directly:

```bash
go run main.go
# OR if you built it: ./manage_folders_records
```
`go run main.go`{{execute}}

### Expected Output (will vary based on success of each operation):

```
🚀 Managing folders and deleting records with Go SDK...

--- Folder Management Operations ---
📁 Creating folder: GoSDK_DemoFolder_...
✅ Folder 'GoSDK_DemoFolder_...' created successfully! UID: ...

--- Listing Folders ---
🔍 Found X folder(s):
  - Name: GoSDK_DemoFolder_..., UID: ..., Parent UID: YOUR_PARENT_SHARED_FOLDER_UID_HERE
  ...

✏️ Renaming folder 'GoSDK_DemoFolder_...' (UID: ...) to 'GoSDK_DemoFolder_..._Renamed'
✅ Folder ... renamed successfully to GoSDK_DemoFolder_..._Renamed.

--- Creating a Test Record for Deletion ---
✅ Test record 'GoSDK_ToDelete' created successfully in folder .... UID: ...

--- Deleting Test Record (UID: ...) ---
✅ Record ... deleted successfully.

--- Deleting Folder 'GoSDK_DemoFolder_..._Renamed' (UID: ...) ---
✅ Folder ... deleted successfully.

🎉 Folder management and record deletion examples complete. Check your Keeper Vault!
```

**Verify**: Check your Keeper Vault. A folder should have been created, listed, renamed, then a record created inside it, that record deleted, and finally the folder itself deleted.

## Understanding the Code

-   **`sm.CreateFolder(createOpts *CreateFolderOptions, name string, existingFolders []*KeeperFolder)`**: Creates a new folder.
    -   `createOpts.FolderUid`: UID of the parent shared context (e.g., your app's main shared folder).
    -   `createOpts.SubFolderUid`: Optional. UID of a sub-folder (that you created) to create this new folder within.
    -   `name`: The desired name for the new folder.
    -   `existingFolders`: Can often be `nil` for basic creation; used by SDK for internal checks.
-   **`sm.GetFolders()`**: Lists all folders accessible to the KSM application.
-   **`sm.UpdateFolder(folderUid, newName string, existingFolders []*KeeperFolder)`**: Renames a folder.
-   **`sm.DeleteSecrets([]string{recordUid})`**: Deletes one or more records given their UIDs. Returns a slice of `DeleteStatus` objects.
-   **`sm.DeleteFolder([]string{folderUid}, forceDelete bool)`**: Deletes one or more folders. Set `forceDelete` to `true` to attempt deletion even if the folder is not empty (behavior depends on backend/SDK logic regarding contained records).

## Conclusion

This step demonstrated how to manage the lifecycle of folders and records, including creation, listing, updating (renaming for folders), and deletion using the KSM Go SDK. These operations allow for programmatic organization and cleanup of secrets.

This completes the KSM Go SDK tutorial! Please review the `finish.md` tab for a summary of what you've learned and important next steps for production deployment.
