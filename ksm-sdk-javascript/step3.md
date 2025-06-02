### Step 3: Retrieving Specific Records & Accessing Fields

In this step, you'll learn how to fetch specific records by their UID or Title, and how to access their standard fields, custom fields, and notes.

### 1. Prepare a Test Record

Ensure you have a record in your Keeper Vault that your KSM application can access. This record should have:
- A unique title (e.g., "My JS Test Record").
- Standard fields (e.g., login, password, URL).
- At least one custom field (e.g., Label: "API Key", Value: "mysecretapikey123").
- Some text in the notes section.

### 2. Create Script: `get_specific_record.js`

<pre class="file" data-filename="get_specific_record.js" data-target="replace">
const {
    getSecrets,
    initializeStorage,
    localConfigStorage
} = require("@keeper-security/secrets-manager-core");

// Replace with your token if myksmconfig.json doesn't exist yet
const ONE_TIME_TOKEN = "[ONE_TIME_TOKEN_IF_NEEDED]"; 
const CONFIG_FILE_NAME = "myksmconfig.json";

// Replace with the UID and Title of your test record
const TARGET_RECORD_UID = "[YOUR_RECORD_UID_HERE]";
const TARGET_RECORD_TITLE = "[YOUR_RECORD_TITLE_HERE]";

async function fetchAndDisplayRecord() {
    const storage = localConfigStorage(CONFIG_FILE_NAME);
    // Initialize storage if config file doesn't exist or token is explicitly provided
    try {
        await initializeStorage(storage, ONE_TIME_TOKEN);
        console.log("KSM storage initialized or configuration loaded.");
    } catch (e) {
        // This might happen if token is invalid and config doesn't exist, or already initialized.
        // We assume config exists or token is valid for this step.
        console.log("Proceeding with existing configuration or valid token.")
    }

    const options = { storage: storage };

    console.log(`\n--- Fetching record by UID: ${TARGET_RECORD_UID} ---`);
    try {
        const { records: recordsByUid } = await getSecrets(options, [TARGET_RECORD_UID]);
        if (recordsByUid && recordsByUid.length > 0) {
            const record = recordsByUid[0];
            console.log(`Found record by UID: ${record.title} (UID: ${record.uid})`);
            displayRecordDetails(record);
        } else {
            console.log(`Record with UID '${TARGET_RECORD_UID}' not found.`);
        }
    } catch (e) {
        console.error(`Error fetching record by UID: ${e.message}`);
    }

    console.log(`\n--- Fetching record by Title: ${TARGET_RECORD_TITLE} ---`);
    try {
        // To fetch by title, you typically list all and filter, or use a specific SDK function if available.
        // For this example, we'll filter from all secrets. 
        // Note: This can be less efficient if you have many records.
        const { records: allRecords } = await getSecrets(options);
        const recordByTitle = allRecords.find(r => r.title === TARGET_RECORD_TITLE);

        if (recordByTitle) {
            console.log(`Found record by Title: ${recordByTitle.title} (UID: ${recordByTitle.uid})`);
            // displayRecordDetails(recordByTitle); // Already displayed if same as UID search
        } else {
            console.log(`Record with Title '${TARGET_RECORD_TITLE}' not found.`);
        }
    } catch (e) {
        console.error(`Error fetching records by title: ${e.message}`);
    }
}

function displayRecordDetails(record) {
    console.log(`  Record UID: ${record.uid}`);
    console.log(`  Title: ${record.title}`);
    console.log(`  Type: ${record.type}`);

    // Standard Fields
    console.log("  Standard Fields:");
    if (record.data && record.data.fields) {
        record.data.fields.forEach(field => {
            const value = field.value ? field.value.join(', ') : '';
            const fieldType = field.type || 'N/A';
            if (fieldType.toLowerCase() === 'password' && value) {
                 console.log(`    - Type: ${fieldType}, Label: ${field.label || ''}, Value: ********`);
            } else {
                 console.log(`    - Type: ${fieldType}, Label: ${field.label || ''}, Value: ${value}`);
            }
        });
    }

    // Custom Fields
    console.log("  Custom Fields:");
    if (record.data && record.data.custom) {
        record.data.custom.forEach(field => {
            const value = field.value ? field.value.join(', ') : '';
            const fieldType = field.type || 'N/A';
            if (fieldType.toLowerCase() === 'password' && value) {
                console.log(`    - Type: ${fieldType}, Label: ${field.label || ''}, Value: ********`);
            } else {
                console.log(`    - Type: ${fieldType}, Label: ${field.label || ''}, Value: ${value}`);
            }
        });
    } else {
        console.log("    <No custom fields>");
    }

    // Notes
    console.log("  Notes:");
    const notes = record.data && record.data.notes ? record.data.notes : "<No notes>";
    console.log(`    ${notes.substring(0, 100)}${notes.length > 100 ? '...' : ''}`);
    console.log("---------------------------------------------------");
}

fetchAndDisplayRecord().catch(error => {
    console.error("An error occurred:", error);
});
</pre>

### 3. Configure Placeholders

- In `get_specific_record.js`:
    - Replace `[ONE_TIME_TOKEN_IF_NEEDED]` with your token if `myksmconfig.json` doesn't exist or you want to force re-initialization.
    - Replace `[YOUR_RECORD_UID_HERE]` with the UID of your test record.
    - Replace `[YOUR_RECORD_TITLE_HERE]` with the title of your test record.

### 4. Execute the Script

`node get_specific_record.js`{{execute}}

This will attempt to fetch the specified record by its UID and then by its title, displaying its details, including standard fields, custom fields, and notes.