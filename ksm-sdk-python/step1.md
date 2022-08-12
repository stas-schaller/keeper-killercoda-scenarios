Sample code to connect to Keeper and retrieve all records that are shared to the application.

> Note: Replace `[ONE TIME ACCESS TOKEN]` in the code with the One-Time Token generated via Web Vault or Commander

Create file `touch main.py`{{execute}} and paste code below:

```python
from keeper_secrets_manager_core import SecretsManager
from keeper_secrets_manager_core.storage import FileKeyValueStorage

secrets_manager = SecretsManager(
    # Replace Below one time token with the tocket generated in via Web Vault or KSM CLI
    token='[ONE TIME ACCESS TOKEN]',
    config=FileKeyValueStorage('ksm-config1.json')
)

# get all records
all_secrets = secrets_manager.get_secrets()

# print out all records
for secret in all_secrets:
    print(secret.dict)
```{{copy}}

Run the application:

`python3 main.py`{{execute}}
