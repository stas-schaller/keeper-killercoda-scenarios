KSM Python SDK with Cache

In the code below we will retrieve records from Keeper which will be used in local file cache.

> Note: Replace `[ONE TIME ACCESS TOKEN]` in the code with the One-Time Token generated via Web Vault or Commander


<pre class="file" data-filename="main-cache.py" data-target="replace">
from keeper_secrets_manager_core import SecretsManager
from keeper_secrets_manager_core.core import KSMCache
from keeper_secrets_manager_core.storage import FileKeyValueStorage

secrets_manager = SecretsManager(
    token='[ONE TIME ACCESS TOKEN]',
    config=FileKeyValueStorage('ksm-config.json'),
    custom_post_function=KSMCache.caching_post_function
)

# get all records
all_secrets = secrets_manager.get_secrets()

# print out all records
for secret in all_secrets:
    print(secret.dict)
</pre>

Run the application:

`python3 main-cache.py`{{execute}}
