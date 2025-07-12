# Step 1: Basic Connection & Configuration Options

**Learning Objective**: Set up secure Python SDK access to your Keeper vault using different configuration methods.

## What You'll Learn
The KSM Python SDK provides multiple ways to authenticate and connect:
- **File-based configuration**: Stores credentials locally (ideal for development)
- **In-memory configuration**: Uses Base64 config strings (ideal for production/containers)
- **Environment variables**: For CI/CD and automated deployments

This step demonstrates secure patterns for connecting to your Keeper vault programmatically.

## 1. Create Your Python Application File

```bash
touch main.py
```
`touch main.py`{{execute}}

**✅ Expected Output**: File created successfully.

## 2. Add Connection Code (File-based & In-Memory)

**⚠️ Important**: Before running, you'll need to replace the placeholder values with your actual Keeper credentials.

Copy and paste the following Python code into `main.py`:

```python
import os
from keeper_secrets_manager_core import SecretsManager
from keeper_secrets_manager_core.storage import FileKeyValueStorage, InMemoryKeyValueStorage

# --- Option 1: File-Based Configuration (using One-Time Token for first run) ---
# Replace with your actual One-Time Access Token for initial file setup
ONE_TIME_TOKEN = os.environ.get("KSM_TOKEN", "[YOUR_ONE_TIME_TOKEN_HERE]")
CONFIG_FILE_NAME = "ksm-config.json"

# --- Option 2: In-Memory Configuration (using Base64 encoded config string) ---
# Replace with your Base64 encoded KSM configuration string
# Obtain from Keeper Vault: Secrets Manager -> Applications -> (Your App) -> Devices -> Add Device -> Configuration File
KSM_CONFIG_BASE64 = os.environ.get("KSM_CONFIG", "[YOUR_KSM_CONFIG_BASE64_STRING_HERE]")

def list_secrets_info(secrets_manager_instance, config_type_name):
    """Display secrets information for demonstration purposes"""
    print(f"\n--- Attempting to retrieve secrets using {config_type_name} ---")
    try:
        all_secrets = secrets_manager_instance.get_secrets()
        print(f"✅ Success: Found {len(all_secrets)} secret(s) with {config_type_name}")
        
        # Display first few secrets as examples
        for i, secret in enumerate(all_secrets[:3], 1):
            print(f"\n  Secret {i}:")
            print(f"    Title: {secret.title}")
            print(f"    Type: {secret.type}")
            print(f"    UID: {secret.uid}")
            
            # Show field information using correct API
            try:
                fields_dict = secret.dict.get('fields', [])
                print(f"    Fields: {len(fields_dict)} field(s)")
                
                # Show field types
                if fields_dict:
                    field_types = [field.get('type', 'unknown') for field in fields_dict[:3]]
                    print(f"    Field types: {', '.join(field_types)}")
                    
                    # Show login field if available
                    login_value = secret.get_standard_field_value('login', single=True)
                    if login_value:
                        print(f"    Login: {login_value}")
                        
            except Exception as field_error:
                print(f"    Could not access field details: {field_error}")
                
        if len(all_secrets) > 3:
            print(f"\n    ... and {len(all_secrets) - 3} more secret(s)")
            
    except Exception as e:
        print(f"❌ Error with {config_type_name}: {e}")
        print(f"   Make sure you've replaced placeholder values with actual credentials.")

# --- Initialize and use File-Based Configuration ---
print("🚀 Demonstrating File-Based Configuration...")
if ONE_TIME_TOKEN and ONE_TIME_TOKEN != "[YOUR_ONE_TIME_TOKEN_HERE]":
    print(f"Initializing FileKeyValueStorage ('{CONFIG_FILE_NAME}') with One-Time Token.")
    print("📝 Note: First run uses token, subsequent runs use the generated config file.")
    
    try:
        file_storage = FileKeyValueStorage(CONFIG_FILE_NAME)
        secrets_manager_file = SecretsManager(token=ONE_TIME_TOKEN, config=file_storage)
        list_secrets_info(secrets_manager_file, "File-Based Config")
        
        print(f"\n📁 Config file '{CONFIG_FILE_NAME}' has been created for future use.")
        
    except Exception as e:
        print(f"❌ File-based configuration failed: {e}")
        
else:
    print("⏭️  Skipping File-Based Config: Replace '[YOUR_ONE_TIME_TOKEN_HERE]' with your actual token.")
    print(f"💡 Tip: If '{CONFIG_FILE_NAME}' already exists, you can use it without a token.")


# --- Initialize and use In-Memory Configuration ---
print("\n🚀 Demonstrating In-Memory Configuration...")
if KSM_CONFIG_BASE64 and KSM_CONFIG_BASE64 != "[YOUR_KSM_CONFIG_BASE64_STRING_HERE]":
    print("Initializing InMemoryKeyValueStorage with Base64 configuration string.")
    print("📝 Note: In-memory config is ideal for containers and serverless functions.")
    
    try:
        memory_storage = InMemoryKeyValueStorage(KSM_CONFIG_BASE64)
        secrets_manager_memory = SecretsManager(config=memory_storage)
        list_secrets_info(secrets_manager_memory, "In-Memory Config (Base64)")
        
        print("\n🔒 In-memory configuration doesn't create local files - perfect for production!")
        
    except Exception as e:
        print(f"❌ In-memory configuration failed: {e}")
        print("💡 Make sure your Base64 config string is valid and properly formatted.")
        
else:
    print("⏭️  Skipping In-Memory Config: Replace '[YOUR_KSM_CONFIG_BASE64_STRING_HERE]' with your config.")
    print("📋 Get Base64 config: Keeper Vault → Secrets Manager → Applications → Add Device → Configuration File")

## 3. Configure Your Credentials

**For File-Based Configuration (Option 1):**

**Where to get your One-Time Token:**
1. Log into Keeper Web Vault
2. Go to **Secrets Manager** → **Applications**
3. Select or create an Application
4. Go to **Devices** → **Add Device**
5. Choose **"One-Time Access Token"** method
6. Copy the token (format: `US:ABC123...`)

**For In-Memory Configuration (Option 2):**

**Where to get your Base64 Config:**
1. Log into Keeper Web Vault
2. Go to **Secrets Manager** → **Applications**
3. Select your Application
4. Go to **Devices** → **Add Device**
5. Choose **"Configuration File"** method
6. Copy the Base64 configuration string

**⚠️ Action Required**: Replace the placeholder values in `main.py` with your actual credentials before running.

## 4. Run the Application

```bash
python3 main.py
```
`python3 main.py`{{execute}}

**✅ Expected Output**: 
- Success messages showing retrieved secrets
- Secret details (title, type, UID, fields)
- Configuration method confirmation

## 🔍 What This Code Does

### **1. SDK Initialization**
- Imports core KSM components: `SecretsManager` and storage classes
- Sets up two different authentication approaches
- Handles both development and production scenarios

### **2. File-Based Configuration**
- **First run**: Uses One-Time Token to authenticate and create local config file
- **Subsequent runs**: Uses stored `ksm-config.json` file automatically
- **Best for**: Development environments, local applications
- **Security**: Encrypted credentials stored locally

### **3. In-Memory Configuration**
- Uses Base64-encoded configuration string directly
- **No local files** created or required
- **Best for**: Production, containers, serverless functions
- **Security**: No persistent storage of credentials

### **4. Secret Retrieval**
- Fetches all secrets shared with your application
- Displays secret metadata (title, type, UID)
- Shows field information using correct API methods
- Demonstrates proper error handling

## Configuration Storage Explained

### **FileKeyValueStorage**
- **Purpose**: Persistent local storage of encrypted credentials
- **File location**: `ksm-config.json` in current directory
- **Content**: Encrypted connection keys and metadata (no plaintext secrets)
- **Use case**: Development, long-running applications
- **Advantage**: No need to manage credentials after initial setup

### **InMemoryKeyValueStorage**
- **Purpose**: Temporary in-memory storage from Base64 string
- **Storage**: RAM only - no files created
- **Content**: Complete configuration including encrypted keys
- **Use case**: Production, containers, CI/CD, serverless
- **Advantage**: No persistent files, better for cloud deployments

### **Environment Variables**
Both methods support environment variables:
- `KSM_TOKEN`: One-Time Access Token
- `KSM_CONFIG`: Base64 configuration string
- `KSM_CONFIG_FILE`: Custom config file path

## Troubleshooting

**❌ "Could not deserialize key data" error**:
- Your Base64 config may be corrupted or expired
- Generate a new configuration from Keeper vault

**❌ "Token is invalid" error**:
- One-Time Token may have been used or expired
- Generate a new token from Keeper vault

**❌ "No secrets found" result**:
- Check that your application has been shared secrets in Keeper
- Verify the application has proper permissions

## Next Steps

**💡 Real-world use case**: You now have secure SDK authentication patterns for both development and production environments.

**🔜 Coming up**: In Step 2, you'll learn about client-side caching for performance and advanced secret retrieval techniques.

**📚 Learn More**: [Official KSM Python SDK Documentation](https://docs.keeper.io/en/keeperpam/secrets-manager/developer-sdk-library/python-sdk)
