KSM Python SDK with Cache

Create sample application file
`touch main-cache.py`{{execute}}

Open file in Editor:

`main-cache.py`{{open}}

Sample code

```python
from keeper_secrets_manager_core import SecretsManager
from keeper_secrets_manager_core.core import KSMCache
from keeper_secrets_manager_core.storage import FileKeyValueStorage

secrets_manager = SecretsManager(
    hostname='keepersecurity.com',
    token='<One Time Access Token>',
    config=FileKeyValueStorage('ksm-config.json'),
    custom_post_function=KSMCache.caching_post_function
)

# get all records
all_secrets = secrets_manager.get_secrets()

# print out all records
for secret in all_secrets:
    print(secret.dict)
    
```{{copy}}

`python3 main-cache.py`{{execute}}
