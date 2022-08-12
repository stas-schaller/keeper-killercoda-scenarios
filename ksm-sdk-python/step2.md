### 1. Create new Python file

Create file `touch main-cache.py`{{execute}} and paste code below:

```python
from keeper_secrets_manager_core import SecretsManager
from keeper_secrets_manager_core.core import KSMCache
from keeper_secrets_manager_core.storage import FileKeyValueStorage

secrets_manager = SecretsManager(
    token='[ONE TIME TOKEN]',
    config=FileKeyValueStorage('ksm-config2.json'),
    custom_post_function=KSMCache.caching_post_function
)

# get all records
all_secrets = secrets_manager.get_secrets()

# print out all records
for secret in all_secrets:
    print(secret.dict)
```

### 2. Modify code

Replace the following placeholders:

- `[ONE TIME TOKEN]` - with the code you have generated in the Keeper Web Vault

### 3. Execute Java code:

`python3 main-cache.py`{{execute}}
