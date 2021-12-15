<pre class="file" data-filename="ksm-add-record.js" data-target="replace">

import {
    createSecret,
    downloadFile,
    getSecrets,
    initialize,
    initializeStorage,
    SecretManagerOptions,
    updateSecret
} from '../src/keeper'
import {nodePlatform} from '../src/node/nodePlatform';
import {connectPlatform} from '../src/platform';
import {loadJsonConfig} from '../src/platform';

const version = require("../package.json").version;
connectPlatform(nodePlatform)
initialize(version)

const configFileName = 'client-config-local.json'
const oneTimeToken = 'US:ONE_TIME_TOKEN'

const KSM_INITIALIZED_CONFIG = "";
const folderUid = "B82uq1fWB5J6CYnyP36bAA"


async function addLoginRecord(){

    const options = { storage: loadJsonConfig(KSM_INITIALIZED_CONFIG) }
    
    let newRec = {
        "title": "My JavaScript Record 1",
        "type": "login",
        "fields": [
            { "type": "login", "value": [ "user@website.com" ] },
            { "type": "password", "value": [ "P455Word123#" ] }
        ],
        "notes": "This is a note\nmultiline\n\n\tnote"
    }

    createSecret(options, folderUid, newRec)
}

addLoginRecord().finally()

</pre>
