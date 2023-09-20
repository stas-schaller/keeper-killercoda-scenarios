
Create a new KSM Application device. Select "Method" for the authentication to be "Configuration File" and copy the base64 encoded config.

Securely store that string in your application. For this example we will use an environment variable.


Create file `touch main-inmemorystorage.py`{{execute}} and paste code below:

```python
import os
from keeper_secrets_manager_core import SecretsManager
from keeper_secrets_manager_core.dto.dtos import RecordCreate, RecordField
from keeper_secrets_manager_core.storage import InMemoryKeyValueStorage


ksm_config_b64 = os.getenv('KSM_CONFIGB64')

secrets_manager = SecretsManager(
    config=InMemoryKeyValueStorage(ksm_config_b64)
)


# get all records
all_secrets = secrets_manager.get_secrets()

# print out all records
for secret in all_secrets:
    print(secret.dict)

```{{copy}}

### 2. Execute Python code:

`python3 main-inmemorystorage.py`{{execute}}
