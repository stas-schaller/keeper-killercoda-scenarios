# Step 4: File Operations

**Learning Objective**: Learn to upload, download, and manage file attachments in records using the KSM Python SDK.

## What You'll Learn
This step covers comprehensive file management operations:
- **Uploading files** to existing records
- **Downloading files** from records to local storage
- **Managing file attachments** (list, delete)
- **Working with different file types** (documents, images, certificates)
- **Best practices** for secure file handling

## Why File Operations Matter?

### **Business Benefits**:
- **Secure document storage** for certificates, keys, and configurations
- **Centralized file management** with encrypted storage
- **Automated file deployment** in CI/CD pipelines
- **Audit trails** for file access and modifications
- **Version control** for sensitive configuration files

### **Technical Benefits**:
- **API-driven file operations** for automation
- **Integration** with existing backup and deployment workflows
- **Encrypted file storage** with access controls
- **Programmatic file management** for DevOps tools

## Understanding File Types in Keeper

### **Common Use Cases**:
- **SSL/TLS Certificates**: `.pem`, `.crt`, `.key` files
- **Configuration Files**: `.json`, `.yaml`, `.ini`, `.env` files
- **SSH Keys**: Private/public key pairs
- **Docker Secrets**: Config files, environment files
- **API Documentation**: `.pdf`, `.md` files
- **Images/Screenshots**: `.png`, `.jpg` for documentation

### **Security Features**:
- **Encrypted storage** - Files are encrypted at rest
- **Access controls** - Only authorized applications can access
- **Audit logging** - All file operations are logged
- **Version tracking** - File changes are tracked

### 1. Create Sample Files for Upload

```bash
touch step4-files.py
```
`touch step4-files.py`{{execute}}

**✅ Expected Output**: File created successfully.

Let's create sample files to work with:

```bash
# Create a sample config file
echo "# Application Configuration
app_name=KSM Python SDK Demo
version=1.0.0
environment=development
api_endpoint=https://api.example.com
created_by=KSM Python SDK Tutorial
timestamp=$(date)" > sample-app-config.txt

# Create a sample certificate file
echo "-----BEGIN CERTIFICATE-----
MIIDXTCCAkWgAwIBAgIJAKoK/hKJ4iOLMA0GCSqGSIb3DQEBCwUAMEUxCzAJBgNV
BAYTAkFVMRMwEQYDVQQIDApTb21lLVN0YXRlMSEwHwYDVQQKDBhJbnRlcm5ldCBX
aWRnaXRzIFB0eSBMdGQwHhcNMjMwMTAxMDAwMDAwWhcNMjQwMTAxMDAwMDAwWjBF
MQswCQYDVQQGEwJBVTETMBEGA1UECAwKU29tZS1TdGF0ZTEhMB8GA1UECgwYSW50
ZXJuZXQgV2lkZ2l0cyBQdHkgTHRkMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIB
CgKCAQEA2Z5QHkKZHJlZJ8nZ5QHkKZHJlZJ8nZ5QHkKZHJlZJ8nZ5QHkKZHJlZJ8
nZ5QHkKZHJlZJ8nZ5QHkKZHJlZJ8nZ5QHkKZHJlZJ8nZ5QHkKZHJlZJ8nZ5QHkKZ
HJlZJ8nZ5QHkKZHJlZJ8nZ5QHkKZHJlZJ8nZ5QHkKZHJlZJ8nZ5QHkKZHJlZJ8nZ
5QHkKZHJlZJ8nZ5QHkKZHJlZJ8nZ5QHkKZHJlZJ8nZ5QHkKZHJlZJ8nZ5QHkKZHJ
lZJ8nZ5QHkKZHJlZJ8nZ5QHkKZHJlZJ8nZ5QHkKZHJlZJ8nZ5QHkKZHJlZJ8nZ5Q
HkKZHJlZJ8nZ5QHkKZHJlZJ8nZ5QHkKZHJlZJ8nZ5QHkKZHJlZJ8nZ5QHkKZHJlZ
J8nZ5QHkKZHJlZJ8nZ5QHkKZHJlZJ8nZ5QHkKZHJlZJ8nZ5QHkKZHJlZJ8nZ5QHk
-----END CERTIFICATE-----" > sample-ssl-cert.pem
```
`echo "# Application Configuration
app_name=KSM Python SDK Demo
version=1.0.0
environment=development
api_endpoint=https://api.example.com
created_by=KSM Python SDK Tutorial
timestamp=$(date)" > sample-app-config.txt`{{execute}}

`echo "-----BEGIN CERTIFICATE-----
MIIDXTCCAkWgAwIBAgIJAKoK/hKJ4iOLMA0GCSqGSIb3DQEBCwUAMEUxCzAJBgNV
BAYTAkFVMRMwEQYDVQQIDApTb21lLVN0YXRlMSEwHwYDVQQKDBhJbnRlcm5ldCBX
aWRnaXRzIFB0eSBMdGQwHhcNMjMwMTAxMDAwMDAwWhcNMjQwMTAxMDAwMDAwWjBF
MQswCQYDVQQGEwJBVTETMBEGA1UECAwKU29tZS1TdGF0ZTEhMB8GA1UECgwYSW50
ZXJuZXQgV2lkZ2l0cyBQdHkgTHRkMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIB
CgKCAQEA2Z5QHkKZHJlZJ8nZ5QHkKZHJlZJ8nZ5QHkKZHJlZJ8nZ5QHkKZHJlZJ8
nZ5QHkKZHJlZJ8nZ5QHkKZHJlZJ8nZ5QHkKZHJlZJ8nZ5QHkKZHJlZJ8nZ5QHkKZ
HJlZJ8nZ5QHkKZHJlZJ8nZ5QHkKZHJlZJ8nZ5QHkKZHJlZJ8nZ5QHkKZHJlZJ8nZ
5QHkKZHJlZJ8nZ5QHkKZHJlZJ8nZ5QHkKZHJlZJ8nZ5QHkKZHJlZJ8nZ5QHkKZHJ
lZJ8nZ5QHkKZHJlZJ8nZ5QHkKZHJlZJ8nZ5QHkKZHJlZJ8nZ5QHkKZHJlZJ8nZ5Q
HkKZHJlZJ8nZ5QHkKZHJlZJ8nZ5QHkKZHJlZJ8nZ5QHkKZHJlZJ8nZ5QHkKZHJlZ
J8nZ5QHkKZHJlZJ8nZ5QHkKZHJlZJ8nZ5QHkKZHJlZJ8nZ5QHkKZHJlZJ8nZ5QHk
-----END CERTIFICATE-----" > sample-ssl-cert.pem`{{execute}}

### 2. Add File Operations Code

Copy and paste this code into `step4-files.py`:

```python
import os
import time
from keeper_secrets_manager_core import SecretsManager
from keeper_secrets_manager_core.storage import FileKeyValueStorage, InMemoryKeyValueStorage

# Configuration - replace with your credentials
ONE_TIME_TOKEN = os.environ.get("KSM_TOKEN", "[YOUR_ONE_TIME_TOKEN_HERE]")
KSM_CONFIG_BASE64 = os.environ.get("KSM_CONFIG", "[YOUR_KSM_CONFIG_BASE64_STRING_HERE]")

# Files to upload
SAMPLE_FILES = [
    'sample-app-config.txt',
    'sample-ssl-cert.pem'
]

def initialize_secrets_manager():
    """Initialize SecretsManager with available configuration"""
    # Try in-memory config first
    if KSM_CONFIG_BASE64 and KSM_CONFIG_BASE64 != "[YOUR_KSM_CONFIG_BASE64_STRING_HERE]":
        try:
            config = InMemoryKeyValueStorage(KSM_CONFIG_BASE64)
            return SecretsManager(config=config), "In-Memory Config"
        except Exception as e:
            print(f"⚠️  In-memory config failed: {e}")
    
    # Try file-based config with token
    if ONE_TIME_TOKEN and ONE_TIME_TOKEN != "[YOUR_ONE_TIME_TOKEN_HERE]":
        try:
            config = FileKeyValueStorage('step4-config.json')
            return SecretsManager(token=ONE_TIME_TOKEN, config=config), "File-Based Config"
        except Exception as e:
            print(f"⚠️  File-based config failed: {e}")
    
    raise Exception("No valid configuration found. Please provide either KSM_CONFIG or KSM_TOKEN.")

def find_suitable_record(secrets_manager):
    """Find a record suitable for file operations"""
    print("\n🔍 Looking for a suitable record for file operations...")
    
    try:
        secrets = secrets_manager.get_secrets()
        
        if not secrets:
            print("❌ No records found. Please create a record first (see Step 3).")
            return None
        
        # Look for a record we can use (prefer ones we created)
        for secret in secrets:
            if 'KSM Python SDK' in secret.title or 'Demo' in secret.title:
                print(f"✅ Found suitable record: {secret.title}")
                return secret
        
        # If no demo record found, use the first one
        secret = secrets[0]
        print(f"✅ Using record: {secret.title}")
        return secret
        
    except Exception as e:
        print(f"❌ Error finding records: {e}")
        return None

def upload_files_to_record(secrets_manager, record):
    """Upload sample files to the specified record"""
    print(f"\n📎 Uploading files to record: {record.title}")
    
    uploaded_files = []
    
    for file_path in SAMPLE_FILES:
        if os.path.exists(file_path):
            try:
                print(f"  Uploading: {file_path}")
                
                # Upload file to the record
                file_uid = secrets_manager.upload_file(record, file_path)
                
                if file_uid:
                    file_size = os.path.getsize(file_path)
                    print(f"  ✅ Uploaded successfully: {os.path.basename(file_path)} ({file_size} bytes)")
                    uploaded_files.append({
                        'name': os.path.basename(file_path),
                        'path': file_path,
                        'uid': file_uid,
                        'size': file_size
                    })
                else:
                    print(f"  ❌ Upload failed for: {file_path}")
                    
            except Exception as e:
                print(f"  ❌ Error uploading {file_path}: {e}")
        else:
            print(f"  ⚠️  File not found: {file_path}")
    
    return uploaded_files

def list_record_files(secrets_manager, record):
    """List all files attached to a record"""
    print(f"\n📋 Files attached to record: {record.title}")
    
    try:
        # Refresh record to get latest file list
        updated_records = secrets_manager.get_secrets(uids=[record.uid])
        if updated_records:
            updated_record = updated_records[0]
            
            files = updated_record.dict.get('files', [])
            
            if files:
                print(f"  Found {len(files)} file(s):")
                for i, file_info in enumerate(files, 1):
                    file_name = file_info.get('name', 'Unknown')
                    file_size = file_info.get('size', 0)
                    file_uid = file_info.get('uid', 'No UID')
                    print(f"    {i}. {file_name} ({file_size} bytes) [UID: {file_uid}]")
                return files
            else:
                print("  No files found on this record")
                return []
        else:
            print("  ❌ Could not refresh record")
            return []
            
    except Exception as e:
        print(f"  ❌ Error listing files: {e}")
        return []

def download_files_from_record(secrets_manager, record, files_list):
    """Download files from the record"""
    print(f"\n💾 Downloading files from record: {record.title}")
    
    if not files_list:
        print("  No files to download")
        return
    
    download_dir = "downloads"
    os.makedirs(download_dir, exist_ok=True)
    
    for file_info in files_list[:2]:  # Download first 2 files
        try:
            file_name = file_info.get('name', 'unknown_file')
            file_uid = file_info.get('uid')
            
            download_path = os.path.join(download_dir, f"downloaded_{file_name}")
            
            print(f"  Downloading: {file_name}")
            
            # Download using file UID
            file_data = secrets_manager.download_file(record, file_uid)
            
            # Save to local file
            with open(download_path, 'wb') as f:
                f.write(file_data)
            
            downloaded_size = len(file_data)
            print(f"  ✅ Downloaded successfully: {download_path} ({downloaded_size} bytes)")
            
            # Verify download
            if os.path.exists(download_path):
                actual_size = os.path.getsize(download_path)
                print(f"     Verified file size: {actual_size} bytes")
            
        except Exception as e:
            print(f"  ❌ Error downloading {file_info.get('name', 'unknown')}: {e}")

def delete_file_from_record(secrets_manager, record, file_info):
    """Delete a specific file from the record"""
    file_name = file_info.get('name', 'unknown')
    file_uid = file_info.get('uid')
    
    print(f"\n🗑️  Deleting file: {file_name}")
    
    try:
        # Delete file by UID
        success = secrets_manager.delete_file(record, file_uid)
        
        if success:
            print(f"  ✅ File deleted successfully: {file_name}")
        else:
            print(f"  ❌ Failed to delete file: {file_name}")
            
    except Exception as e:
        print(f"  ❌ Error deleting file {file_name}: {e}")

def main():
    """Main execution function"""
    print("🚀 KSM Python SDK - File Operations Demo")
    print("=" * 60)
    
    try:
        # Initialize Secrets Manager
        secrets_manager, config_type = initialize_secrets_manager()
        print(f"✅ Initialized with {config_type}")
        
        # Find a suitable record for file operations
        target_record = find_suitable_record(secrets_manager)
        if not target_record:
            print("\n❌ Cannot proceed without a suitable record")
            print("💡 Create a record first using Step 3, then run this step")
            return
        
        # Upload files to the record
        uploaded_files = upload_files_to_record(secrets_manager, target_record)
        
        if uploaded_files:
            print(f"\n📊 Upload Summary: {len(uploaded_files)} file(s) uploaded successfully")
        
        # List all files on the record
        all_files = list_record_files(secrets_manager, target_record)
        
        # Download files from the record
        if all_files:
            download_files_from_record(secrets_manager, target_record, all_files)
        
        # Demonstrate file deletion (delete first uploaded file if any)
        if uploaded_files:
            file_to_delete = uploaded_files[0]
            delete_file_from_record(secrets_manager, target_record, file_to_delete)
            
            # List files again to show deletion
            print(f"\n📋 Files after deletion:")
            list_record_files(secrets_manager, target_record)
        
        print("\n✅ File operations demonstration completed!")
        print("\n📁 Downloaded files are in the 'downloads' directory")
        
    except Exception as e:
        print(f"❌ Setup failed: {e}")
        print("💡 Make sure you've provided valid credentials (token or config)")

if __name__ == "__main__":
    main()
```{{copy}}

## 3. Configure Required Parameters

### **Authentication (required)**:
**Replace ONE of these placeholders:**
- `[YOUR_ONE_TIME_TOKEN_HERE]` → Your One-Time Access Token
- `[YOUR_KSM_CONFIG_BASE64_STRING_HERE]` → Your Base64 configuration

**💡 Tip**: Use the same credentials from previous steps.

### 4. Run the File Operations Script

```bash
python3 step4-files.py
```
`python3 step4-files.py`{{execute}}

**✅ Expected Output**:
- Record selection for file operations
- File upload progress and confirmation
- File listing with details (name, size, UID)
- File download progress and verification
- File deletion demonstration
- Downloaded files in 'downloads' directory

## 🔍 Understanding the Code

### **Key File Operations**:

**1. File Upload**:
```python
file_uid = secrets_manager.upload_file(record, file_path)
# Returns the UID of the uploaded file for later reference
```

**2. File Download**:
```python
file_data = secrets_manager.download_file(record, file_uid)
# Returns file content as bytes
```

**3. File Listing**:
```python
files = record.dict.get('files', [])
# Access files metadata from record object
```

**4. File Deletion**:
```python
success = secrets_manager.delete_file(record, file_uid)
# Returns True if deletion successful
```

### **File Metadata Structure**:
Each file in a record contains:
- **`name`**: Original filename
- **`size`**: File size in bytes
- **`uid`**: Unique identifier for the file
- **`title`**: Optional file title/description
- **`type`**: MIME type of the file

### **Working with File UIDs**:
- **File UIDs are unique identifiers** for each attached file
- **Required for download and delete operations**
- **Obtained from upload operation** or file listing
- **Format**: Similar to record UIDs (e.g., `abc123def456...`)

## 🔒 Security & Best Practices

### **File Security**:
- ✅ **All files are encrypted** at rest in Keeper vault
- ✅ **Access controls apply** - only authorized apps can access
- ✅ **Audit logging** tracks all file operations
- ✅ **No size limits** for individual files (within reason)
- ❌ **Never store plaintext secrets** in uploaded files without additional encryption

### **File Management**:
- ✅ **Organize files by purpose** (certificates, configs, documentation)
- ✅ **Use descriptive filenames** for easy identification
- ✅ **Regular cleanup** of unused or outdated files
- ✅ **Version control** by including dates or versions in filenames
- ❌ **Don't upload temporary files** or cache files

### **Error Handling**:
- ✅ **Check file existence** before upload
- ✅ **Verify download success** by checking file size
- ✅ **Handle network failures** gracefully
- ✅ **Implement retry logic** for failed operations

## Real-World File Operation Examples

### **SSL Certificate Management**:
```python
# Upload certificate files
cert_uid = secrets_manager.upload_file(ssl_record, 'server.crt')
key_uid = secrets_manager.upload_file(ssl_record, 'server.key')
ca_uid = secrets_manager.upload_file(ssl_record, 'ca-bundle.crt')

# Download for deployment
cert_data = secrets_manager.download_file(ssl_record, cert_uid)
with open('/etc/ssl/certs/server.crt', 'wb') as f:
    f.write(cert_data)
```

### **Configuration File Deployment**:
```python
# Upload app config
config_uid = secrets_manager.upload_file(app_record, 'app-config.json')

# Download and deploy
config_data = secrets_manager.download_file(app_record, config_uid)
with open('/app/config/production.json', 'wb') as f:
    f.write(config_data)
```

### **Docker Secret Management**:
```python
# Upload Docker environment file
env_uid = secrets_manager.upload_file(docker_record, '.env.production')

# Download for container deployment
env_data = secrets_manager.download_file(docker_record, env_uid)
with open('/docker/secrets/.env', 'wb') as f:
    f.write(env_data)
```

## Troubleshooting

**❌ "File not found" error**: Check that the file exists and path is correct

**❌ "Upload failed" error**: Verify record permissions and file isn't corrupted

**❌ "Download failed" error**: Ensure file UID is correct and file still exists

**❌ "Permission denied" error**: Check that your application has edit permissions on the record

**❌ Large file uploads failing**: Consider file size limits and network timeouts

## Next Steps

**💡 Real-world use case**: You now have secure file management capabilities for certificates, configurations, and sensitive documents.

**🔜 Coming up**: In Step 5, you'll learn folder management and advanced organizational features.

**📚 Learn More**: [Official KSM Python SDK Documentation](https://docs.keeper.io/en/keeperpam/secrets-manager/developer-sdk-library/python-sdk)