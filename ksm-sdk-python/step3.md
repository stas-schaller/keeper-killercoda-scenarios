# Step 3: Record Creation & Updates

**Learning Objective**: Learn to create new records programmatically and update existing secrets using the KSM Python SDK.

## What You'll Learn
This step covers essential record management operations:
- **Creating new login records** with generated passwords
- **Updating existing secret fields** programmatically  
- **Working with different record types** (login, database, etc.)
- **Managing custom fields** and metadata
- **Best practices** for automated secret management

## Why Programmatic Record Management?

### **Business Benefits**:
- **Automated secret provisioning** in CI/CD pipelines
- **Dynamic credential generation** for temporary access
- **Bulk secret imports** and migrations
- **Consistent security policies** across all credentials
- **Reduced manual errors** in secret management

### **Technical Benefits**:
- **API-driven workflows** for DevOps automation
- **Integration** with existing infrastructure tools
- **Audit trails** for all secret operations
- **Programmatic password policies** enforcement

## Understanding Record Types

Keeper supports many record types for different use cases:

### **Common Record Types**:
- **`login`**: Username/password combinations (most common)
- **`databaseCredentials`**: Database connection details
- **`sshKeys`**: SSH key pairs and connection info
- **`bankCard`**: Credit card information
- **`contact`**: Personal contact details
- **`file`**: Secure file storage with metadata

### **Field Types**:
- **`login`**: Username fields
- **`password`**: Password fields (encrypted)
- **`url`**: Website/service URLs
- **`text`**: Custom text fields
- **`secret`**: Sensitive custom data (encrypted)
- **`email`**: Email addresses
- **`phone`**: Phone numbers

### 1. Create the Record Management Script

```bash
touch step3-records.py
```
`touch step3-records.py`{{execute}}

**✅ Expected Output**: File created successfully.

### 2. Add Record Management Code

**⚠️ Important**: You'll need a shared folder UID where your application has edit permissions.

Copy and paste this code into `step3-records.py`:

```python
import os
import secrets
import string
from keeper_secrets_manager_core import SecretsManager
from keeper_secrets_manager_core.dto.dtos import RecordCreate, RecordField
from keeper_secrets_manager_core.storage import FileKeyValueStorage, InMemoryKeyValueStorage
from keeper_secrets_manager_core.utils import generate_password

# Configuration - replace with your credentials
ONE_TIME_TOKEN = os.environ.get("KSM_TOKEN", "[YOUR_ONE_TIME_TOKEN_HERE]")
KSM_CONFIG_BASE64 = os.environ.get("KSM_CONFIG", "[YOUR_KSM_CONFIG_BASE64_STRING_HERE]")
TARGET_FOLDER_UID = os.environ.get("KSM_TARGET_FOLDER_UID", "[YOUR_TARGET_FOLDER_UID_HERE]")

def generate_strong_password(length=16):
    """Generate a cryptographically secure password"""
    # Use KSM's built-in password generator if available, fallback to custom
    try:
        return generate_password(length=length)
    except:
        # Fallback password generation
        alphabet = string.ascii_letters + string.digits + "!@#$%^&*"
        return ''.join(secrets.choice(alphabet) for _ in range(length))

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
            config = FileKeyValueStorage('step3-config.json')
            return SecretsManager(token=ONE_TIME_TOKEN, config=config), "File-Based Config"
        except Exception as e:
            print(f"⚠️  File-based config failed: {e}")
    
    raise Exception("No valid configuration found. Please provide either KSM_CONFIG or KSM_TOKEN.")

def create_login_record(secrets_manager):
    """Create a new login record with generated password"""
    print("\n🔐 Creating a new login record with generated password...")
    
    # Generate strong credentials
    new_password = generate_strong_password(length=20)
    api_key = generate_strong_password(length=32)
    
    print(f"🔑 Generated Password: {new_password}")
    print(f"🗝️  Generated API Key: {api_key[:8]}...")
    
    # Create the record structure
    new_login_record = RecordCreate(
        record_type='login',
        title="KSM Python SDK - Demo Login Record"
    )
    
    # Add standard fields
    new_login_record.fields = [
        RecordField(field_type='login', value=['sdk.demo.user@example.com']),
        RecordField(field_type='password', value=[new_password]),
        RecordField(field_type='url', value=['https://demo-app.example.com'])
    ]
    
    # Add notes
    new_login_record.notes = 'Created via KSM Python SDK Tutorial\nPassword was generated automatically\nFor demonstration purposes only'
    
    # Add custom fields
    custom_fields = [
        RecordField(field_type='text', label='Environment', value=['Development']),
        RecordField(field_type='secret', label='API Key', value=[api_key]),
        RecordField(field_type='text', label='Created By', value=['KSM Python SDK Tutorial'])
    ]
    new_login_record.fields.extend(custom_fields)
    
    return new_login_record, new_password

def update_existing_record(secrets_manager):
    """Demonstrate updating an existing record"""
    print("\n🔄 Demonstrating record updates...")
    
    try:
        # Get all secrets to find one to update
        secrets = secrets_manager.get_secrets()
        
        if len(secrets) > 0:
            # Get the first secret for demonstration
            secret = secrets[0]
            print(f"Updating secret: {secret.title}")
            
            # Update a field (e.g., add/update a custom field)
            try:
                # Add or update a custom field
                secret.set_custom_field_value('Last Updated', 'Updated via KSM Python SDK')
                
                # Save the changes
                result = secrets_manager.save(secret)
                
                if result:
                    print(f"✅ Successfully updated record: {secret.title}")
                    print(f"   Added/Updated 'Last Updated' field")
                else:
                    print(f"❌ Failed to save record updates")
                    
            except Exception as update_error:
                print(f"❌ Error updating record fields: {update_error}")
                
        else:
            print("ℹ️  No existing records found to update")
            
    except Exception as e:
        print(f"❌ Error accessing records for update: {e}")

def main():
    """Main execution function"""
    print("🚀 KSM Python SDK - Record Creation & Updates Demo")
    print("" + "="*60)
    
    try:
        # Initialize Secrets Manager
        secrets_manager, config_type = initialize_secrets_manager()
        print(f"✅ Initialized with {config_type}")
        
        # Test connection
        secrets = secrets_manager.get_secrets()
        print(f"📋 Found {len(secrets)} existing secret(s)")
        
        # Demonstrate record updates first (safer)
        update_existing_record(secrets_manager)
        
        # Demonstrate record creation (requires folder UID)
        if TARGET_FOLDER_UID and TARGET_FOLDER_UID != "[YOUR_TARGET_FOLDER_UID_HERE]":
            try:
                print(f"\n📁 Target folder UID: {TARGET_FOLDER_UID}")
                
                new_record, password = create_login_record(secrets_manager)
                new_record_uid = secrets_manager.create_secret(TARGET_FOLDER_UID, new_record)
                
                print(f"\n✅ Successfully created new record!")
                print(f"📋 New Record UID: {new_record_uid}")
                print(f"📝 Title: {new_record.title}")
                print(f"🔐 Type: {new_record.record_type}")
                print(f"🔒 Generated Password: {password}")
                
                # Verify the created record
                created_record = secrets_manager.get_secrets(uids=[new_record_uid])[0]
                print(f"\n🔍 Verification - Retrieved created record:")
                print(f"   Title: {created_record.title}")
                print(f"   Fields: {len(created_record.dict.get('fields', []))} field(s)")
                
            except Exception as create_error:
                print(f"❌ Record creation failed: {create_error}")
                print(f"💡 Make sure folder UID '{TARGET_FOLDER_UID}' exists and has edit permissions")
                
        else:
            print("\n⏭️  Skipping record creation: Replace '[YOUR_TARGET_FOLDER_UID_HERE]' with actual folder UID")
            print("📖 How to get folder UID: Keeper Vault → Right-click folder → Get Info → Copy UID")
            
        print("\n✅ Record management demonstration completed!")
        
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

### **Folder UID (required for creation)**:
`[YOUR_TARGET_FOLDER_UID_HERE]` → UID of a shared folder with edit permissions

**How to get Folder UID:**
1. Log into Keeper Web Vault
2. Navigate to a shared folder
3. Right-click → **"Get Info"**
4. Copy the **Folder UID**
5. Ensure your application has **"Can Edit"** permissions

**⚠️ Note**: Record updates work without folder UID, but creation requires it.

### 4. Run the Record Management Script

```bash
python3 step3-records.py
```
`python3 step3-records.py`{{execute}}

**✅ Expected Output**:
- Connection confirmation
- Record update demonstration
- New record creation (if folder UID provided)
- Generated passwords and API keys
- Verification of created records

## 🔍 Understanding the Code

### **Key Components**:

**1. Password Generation**:
```python
from keeper_secrets_manager_core.utils import generate_password
new_password = generate_password(length=20)  # Strong, random password
```

**2. Record Structure**:
```python
record = RecordCreate(record_type='login', title='My Record')
record.fields = [
    RecordField(field_type='login', value=['username']),
    RecordField(field_type='password', value=[password])
]
```

**3. Field Types**:
- **Standard fields**: `login`, `password`, `url`
- **Custom fields**: Use `label` parameter for custom field names
- **Value format**: Always use lists `value=['data']`

**4. Record Operations**:
- **Create**: `secrets_manager.create_secret(folder_uid, record)`
- **Update**: `secret.set_custom_field_value(label, value)` then `secrets_manager.save(secret)`
- **Read**: `secrets_manager.get_secrets(uids=[uid])`

## 🔒 Security Best Practices

### **Password Generation**:
- ✅ **Use sufficient length** (minimum 16 characters, prefer 20+)
- ✅ **Include mixed character types** (upper, lower, digits, symbols)
- ✅ **Use cryptographically secure generators** (like KSM's `generate_password()`)
- ❌ **Never log passwords** in production applications
- ❌ **Avoid predictable patterns** or dictionary words

### **Record Management**:
- ✅ **Validate folder permissions** before creating records
- ✅ **Use descriptive titles** and notes for audit trails
- ✅ **Add metadata fields** (environment, created by, purpose)
- ✅ **Test updates** on non-critical records first
- ❌ **Don't hardcode sensitive data** in your code

### **API Usage**:
- ✅ **Handle errors gracefully** with try-catch blocks
- ✅ **Verify operations** by reading back created/updated records
- ✅ **Use environment variables** for configuration
- ✅ **Implement retry logic** for network operations

## Record Field Examples

### **Login Record**:
```python
record = RecordCreate(record_type='login', title='Web Application')
record.fields = [
    RecordField(field_type='login', value=['admin@example.com']),
    RecordField(field_type='password', value=[generated_password]),
    RecordField(field_type='url', value=['https://app.example.com']),
    RecordField(field_type='text', label='Environment', value=['Production'])
]
```

### **Database Record**:
```python
record = RecordCreate(record_type='databaseCredentials', title='Production DB')
record.fields = [
    RecordField(field_type='login', value=['dbuser']),
    RecordField(field_type='password', value=[db_password]),
    RecordField(field_type='host', value=['db.example.com']),
    RecordField(field_type='text', label='Port', value=['5432']),
    RecordField(field_type='text', label='Database', value=['production'])
]
```

## Troubleshooting

**❌ "Folder not found" error**: Verify the folder UID exists and your app has edit permissions

**❌ "Invalid field type" error**: Check that field types are valid (see SDK documentation)

**❌ "Save failed" error**: Ensure the record was retrieved correctly before updating

## Next Steps

**💡 Real-world use case**: You now have programmatic secret creation and management for CI/CD automation.

**🔜 Coming up**: In Step 4, you'll learn file operations - uploading, downloading, and managing file attachments.

**📚 Learn More**: [Official KSM Python SDK Documentation](https://docs.keeper.io/en/keeperpam/secrets-manager/developer-sdk-library/python-sdk)
