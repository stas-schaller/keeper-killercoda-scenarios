### Step 5: Folders, In-Memory Config & Caching

This final step explores folder management (creating, listing, updating, deleting), using in-memory configuration, and implementing client-side caching.

### 1. Create Script: `manage_folders_config_cache.js`

<pre class="file" data-filename="manage_folders_config_cache.js" data-target="replace">
const {
    initializeStorage,
    localConfigStorage,
    memoryStorage,      // For in-memory configuration
    loadJsonConfig,     // Utility to load config from JSON string (can be Base64)
    getSecrets,
    createSecret,
    createFolder,
    getFolders,
    updateFolder,
    deleteFolder,
    cachingPostFunction, // For client-side caching (Node.js specific)
    SecretManagerOptions,
    KeeperFolder,
    CreateOptions
} = require("@keeper-security/secrets-manager-core");
const fs = require('fs'); // For Node.js cachingPostFunction example

const ONE_TIME_TOKEN = "[ONE_TIME_TOKEN_IF_NEEDED]"; // For initial file-based config setup if needed
const CONFIG_FILE_NAME = "myksmconfig.json";

// Option 1: Obtain KSM Config Base64 string from Keeper Vault for In-Memory Config
// Keeper Vault -> Secrets Manager -> Applications -> (Your App) -> Devices -> Add Device -> Configuration File
const KSM_CONFIG_BASE64 = "[YOUR_KSM_CONFIG_BASE64_STRING_HERE]"; // e.g., "eyJob3N0bmFtZSI6ImtlZXBlcnNlY3VyaXR5LmNvbSIsIC..."

// Option 2: Provide the UID of the root/shared folder for your application context
// This is the folder shared with your KSM App, under which other folders/records will be managed.
// If using createFolder at the top level for your app, this is required for the `createOptions.folderUid`.
const APP_ROOT_FOLDER_UID = "[YOUR_APP_ROOT_SHARED_FOLDER_UID]"; // e.g., the UID of the Shared Folder your app is configured with

async function advancedKSMOperations() {
    let options;
    let ksmStorage;

    // --- Initialize KSM Client: In-Memory or File-Based ---
    if (KSM_CONFIG_BASE64 && KSM_CONFIG_BASE64 !== "[YOUR_KSM_CONFIG_BASE64_STRING_HERE]") {
        console.log("🚀 Initializing with In-Memory Configuration...");
        // loadJsonConfig handles both plain JSON and Base64 encoded JSON
        ksmStorage = loadJsonConfig(KSM_CONFIG_BASE64);
        // For in-memory config from Base64, explicit initializeStorage with token is not usually needed afterwards.
        // The SDK will use the keys from the provided config directly.
        console.log("In-Memory storage initialized from Base64 config.");
    } else {
        console.log("🚀 Initializing with File-Based Configuration (fallback)...");
        ksmStorage = localConfigStorage(CONFIG_FILE_NAME);
        try {
            // This is needed if myksmconfig.json doesn't exist or to re-bind with a new token.
            await initializeStorage(ksmStorage, ONE_TIME_TOKEN);
            console.log("File-based storage initialized or configuration loaded.");
        } catch (e) {
            console.log("Proceeding with existing file-based configuration or if token was for initial setup.");
        }
    }
    options = { storage: ksmStorage };
    console.log("KSM Client Options Initialized.");

    // --- 1. Folder Management --- 
    console.log("\n--- Folder Management Operations --- ");
    let newFolderUid = null;
    const newFolderName = "MyJSSDK_Folder_" + Date.now();
    const updatedFolderName = newFolderName + "_Renamed";

    try {
        // a. Create a new folder
        // `createOptions.folderUid` is the shared context (e.g., app's root shared folder)
        // `createOptions.subFolderUid` (optional) is the parent folder UID within that context to create this folder under.
        // For a top-level folder in the app's view, subFolderUid might be null/undefined depending on SDK interpretation, or APP_ROOT_FOLDER_UID itself if required for clarity.
        const createFolderOpts = { 
            folderUid: APP_ROOT_FOLDER_UID, // The shared context. IMPORTANT: Replace with your actual root shared folder UID.
            // subFolderUid: null // Or specify a parent folder UID if nesting
        };
        newFolderUid = await createFolder(options, createFolderOpts, newFolderName);
        console.log(`Folder '${newFolderName}' created successfully with UID: ${newFolderUid}`);

        // b. List folders (usually lists folders within the app's configured scope)
        console.log("\nListing folders...");
        const folders = await getFolders(options);
        folders.forEach(f => console.log(`  - Folder: ${f.name}, UID: ${f.folderUid}, Parent: ${f.parentUid || 'N/A'}`));

        // c. Update the created folder (rename)
        if (newFolderUid) {
            console.log(`\nUpdating folder ${newFolderUid} to name: ${updatedFolderName}`);
            await updateFolder(options, newFolderUid, updatedFolderName);
            console.log(`Folder ${newFolderUid} renamed successfully.`);
            // Verify by listing again
            const updatedFolders = await getFolders(options);
            const foundUpdated = updatedFolders.find(f => f.folderUid === newFolderUid);
            if (foundUpdated) console.log(`Verified updated name: ${foundUpdated.name}`);
        }

        // d. Create a record inside the new folder
        if (newFolderUid) {
            console.log(`\nCreating record inside folder: ${updatedFolderName} (UID: ${newFolderUid})`);
            const recordInFolder = {
                title: "RecordIn_" + updatedFolderName,
                type: "login",
                fields: [{ type: "text", value: ["Belongs to JS SDK Folder"] }],
                notes: "This record is inside a newly created and renamed folder."
            };
            // When creating a secret, the second parameter is the folder UID where it should reside.
            const newRecordInFolderUid = await createSecret(options, newFolderUid, recordInFolder);
            console.log(`Record '${recordInFolder.title}' created in folder ${newFolderUid}, New Record UID: ${newRecordInFolderUid}`);
        }

    } catch (e) {
        console.error(`Error during folder operations: ${e.message}`, e.stack);
    }

    // --- 2. Client-Side Caching (Node.js Example) ---
    console.log("\n--- Client-Side Caching (Node.js Example) --- ");
    try {
        // The cachingPostFunction from src/node/localConfigStorage.ts uses a 'cache.dat' file.
        // It's a basic example; production systems might need more sophisticated caching.
        const optionsWithCache = {
            storage: ksmStorage, // Use the same storage as initialized before
            queryFunction: cachingPostFunction // This function handles caching logic
        };

        console.log("Fetching secrets with caching enabled (first time, might hit network)...");
        let { records: cachedRecords1 } = await getSecrets(optionsWithCache);
        console.log(`Fetched ${cachedRecords1.length} records (1st attempt).`);

        console.log("Fetching secrets again (should use cache if 'cache.dat' was created and valid)...");
        let { records: cachedRecords2 } = await getSecrets(optionsWithCache);
        console.log(`Fetched ${cachedRecords2.length} records (2nd attempt).`);
        
        // To truly test caching, you might compare response times or check if 'cache.dat' exists.
        if (fs.existsSync('cache.dat')) {
            console.log("'cache.dat' file found, indicating caching was likely used.");
            // fs.unlinkSync('cache.dat'); // Clean up cache file for next fresh run
        } else {
            console.log("'cache.dat' not found. Caching might not have occurred or was cleared.");
        }

    } catch (e) {
        console.error(`Error during caching test: ${e.message}`, e.stack);
    }

    // --- Cleanup: Delete the created folder (and its contents, if force is true and supported) ---
    if (newFolderUid) {
        console.log(`\n--- Deleting folder: ${updatedFolderName} (UID: ${newFolderUid}) ---`);
        try {
            // Set forceDeletion to true to delete non-empty folders.
            // The exact behavior of forceDeletion (e.g., if it deletes contained records) depends on SDK/backend.
            const deleteFolderResult = await deleteFolder(options, [newFolderUid], true);
            if (deleteFolderResult.folders && deleteFolderResult.folders.length > 0 && deleteFolderResult.folders[0].folderUid === newFolderUid && deleteFolderResult.folders[0].responseCode === 'success'){
                console.log(`Folder ${newFolderUid} deleted successfully.`);
            } else {
                console.error(`Failed to delete folder ${newFolderUid}. Response:`, deleteFolderResult);
            }
        } catch (e) {
            console.error(`Error deleting folder: ${e.message}`, e.stack);
        }
    }

    console.log("\nAdvanced KSM operations demo complete.");
}

advancedKSMOperations().catch(error => {
    console.error("An critical error occurred in advancedKSMOperations:", error);
});
</pre>

### 2. Configure Placeholders

- In `manage_folders_config_cache.js`:
    - Replace `[ONE_TIME_TOKEN_IF_NEEDED]` if you intend to initialize/re-initialize file-based config (`myksmconfig.json`).
    - **For In-Memory Configuration**: Replace `[YOUR_KSM_CONFIG_BASE64_STRING_HERE]` with the actual Base64 encoded configuration string for your KSM application from the Keeper Vault.
    - **Crucially for Folder Creation**: Replace `[YOUR_APP_ROOT_SHARED_FOLDER_UID]` with the UID of the main Shared Folder that your KSM Application has access to. New top-level folders created by the script will be under this root shared folder.

### 3. Execute the Script

`node manage_folders_config_cache.js`{{execute}}

This script will:
1. Initialize KSM using in-memory (if Base64 config is provided) or file-based configuration.
2. Perform folder operations: create, list, rename (update), and create a record within the new folder.
3. Demonstrate a basic client-side caching mechanism for `getSecrets` (specific to Node.js using `cachingPostFunction`).
4. Clean up by attempting to delete the folder created during the script.

Review the output and check your Keeper Vault to see the folder and record manipulations.
