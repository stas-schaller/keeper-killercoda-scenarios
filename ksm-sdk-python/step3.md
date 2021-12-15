
<pre class="file" data-filename="main-create-record.py" data-target="replace">
from keeper_secrets_manager_core import SecretsManager
from keeper_secrets_manager_core.dto.dtos import RecordCreate, RecordField
from keeper_secrets_manager_core.storage import FileKeyValueStorage

secrets_manager = SecretsManager(
    token='[ONE TIME TOKEN]',
    config=FileKeyValueStorage('ksm-config3.json')
)


new_login_record = RecordCreate('login', "Sample Katacoda KSM Record")
new_login_record.fields = [
    RecordField(field_type='login', value='username@email.com'),
    RecordField(field_type='password', value='Pa$$word123')
]
new_login_record.notes = 'This is a Python\nrecord creation example'

secrets_manager.create_secret('[FOLDER UID]', new_login_record)

</pre>

### 2. Modify code

Replace the following placeholders:

- `[ONE TIME TOKEN]` - with the code you have generated in the Keeper Web Vault
- `[FOLDER UID]` - UID of the shared folder that is shared to the Application

### 3. Execute Python code:

`python3 main-create-record.py`{{execute}}
