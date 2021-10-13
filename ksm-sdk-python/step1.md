
Install KSM SDK

`pip3 install -U keeper-secrets-manager-core`{{execute}}


Create sample application file
`touch main.py`{{execute}}


Open file in Editor:

`main.py`{{open}}

Sample code
```python
from keeper_secrets_manager_core import SecretsManager
from keeper_secrets_manager_core.storage import FileKeyValueStorage

secrets_manager = SecretsManager(
    hostname='keepersecurity.com',
    token='<One Time Access Token>',
    config=FileKeyValueStorage('ksm-config.json')
)

# get all records
all_secrets = secrets_manager.get_secrets()

# print out all records
for secret in all_secrets:
    print(secret.dict)

```{{copy}}

`python3 main.py`{{execute}}
