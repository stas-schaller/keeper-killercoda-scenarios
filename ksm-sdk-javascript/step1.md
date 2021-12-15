### 1. Initialize NPM `package.json` file:

<pre class="file" data-filename="package.json" data-target="replace">
{
  "name": "ksm-helloworld",
  "version": "1.0.0",
  "dependencies": {
    "@keeper-security/secrets-manager-core": "^16.2.1"
  }
}
</pre>

### 2. Install dependencies

`npm install`{{execute}}

### 3. Create Sample JavaScript Code

<pre class="file" data-filename="list_records.js" data-target="replace">
const {
    getSecrets, 
    initializeStorage, 
    localConfigStorage } = require("@keeper-security/secrets-manager-core");

const getKeeperRecords = async () => {
    const storage = localConfigStorage("myksmconfig.json")
    await initializeStorage(storage, "[ONE TIME TOKEN]")
    const {records} = await getSecrets({storage: storage}) // Retrieve all records shared to this application
    
    console.log("\n---------------------------------------------------")
    console.log("Preview of the response from the server")
    console.log(records)

    const firstRecord = records[0] // Getting the first record for this application
    const firstRecordPassword = firstRecord.data.fields.find(x => x.type === 'password')
    console.log("\n---------------------------------------------------")
    console.log("Password of the first record: " + firstRecordPassword.value[0])
}

getKeeperRecords().finally()
</pre>

### 4. Replace Token
Replace `[ONE TIME TOKEN]` with the one time token you generated using Web Vault or Commander. See instructions [HERE](https://docs.keeper.io/secrets-manager/secrets-manager/about/one-time-token)

### 5. Execute the code:

`node list_records.js`{{execute}}
