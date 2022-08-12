Sample code to connect to Keeper and retrieve all records that are shared to the application.

> Note: Replace `[ONE TIME ACCESS TOKEN]` in the code with the One-Time Token generated via Web Vault or Commander

<pre class="file" data-filename="main.py" data-target="replace">
from keeper_secrets_manager_core import SecretsManager
from keeper_secrets_manager_core.storage import FileKeyValueStorage

secrets_manager = SecretsManager(
    token='[ONE TIME ACCESS TOKEN]',
    config=FileKeyValueStorage('ksm-config1.json')
)

# get all records
all_secrets = secrets_manager.get_secrets()

# print out all records
for secret in all_secrets:
    print(secret.dict)
</pre>

Run the application:

`python3 main.py`{{execute}}
