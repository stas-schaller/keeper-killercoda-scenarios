



Add KSM JavaScript Dependency

`npm install @keeper-security/secrets-manager-core`{{execute}}


Let's replace our index.js file with the new code that will use newly installed dependency and print out some details about retrieved secrets.

<pre class="file" data-filename="index.js" data-target="replace">

const {
    getSecrets,
    initializeStorage,
    localConfigStorage,
    downloadFile,
    updateSecret
} = require('@keeper-security/secrets-manager-core')

const fs = require("fs")

const getKeeperRecords = async () => {
    const storage = localConfigStorage("config.json")
    await initializeStorage(storage, "[ONE TIME TOKEN]")
    const {records} = await getSecrets({storage: storage})
    console.log(records)

    const firstRecord = records[0]
    const firstRecordPassword = firstRecord.data.fields.find(x => x.type === 'password')
    console.log(firstRecordPassword.value[0])
}

getKeeperRecords().finally()
</pre>

Now, replace `[ONE TIME TOKEN]` with the one time token you generated using Web Vault or Commander. See instructions [HERE](https://docs.keeper.io/secrets-manager/secrets-manager/about/one-time-token)

Once One time token is replaced, we are ready to execute the code and see our first real results:

`npm start`{{execute}}
