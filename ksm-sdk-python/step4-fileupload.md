
# Step 4: File Upload & Attachments

## File Attachments in Keeper

Keeper records can store file attachments alongside secret data. This is useful for:
- **SSH keys and certificates** attached to server login records
- **Configuration files** for applications
- **Documentation** related to specific secrets
- **Backup codes** and recovery information

## Creating Records with File Attachments

Let's create a record and attach a file to demonstrate the file upload functionality.

### 1. Create the File Upload Script

```bash
touch main-create-record-upload-file.py
```
`touch main-create-record-upload-file.py`{{execute}}

### 2. Create a Sample File to Upload

First, let's create a sample configuration file to upload:

```bash
echo "# Sample Configuration File
app_name=KSM Tutorial App
version=1.0.0
created_by=KSM Python SDK
timestamp=$(date)" > sample-config.txt
```
`echo "# Sample Configuration File
app_name=KSM Tutorial App
version=1.0.0
created_by=KSM Python SDK
timestamp=$(date)" > sample-config.txt`{{execute}}

### 3. Add the File Upload Code

Copy and paste this code into `main-create-record-upload-file.py`:

```python
from keeper_secrets_manager_core import SecretsManager
from keeper_secrets_manager_core.dto.dtos import RecordCreate, RecordField
from keeper_secrets_manager_core.storage import FileKeyValueStorage
import os

# Initialize the Secrets Manager
secrets_manager = SecretsManager(
    token='[ONE TIME TOKEN]',
    config=FileKeyValueStorage('ksm-config4.json')
)

print("🔐 Creating a new record with file attachment...")

# Create a new login record
new_login_record = RecordCreate('login', "KSM SDK Tutorial - Record with File")
new_login_record.fields = [
    RecordField(field_type='login', value='fileuser@example.com'),
    RecordField(field_type='password', value='FileUploadDemo123!')
]
new_login_record.notes = 'Record created with file attachment\nDemonstrates KSM file upload capability'

try:
    # Create the record first
    new_record_uid = secrets_manager.create_secret('[FOLDER UID]', new_login_record)
    print(f"✅ Successfully created record!")
    print(f"📋 Record UID: {new_record_uid}")
    
    # Retrieve the newly created record
    print("\n📁 Preparing file upload...")
    record_to_have_attached_file = secrets_manager.get_secrets(new_record_uid)[0]
    
    # Define the file to upload
    file_path = './sample-config.txt'
    
    # Check if file exists
    if os.path.exists(file_path):
        print(f"📎 Uploading file: {file_path}")
        
        # Perform the file upload
        secrets_manager.upload_file_path(record_to_have_attached_file, file_path)
        
        print("✅ File uploaded successfully!")
        print(f"🔗 File attached to record: {record_to_have_attached_file.title}")
        
        # Show file information
        file_size = os.path.getsize(file_path)
        print(f"📊 File size: {file_size} bytes")
        
    else:
        print(f"❌ File not found: {file_path}")
        print("💡 Make sure the sample file was created successfully")
        
except Exception as e:
    print(f"❌ Error: {str(e)}")
    print("💡 Make sure you have:")
    print("   - Valid ONE TIME TOKEN")
    print("   - Correct FOLDER UID")
    print("   - Write permissions to the folder")
    print("   - File exists and is readable")
```
`{{copy}}`

### 4. Configure Required Parameters

Replace these placeholders in your code:

**`[ONE TIME TOKEN]`** - Your token from Keeper Web Vault

**`[FOLDER UID]`** - The UID of a shared folder with write permissions

### 5. Run the File Upload Script

```bash
python3 main-create-record-upload-file.py
```
`python3 main-create-record-upload-file.py`{{execute}}

## Understanding File Upload Process

The file upload process involves several steps:

1. **Create the record** first using `create_secret()`
2. **Retrieve the record** to get the full record object
3. **Upload the file** using `upload_file_path()`

### File Upload Methods

The KSM SDK provides multiple ways to upload files:

```python
# Upload from file path
secrets_manager.upload_file_path(record, '/path/to/file.txt')

# Upload from file-like object
with open('file.txt', 'rb') as f:
    secrets_manager.upload_file(record, f, 'filename.txt')

# Upload from bytes
file_data = b'File content as bytes'
secrets_manager.upload_file_bytes(record, file_data, 'data.bin')
```

## File Size and Type Limitations

- **Maximum file size**: Check your Keeper plan limits
- **File types**: All file types are supported
- **Multiple files**: You can attach multiple files to a single record
- **File names**: Original filenames are preserved

## Security Considerations

- **Files are encrypted** using Keeper's zero-knowledge encryption
- **Access control** follows the same rules as the parent record
- **Audit trails** track file upload and download activities
- **No file scanning** - files are stored as-is (encrypted)

## Use Cases for File Attachments

- **SSL/TLS certificates** with server credentials
- **SSH private keys** with server access records
- **API documentation** with API key records
- **Configuration templates** with application secrets
- **Recovery codes** with account credentials

## Next Steps

In the final step, we'll explore in-memory configuration storage for containerized and serverless deployments.
