# Step 2: Caching & Advanced Secret Retrieval

**Learning Objective**: Learn performance optimization through caching and advanced secret retrieval techniques.

## Why Use Caching?

When your application frequently accesses secrets, caching can significantly improve performance by:
- **Reducing API calls** to Keeper servers (fewer network requests)
- **Faster secret retrieval** from local cache (milliseconds vs seconds)
- **Better user experience** with reduced latency
- **Lower bandwidth usage** for repeated requests
- **Offline resilience** when network is temporarily unavailable

## Understanding KSM Caching

The KSM SDK provides built-in caching functionality through the `KSMCache` module that:
- **Automatically encrypts** cached data for security
- **Handles cache expiration** and invalidation
- **Works with any storage type** (file-based or in-memory)
- **Provides fallback** to cached data if network fails

### 1. Create the Caching Example

```bash
touch step2-caching.py
```
`touch step2-caching.py`{{execute}}

**✅ Expected Output**: File created successfully.

### 2. Add the Caching Code

Copy and paste this code into `step2-caching.py`:

```python
import os
import time
from keeper_secrets_manager_core import SecretsManager
from keeper_secrets_manager_core.core import KSMCache
from keeper_secrets_manager_core.storage import FileKeyValueStorage, InMemoryKeyValueStorage

# Configuration - replace with your credentials
ONE_TIME_TOKEN = os.environ.get("KSM_TOKEN", "[YOUR_ONE_TIME_TOKEN_HERE]")
KSM_CONFIG_BASE64 = os.environ.get("KSM_CONFIG", "[YOUR_KSM_CONFIG_BASE64_STRING_HERE]")

def test_performance(secrets_manager, config_name):
    """Test and measure performance with and without caching"""
    print(f"\n🔄 Testing {config_name} - First retrieval (will cache results)...")
    start_time = time.time()
    all_secrets = secrets_manager.get_secrets()
    first_duration = time.time() - start_time
    
    print(f"✅ Retrieved {len(all_secrets)} secret(s) in {first_duration:.3f} seconds")
    
    print(f"\n🚀 Testing {config_name} - Second retrieval (from cache)...")
    start_time = time.time()
    all_secrets_cached = secrets_manager.get_secrets()
    second_duration = time.time() - start_time
    
    print(f"⚡ Retrieved {len(all_secrets_cached)} secret(s) in {second_duration:.3f} seconds")
    
    # Show performance improvement
    if first_duration > 0:
        improvement = ((first_duration - second_duration) / first_duration) * 100
        print(f"📊 Performance improvement: {improvement:.1f}% faster with cache!")
    
    return all_secrets

def demonstrate_specific_retrieval(secrets_manager, secrets):
    """Show advanced secret retrieval techniques"""
    print("\n🎯 Advanced Secret Retrieval Techniques:")
    
    if len(secrets) > 0:
        # Get specific secret by UID
        first_secret = secrets[0]
        print(f"\n1. Get specific secret by UID:")
        specific_secret = secrets_manager.get_secrets(uids=[first_secret.uid])[0]
        print(f"   Retrieved: {specific_secret.title}")
        
        # Get multiple specific secrets
        if len(secrets) > 1:
            print(f"\n2. Get multiple specific secrets:")
            uids = [secret.uid for secret in secrets[:3]]
            multiple_secrets = secrets_manager.get_secrets(uids=uids)
            print(f"   Retrieved {len(multiple_secrets)} specific secrets:")
            for secret in multiple_secrets:
                print(f"   - {secret.title}")
        
        # Demonstrate field access
        print(f"\n3. Field access examples:")
        secret = specific_secret
        print(f"   Secret: {secret.title}")
        
        # Standard fields
        login = secret.get_standard_field_value('login', single=True)
        if login:
            print(f"   Login: {login}")
            
        # Show all fields in the secret
        try:
            fields_dict = secret.dict.get('fields', [])
            print(f"   Available fields: {len(fields_dict)} field(s)")
            for field in fields_dict[:3]:  # Show first 3 fields
                field_type = field.get('type', 'unknown')
                field_value = field.get('value', [])
                if field_type != 'password':  # Don't show passwords in demo
                    print(f"   - {field_type}: {field_value[0] if field_value else 'empty'}")
                else:
                    print(f"   - {field_type}: [hidden]")
        except Exception as e:
            print(f"   Could not access field details: {e}")

print("🚀 KSM Python SDK - Caching & Advanced Retrieval Demo")
print("" + "="*60)

# Method 1: File-based configuration with caching
if ONE_TIME_TOKEN and ONE_TIME_TOKEN != "[YOUR_ONE_TIME_TOKEN_HERE]":
    try:
        print("\n📁 Testing File-Based Configuration with Caching")
        file_storage = FileKeyValueStorage('ksm-cache-config.json')
        secrets_manager_file = SecretsManager(
            token=ONE_TIME_TOKEN,
            config=file_storage,
            custom_post_function=KSMCache.caching_post_function  # Enable caching
        )
        
        secrets = test_performance(secrets_manager_file, "File-Based Config")
        demonstrate_specific_retrieval(secrets_manager_file, secrets)
        
    except Exception as e:
        print(f"❌ File-based caching failed: {e}")
else:
    print("⏭️  Skipping File-Based test: Replace token placeholder")

# Method 2: In-memory configuration with caching
if KSM_CONFIG_BASE64 and KSM_CONFIG_BASE64 != "[YOUR_KSM_CONFIG_BASE64_STRING_HERE]":
    try:
        print("\n💾 Testing In-Memory Configuration with Caching")
        memory_storage = InMemoryKeyValueStorage(KSM_CONFIG_BASE64)
        secrets_manager_memory = SecretsManager(
            config=memory_storage,
            custom_post_function=KSMCache.caching_post_function  # Enable caching
        )
        
        secrets = test_performance(secrets_manager_memory, "In-Memory Config")
        demonstrate_specific_retrieval(secrets_manager_memory, secrets)
        
    except Exception as e:
        print(f"❌ In-memory caching failed: {e}")
else:
    print("⏭️  Skipping In-Memory test: Replace config placeholder")

print("\n🔒 Security Note: Cached data is encrypted using your application keys")
print("📁 Cache files are stored securely and cleaned automatically when expired")
print("\n✅ Caching demonstration completed!")
```{{copy}}

### 3. Configure Your Credentials

**⚠️ Action Required**: Replace the placeholder values with your actual credentials:
- `[YOUR_ONE_TIME_TOKEN_HERE]` → Your One-Time Access Token
- `[YOUR_KSM_CONFIG_BASE64_STRING_HERE]` → Your Base64 configuration

**💡 Tip**: Use the same credentials from Step 1.

### 4. Run the Caching Example

```bash
python3 step2-caching.py
```
`python3 step2-caching.py`{{execute}}

**✅ Expected Output**:
- Performance metrics showing speed improvements
- Secret retrieval demonstrations
- Field access examples
- Cache efficiency measurements

## 🔍 Understanding the Output

You should see:
1. **First retrieval**: Takes longer as it fetches from Keeper servers and caches the response
2. **Second retrieval**: Much faster (often 10-100x) as it uses cached data
3. **Performance metrics**: Shows percentage speed improvement with caching
4. **Advanced retrieval**: Demonstrates getting specific secrets by UID
5. **Field access**: Shows how to access different types of secret fields

## 🔧 How Caching Works

### **The `KSMCache.caching_post_function`**:
- **Intercepts API responses** and stores them in encrypted local cache
- **Checks cache first** before making network requests
- **Automatic fallback** to cache if network fails
- **Maintains security** by encrypting all cached data
- **Smart invalidation** updates cache when secrets change

### **Cache Flow**:
1. **First request**: SDK → Keeper servers → Cache + Return data
2. **Subsequent requests**: SDK → Cache → Return data (no network)
3. **Cache miss**: SDK → Keeper servers → Update cache → Return data
4. **Network failure**: SDK → Cache → Return cached data

## 📁 Cache Storage

### **Security Features**:
- **Encrypted storage** using your application's encryption keys
- **No plaintext secrets** ever stored in cache files
- **Automatic cleanup** of expired or invalid cache entries

### **Storage Locations**:
- **Default location**: `ksm_cache.bin` in current directory
- **Custom location**: Set `KSM_CACHE_DIR` environment variable
- **In-memory caching**: Works with both file and memory storage

### **Cache Files**:
```bash
# Default cache file
ls -la ksm_cache.bin

# Custom cache directory
export KSM_CACHE_DIR="/tmp/ksm_cache"
```

## 🎯 Best Practices

### **When to Use Caching**:
- ✅ Applications that frequently access the same secrets
- ✅ Production environments with performance requirements
- ✅ Applications that need offline resilience
- ✅ High-frequency secret access patterns

### **When to Avoid Caching**:
- ❌ One-time secret access applications
- ❌ Secrets that change very frequently
- ❌ Security-critical applications requiring real-time data

### **Performance Considerations**:
- **Monitor cache hit rates** to ensure caching provides benefits
- **Test cache behavior** during network outages
- **Consider cache invalidation** for secrets that change frequently
- **Balance security vs performance** based on your requirements

## Advanced Secret Retrieval Patterns

### **Get Secrets by Title** (if available):
```python
# Get secret by exact title match
secret = secrets_manager.get_secret_by_title("My Database Login")

# Get all secrets with title containing text
secrets = secrets_manager.get_secrets_by_title("Database")
```

### **Batch Operations**:
```python
# Get multiple specific secrets efficiently
uids = ["uid1", "uid2", "uid3"]
secrets = secrets_manager.get_secrets(uids=uids)

# Process secrets in batches
for secret in secrets:
    login = secret.get_standard_field_value('login', single=True)
    password = secret.get_standard_field_value('password', single=True)
    # Use credentials...
```

## Troubleshooting

**❌ "Cache file not found" warning**: Normal on first run - cache will be created

**❌ Slow performance with caching**: Check that `custom_post_function=KSMCache.caching_post_function` is set

**❌ "Permission denied" on cache file**: Check write permissions in current directory or set `KSM_CACHE_DIR`

## Next Steps

**💡 Real-world use case**: You now have high-performance secret access patterns for production applications.

**🔜 Coming up**: In Step 3, you'll learn how to create and update records programmatically.

**📚 Learn More**: [Official KSM Python SDK Documentation](https://docs.keeper.io/en/keeperpam/secrets-manager/developer-sdk-library/python-sdk)
