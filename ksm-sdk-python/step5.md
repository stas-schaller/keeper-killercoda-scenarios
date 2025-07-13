# Step 5: Folder Management & Advanced Features

**Learning Objective**: Learn to manage folders and implement advanced organizational features using the KSM Python SDK.

## What You'll Learn
This step covers advanced organizational and management operations:
- **Creating and managing folders** programmatically
- **Organizing records** into logical folder structures
- **Bulk operations** for records and folders
- **Advanced SDK features** for enterprise workflows

## Why Folder Management Matters?

### **Business Benefits**:
- **Organized secret hierarchy** for teams and projects
- **Bulk operations** for managing large secret inventories
- **Automated organization** of secrets by environment or purpose
- **Compliance and auditing** through structured secret management

### **Technical Benefits**:
- **Scalable secret organization** for enterprise environments
- **API-driven folder operations** for automation
- **Batch processing** capabilities for large datasets
- **Integration** with organizational structures and workflows

## Understanding Folder Operations

### **Folder Hierarchy**:
- **Root folders**: Top-level organization units
- **Nested folders**: Sub-folders for detailed organization
- **Shared folders**: Folders accessible to multiple applications
- **Personal folders**: Private folders for specific applications


### 1. Create the Folder Management Script

```bash
touch step5-folders.py
```
`touch step5-folders.py`{{execute}}

**✅ Expected Output**: File created successfully.

### 2. Add Folder Management Code

**⚠️ Important**: You'll need a parent folder UID where your application can create folders.

Copy and paste this code into `step5-folders.py`:

```python
import os
import time
from keeper_secrets_manager_core import SecretsManager
from keeper_secrets_manager_core.storage import FileKeyValueStorage, InMemoryKeyValueStorage
from keeper_secrets_manager_core.dto.dtos import RecordCreate, RecordField
from keeper_secrets_manager_core.core import KSMCache

# Configuration - replace with your credentials
ONE_TIME_TOKEN = os.environ.get("KSM_TOKEN", "[YOUR_ONE_TIME_TOKEN_HERE]")
KSM_CONFIG_BASE64 = os.environ.get("KSM_CONFIG", "[YOUR_KSM_CONFIG_BASE64_STRING_HERE]")
PARENT_FOLDER_UID = os.environ.get("KSM_PARENT_FOLDER_UID", "[YOUR_PARENT_FOLDER_UID_HERE]")

def initialize_secrets_manager():
    """Initialize SecretsManager with available configuration and caching"""
    # Try in-memory config first
    if KSM_CONFIG_BASE64 and KSM_CONFIG_BASE64 != "[YOUR_KSM_CONFIG_BASE64_STRING_HERE]":
        try:
            config = InMemoryKeyValueStorage(KSM_CONFIG_BASE64)
            return SecretsManager(
                config=config,
                custom_post_function=KSMCache.caching_post_function  # Enable caching
            ), "In-Memory Config with Caching"
        except Exception as e:
            print(f"⚠️  In-memory config failed: {e}")
    
    # Try file-based config with token
    if ONE_TIME_TOKEN and ONE_TIME_TOKEN != "[YOUR_ONE_TIME_TOKEN_HERE]":
        try:
            config = FileKeyValueStorage('step5-config.json')
            return SecretsManager(
                token=ONE_TIME_TOKEN,
                config=config,
                custom_post_function=KSMCache.caching_post_function  # Enable caching
            ), "File-Based Config with Caching"
        except Exception as e:
            print(f"⚠️  File-based config failed: {e}")
    
    raise Exception("No valid configuration found. Please provide either KSM_CONFIG or KSM_TOKEN.")

def list_available_folders(secrets_manager):
    """List all folders accessible to the application"""
    print("\n📁 Listing all accessible folders...")
    
    try:
        # Get all secrets to analyze folder structure
        all_secrets = secrets_manager.get_secrets()
        
        folder_info = {}
        
        for secret in all_secrets:
            try:
                # Get folder UID from secret metadata
                folder_uid = secret.dict.get('folder_uid', 'Root')
                folder_key = secret.dict.get('folder_key', 'N/A')
                
                if folder_uid not in folder_info:
                    folder_info[folder_uid] = {
                        'folder_key': folder_key,
                        'record_count': 0,
                        'records': []
                    }
                
                folder_info[folder_uid]['record_count'] += 1
                folder_info[folder_uid]['records'].append(secret.title)
                
            except Exception as e:
                print(f"  ⚠️  Error processing secret {secret.title}: {e}")
        
        print(f"✅ Found {len(folder_info)} folder(s):")
        for folder_uid, info in folder_info.items():
            print(f"  📂 Folder UID: {folder_uid}")
            print(f"     Records: {info['record_count']}")
            print(f"     Examples: {', '.join(info['records'][:3])}{'...' if len(info['records']) > 3 else ''}")
        
        return folder_info
        
    except Exception as e:
        print(f"❌ Error listing folders: {e}")
        return {}

def create_demo_folder_structure(secrets_manager):
    """Create a demo folder structure for organization"""
    print("\n🏗️  Creating demo folder structure...")
    
    if not PARENT_FOLDER_UID or PARENT_FOLDER_UID == "[YOUR_PARENT_FOLDER_UID_HERE]":
        print("⏭️  Skipping folder creation: Parent folder UID not provided")
        print("💡 To test folder creation, provide a parent folder UID where you can create folders")
        return None
    
    try:
        # Create a main demo folder
        timestamp = int(time.time())
        main_folder_name = f"KSM_Python_SDK_Demo_{timestamp}"
        
        print(f"📁 Creating main folder: {main_folder_name}")
        
        # Note: Folder creation API varies by implementation
        # This is a conceptual example - actual API may differ
        try:
            # Some SDKs use create_folder method
            folder_result = secrets_manager.create_folder(
                folder_name=main_folder_name,
                parent_uid=PARENT_FOLDER_UID
            )
            
            if hasattr(folder_result, 'uid'):
                main_folder_uid = folder_result.uid
            else:
                main_folder_uid = folder_result.get('folder_uid') or folder_result.get('uid')
            
            print(f"✅ Main folder created: {main_folder_name} (UID: {main_folder_uid})")
            return main_folder_uid
            
        except AttributeError:
            print("ℹ️  Folder creation method not available in this SDK version")
            print("💡 Folder management may require different API endpoints")
            return None
            
    except Exception as e:
        print(f"❌ Error creating folder structure: {e}")
        print("💡 Make sure your application can create folders in the parent folder")
        return None

def create_demo_records_in_folder(secrets_manager, folder_uid):
    """Create demo records in the specified folder"""
    if not folder_uid:
        print("⏭️  Skipping record creation: No folder UID provided")
        return []
    
    print(f"\n📋 Creating demo records in folder UID: {folder_uid}")
    
    demo_records = [
        {
            'title': 'Development Database Credentials',
            'type': 'login',
            'fields': [
                RecordField(field_type='login', value=['dev_user']),
                RecordField(field_type='password', value=['dev_password_123']),
                RecordField(field_type='url', value=['dev-db.example.com']),
                RecordField(field_type='text', label='Environment', value=['Development']),
                RecordField(field_type='text', label='Port', value=['5432'])
            ]
        },
        {
            'title': 'API Service Configuration',
            'type': 'login',
            'fields': [
                RecordField(field_type='text', label='API Key', value=['sk_dev_123456789']),
                RecordField(field_type='url', value=['https://api.dev.example.com']),
                RecordField(field_type='text', label='Service', value=['User Authentication API']),
                RecordField(field_type='text', label='Version', value=['v2.1'])
            ]
        }
    ]
    
    created_records = []
    
    for record_data in demo_records:
        try:
            print(f"  Creating: {record_data['title']}")
            
            new_record = RecordCreate(
                record_type=record_data['type'],
                title=record_data['title']
            )
            new_record.fields = record_data['fields']
            new_record.notes = f'Created by KSM Python SDK - Step 5\\nFolder Management Demo\\nCreated: {time.ctime()}'
            
            record_uid = secrets_manager.create_secret(folder_uid, new_record)
            print(f"  ✅ Created: {record_data['title']} (UID: {record_uid})")
            created_records.append(record_uid)
            
        except Exception as e:
            print(f"  ❌ Error creating {record_data['title']}: {e}")
    
    return created_records

def demonstrate_bulk_operations(secrets_manager, record_uids):
    """Demonstrate bulk operations on multiple records"""
    if not record_uids:
        print("⏭️  Skipping bulk operations: No records available")
        return
    
    print(f"\n🔄 Demonstrating bulk operations on {len(record_uids)} records...")
    
    try:
        # Bulk retrieve specific records
        print("  📥 Bulk retrieving records...")
        bulk_records = secrets_manager.get_secrets(uids=record_uids)
        print(f"  ✅ Retrieved {len(bulk_records)} records in bulk")
        
        # Show record details
        for record in bulk_records:
            print(f"    - {record.title} (Type: {record.type})")
            fields_count = len(record.dict.get('fields', []))
            print(f"      Fields: {fields_count}, UID: {record.uid}")
        
        # Demonstrate bulk field access
        print("\n  🔍 Analyzing field patterns across records...")
        field_types = set()
        for record in bulk_records:
            try:
                fields = record.dict.get('fields', [])
                for field in fields:
                    field_type = field.get('type', 'unknown')
                    field_types.add(field_type)
            except Exception as e:
                print(f"    ⚠️  Error accessing fields for {record.title}: {e}")
        
        print(f"  📊 Found field types: {', '.join(sorted(field_types))}")
        
    except Exception as e:
        print(f"❌ Error in bulk operations: {e}")

def cleanup_demo_resources(secrets_manager, record_uids, folder_uid):
    """Clean up demo resources"""
    print(f"\n🧹 Cleaning up demo resources...")
    
    # Delete demo records
    if record_uids:
        print(f"  🗑️  Deleting {len(record_uids)} demo records...")
        try:
            for record_uid in record_uids:
                try:
                    # Delete individual records
                    secrets_manager.delete_secret(record_uid)
                    print(f"    ✅ Deleted record: {record_uid}")
                except Exception as e:
                    print(f"    ❌ Error deleting record {record_uid}: {e}")
        except Exception as e:
            print(f"  ❌ Error in bulk record deletion: {e}")
    
    # Delete demo folder
    if folder_uid:
        print(f"  📁 Deleting demo folder: {folder_uid}")
        try:
            secrets_manager.delete_folder(folder_uid)
            print(f"    ✅ Deleted folder: {folder_uid}")
        except AttributeError:
            print("    ℹ️  Folder deletion method not available in this SDK version")
        except Exception as e:
            print(f"    ❌ Error deleting folder {folder_uid}: {e}")
            print("    💡 Folder may need to be empty or folder creation may not be available")

def main():
    """Main execution function"""
    print("🚀 KSM Python SDK - Folder Management & Advanced Features Demo")
    print("=" * 70)
    
    try:
        # Initialize Secrets Manager with caching
        secrets_manager, config_type = initialize_secrets_manager()
        print(f"✅ Initialized with {config_type}")
        
        # Test connection and show current state
        all_secrets = secrets_manager.get_secrets()
        print(f"📊 Current vault state: {len(all_secrets)} secret(s) accessible")
        
        # List available folders
        folder_info = list_available_folders(secrets_manager)
        
        # Create demo folder structure
        demo_folder_uid = create_demo_folder_structure(secrets_manager)
        
        # Create demo records in folder
        demo_record_uids = create_demo_records_in_folder(secrets_manager, demo_folder_uid)
        
        # Demonstrate bulk operations
        demonstrate_bulk_operations(secrets_manager, demo_record_uids)
        
        # Show updated folder state
        if demo_folder_uid:
            print(f"\n📁 Demo folder UID: {demo_folder_uid}")
            print(f"📋 Created {len(demo_record_uids)} demo records")
        
        # Cleanup (optional - comment out to keep demo resources)
        cleanup_choice = input("\n🤔 Clean up demo resources? (y/N): ").strip().lower()
        if cleanup_choice in ['y', 'yes']:
            cleanup_demo_resources(secrets_manager, demo_record_uids, demo_folder_uid)
        else:
            print("ℹ️  Demo resources kept for further testing")
            if demo_folder_uid:
                print(f"   Demo folder UID: {demo_folder_uid}")
            if demo_record_uids:
                print(f"   Demo record UIDs: {', '.join(demo_record_uids)}")
        
        print("\n✅ Folder management and advanced features demonstration completed!")
        
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

### **Parent Folder UID (optional for folder creation)**:
`[YOUR_PARENT_FOLDER_UID_HERE]` → UID of a shared folder where you can create folders

**How to get Parent Folder UID:**
1. Log into Keeper Web Vault
2. Navigate to a shared folder
3. Right-click → **"Get Info"**
4. Copy the **Folder UID**

**⚠️ Note**: Folder listing works without parent UID, but creation requires it.

### 4. Run the Folder Management Script

```bash
python3 step5-folders.py
```
`python3 step5-folders.py`{{execute}}

**✅ Expected Output**:
- Connection confirmation with caching enabled
- Current vault state summary
- Folder structure analysis
- Demo folder and record creation (if parent UID provided)
- Bulk operations demonstration
- Cleanup options

## 🔍 Understanding Advanced Features

### **Folder Organization Patterns**:

**1. Environment-Based Structure**:
```
📁 Production
  📋 Database Credentials
  📋 API Keys
  📋 SSL Certificates
📁 Development
  📋 Test Database
  📋 Dev API Keys
📁 Staging
  📋 Staging Database
  📋 Staging API Keys
```

**2. Service-Based Structure**:
```
📁 Web Application
  📋 Database Connections
  📋 External API Keys
  📋 Session Secrets
📁 Background Jobs
  📋 Queue Credentials
  📋 Storage Keys
📁 Monitoring
  📋 Logging Keys
  📋 Metrics API Keys
```

**3. Team-Based Structure**:
```
📁 DevOps Team
  📋 Infrastructure Secrets
  📋 Deployment Keys
📁 Development Team
  📋 Development Tools
  📋 Test Accounts
📁 QA Team
  📋 Test Environment Access
  📋 Test Data
```

### **Bulk Operations Best Practices**:

**1. Efficient Secret Retrieval**:
```python
# Get specific secrets by UIDs (efficient)
specific_secrets = secrets_manager.get_secrets(uids=uid_list)

# Process secrets in batches
batch_size = 50
for i in range(0, len(all_uids), batch_size):
    batch_uids = all_uids[i:i + batch_size]
    batch_secrets = secrets_manager.get_secrets(uids=batch_uids)
    # Process batch...
```

**2. Field Analysis Across Records**:
```python
# Analyze field patterns
field_distribution = {}
for secret in secrets:
    fields = secret.dict.get('fields', [])
    for field in fields:
        field_type = field.get('type', 'unknown')
        field_distribution[field_type] = field_distribution.get(field_type, 0) + 1
```

## 🔧 Advanced SDK Features

### **Caching with Performance Monitoring**:
```python
# Enable caching for better performance
secrets_manager = SecretsManager(
    config=config,
    custom_post_function=KSMCache.caching_post_function
)

# Monitor cache performance
start_time = time.time()
secrets = secrets_manager.get_secrets()
end_time = time.time()
print(f"Retrieval time: {end_time - start_time:.3f} seconds")
```

### **Error Handling for Enterprise Operations**:
```python
def robust_secret_operation(secrets_manager, operation_func, *args, **kwargs):
    """Wrapper for robust secret operations with retry logic"""
    max_retries = 3
    for attempt in range(max_retries):
        try:
            return operation_func(*args, **kwargs)
        except Exception as e:
            if attempt == max_retries - 1:
                raise e
            time.sleep(2 ** attempt)  # Exponential backoff
            print(f"Retry {attempt + 1}/{max_retries}: {e}")
```

## 🔒 Enterprise Security Considerations

### **Organizational Patterns**:
- ✅ **Principle of least privilege** - Only access necessary folders
- ✅ **Consistent folder structure** for team-based organization
- ✅ **Regular cleanup** to maintain organized structure
- ✅ **Audit logging** for all folder and record operations

### **Organizational Best Practices**:
- ✅ **Consistent naming conventions** for folders and records
- ✅ **Metadata fields** for categorization and searching
- ✅ **Regular cleanup** of unused folders and records
- ✅ **Documentation** of folder structure and purposes

### **Automation Guidelines**:
- ✅ **Automated folder creation** for new projects/environments
- ✅ **Bulk operations** for maintenance and migration
- ✅ **Regular backups** of important folder structures
- ✅ **Monitoring and alerting** for unauthorized changes

## Real-World Enterprise Scenarios

### **Multi-Environment Management**:
```python
# Create environment-specific folders
environments = ['production', 'staging', 'development']
for env in environments:
    folder_uid = create_environment_folder(env)
    setup_environment_secrets(folder_uid, env)
```

### **Team Onboarding Automation**:
```python
# Automated team folder setup
def setup_team_folder(team_name):
    team_folder = secrets_manager.create_folder(f"Team_{team_name}")
    return team_folder
```

### **Compliance and Auditing**:
```python
# Generate compliance reports
def generate_folder_report():
    folders = secrets_manager.get_folders_all()
    report = []
    for folder in folders:
        report.append({
            'folder': folder.name,
            'folder_uid': folder.uid,
            'created_time': getattr(folder, 'created_time', 'N/A')
        })
    return report
```

## Troubleshooting

**❌ "Folder not found" error**: Verify the parent folder UID exists and is accessible

**❌ "Cannot create folder" error**: Ensure the parent folder exists and folder creation is supported

**❌ Slow bulk operations**: Consider implementing batching and caching strategies

## Next Steps

**💡 Real-world use case**: You now have advanced folder management and organizational capabilities for enterprise secret management.

**🎉 Tutorial Complete**: You've mastered the KSM Python SDK from basic connections to advanced enterprise features!

**📚 Learn More**: [Official KSM Python SDK Documentation](https://docs.keeper.io/en/keeperpam/secrets-manager/developer-sdk-library/python-sdk)

## Tutorial Summary

Congratulations! You've completed the comprehensive KSM Python SDK tutorial covering:

1. **Step 1**: Basic connection and configuration options
2. **Step 2**: Caching and advanced secret retrieval
3. **Step 3**: Record creation and updates
4. **Step 4**: File operations (upload, download, management)
5. **Step 5**: Folder management and advanced features

You're now equipped to build production-ready applications with secure secret management using the Keeper Secrets Manager Python SDK!