
# Step 3: Creating Records

## Programmatic Record Creation

The KSM SDK allows you to create new records directly from your Python applications. This is useful for:
- **Automated secret provisioning** in CI/CD pipelines
- **Dynamic credential generation** for applications
- **Bulk secret imports** from other systems
- **Integration with identity providers**

## Understanding Record Types

Keeper supports various record types:
- **login**: Username/password combinations
- **bankCard**: Credit card information
- **contact**: Personal contact details
- **address**: Physical addresses
- **And many more...**

### 1. Create the Record Creation Script

```bash
touch main-create-record.py
```
`touch main-create-record.py`{{execute}}

### 2. Add the Record Creation Code

Copy and paste this code into `main-create-record.py`:

```python
from keeper_secrets_manager_core import SecretsManager
from keeper_secrets_manager_core.dto.dtos import RecordCreate, RecordField
from keeper_secrets_manager_core.storage import FileKeyValueStorage

# Initialize the Secrets Manager
secrets_manager = SecretsManager(
    token='[ONE TIME TOKEN]',
    config=FileKeyValueStorage('ksm-config3.json')
)

# Create a new login record
print("🔐 Creating a new login record...")

new_login_record = RecordCreate('login', "KSM SDK Tutorial - Sample Login")
new_login_record.fields = [
    RecordField(field_type='login', value='tutorial-user@example.com'),
    RecordField(field_type='password', value='SecurePassword123!')
]
new_login_record.notes = 'Created via KSM Python SDK Tutorial\nThis is a demonstration record'

try:
    # Create the record in the specified folder
    new_record_uid = secrets_manager.create_secret('[FOLDER UID]', new_login_record)
    print(f"✅ Successfully created record!")
    print(f"📋 New Record UID: {new_record_uid}")
    print(f"📝 Title: {new_login_record.title}")
    print(f"🔑 Type: {new_login_record.type}")
    
except Exception as e:
    print(f"❌ Error creating record: {str(e)}")
    print("💡 Make sure you have:")
    print("   - Valid ONE TIME TOKEN")
    print("   - Correct FOLDER UID")
    print("   - Write permissions to the folder")
```
`{{copy}}`

### 3. Configure Required Parameters

Replace these placeholders in your code:

**`[ONE TIME TOKEN]`** - Your token from Keeper Web Vault (same as previous steps)

**`[FOLDER UID]`** - The UID of a shared folder where you want to create the record

To get your Folder UID:
1. Log into Keeper Web Vault
2. Navigate to the folder you want to use
3. Right-click the folder → **Get Info**
4. Copy the **Folder UID**

### 4. Run the Record Creation Script

```bash
python3 main-create-record.py
```
`python3 main-create-record.py`{{execute}}

## Understanding the Code

### RecordCreate Object
```python
RecordCreate('login', "Record Title")
```
- **First parameter**: Record type (`login`, `bankCard`, etc.)
- **Second parameter**: Display title for the record

### RecordField Objects
```python
RecordField(field_type='login', value='username@email.com')
RecordField(field_type='password', value='SecurePassword123!')
```
- **field_type**: The type of field (login, password, url, etc.)
- **value**: The actual secret value to store

### Notes and Metadata
```python
new_login_record.notes = 'Additional information about this record'
```
- **notes**: Free-form text for additional context

## Security Best Practices

- **Use strong passwords** when creating login records
- **Validate input data** before creating records
- **Handle errors gracefully** to avoid exposing sensitive information
- **Log operations** for audit purposes (without logging secret values)

## Common Record Types

| Type | Description | Common Fields |
|------|-------------|---------------|
| `login` | Username/password | login, password, url |
| `bankCard` | Credit card info | cardNumber, expirationDate, securityCode |
| `contact` | Personal contacts | name, email, phone |
| `address` | Physical addresses | address1, city, state, zip |

## Next Steps

In the next step, we'll learn how to attach files to records and handle file uploads with the KSM SDK.
