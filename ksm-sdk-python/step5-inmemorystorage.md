
Create file `touch main-inmemorystorage.py`{{execute}} and paste code below:

```python
from keeper_secrets_manager_core import SecretsManager
from keeper_secrets_manager_core.dto.dtos import RecordCreate, RecordField
from keeper_secrets_manager_core.storage import InMemoryKeyValueStorage

secrets_manager = SecretsManager(
    config=InMemoryKeyValueStorage('[BASE64 CONFIG]')
)


# get all records
all_secrets = secrets_manager.get_secrets()

# print out all records
for secret in all_secrets:
    print(secret.dict)

```{{copy}}

### 2. Modify code

Replace the following placeholders:

- `[BASE64 CONFIG]` - with the base64 Config

### 3. Execute Python code:

`python3 main-inmemorystorage.py`{{execute}}
