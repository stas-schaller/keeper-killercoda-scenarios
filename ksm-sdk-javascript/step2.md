
### 1. Create New Script file

<pre class="file" data-filename="create-record.js" data-target="replace">
const {
    createSecret, 
    initializeStorage, 
    localConfigStorage } = require("@keeper-security/secrets-manager-core");

// oneTimeToken is used only once to initialize the storage
// after the first run, subsequent calls will use myksmconfig.json
const ONE_TIME_TOKEN = "[ONE TIME TOKEN]"

// Folder WHERE where the new record will be stored
const FOLDER_UID = "[FOLDER UID]"

async function createNewKeeperRecord() {

    const storage = localConfigStorage("myksmconfig.json")
    initializeStorage(storage, ONE_TIME_TOKEN)
    const options = { storage: storage }

    let newRec = {
        "title": "My JavaScript Record 1",
        "type": "login",
        "fields": [
            {
                "type": "login", "value": [ "My Username" ]
            },
            {
                "type": "password", "value": [ "AAAaaa123!zz" ]
            }
        ],

        "notes": "\tThis record was created\n\tvia KSM Katacoda JavaScript Example "
    }

    let newRecUid = await createSecret(options, FOLDER_UID, newRec)
    
    console.log("Record was successfully created. UID=[" + newRecUid.replace('==', '') + "]")

}

createNewKeeperRecord().finally()
</pre>

### 2. Replace Token

Replace the following placeholders:

- `[ONE TIME TOKEN]` - with the code you have generated in the Keeper Web Vault
- `[FOLDER UID]` - UID of the shared folder that is shared to the Application where this record will be stored

### 3. Execute the code:

`node create-record.js`{{execute}}
