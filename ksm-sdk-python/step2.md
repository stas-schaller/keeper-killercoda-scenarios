# Step 2: Caching for Performance

## Why Use Caching?

When your application frequently accesses secrets, caching can significantly improve performance by:
- **Reducing API calls** to Keeper servers
- **Faster secret retrieval** from local cache
- **Better user experience** with reduced latency
- **Lower bandwidth usage** for repeated requests

## Implementing KSM Caching

The KSM SDK provides built-in caching functionality through the `KSMCache` module.

### 1. Create the Caching Example

```bash
touch main-cache.py
```
`touch main-cache.py`{{execute}}

### 2. Add the Caching Code

Copy and paste this code into `main-cache.py`:

```python
from keeper_secrets_manager_core import SecretsManager
from keeper_secrets_manager_core.core import KSMCache
from keeper_secrets_manager_core.storage import FileKeyValueStorage
import time

# Initialize Secrets Manager with caching enabled
secrets_manager = SecretsManager(
    token='[ONE TIME TOKEN]',
    config=FileKeyValueStorage('ksm-config2.json'),
    custom_post_function=KSMCache.caching_post_function
)

print("🔄 First retrieval (will cache the results)...")
start_time = time.time()
all_secrets = secrets_manager.get_secrets()
first_duration = time.time() - start_time

print(f"✅ Retrieved {len(all_secrets)} secret(s) in {first_duration:.3f} seconds")

print("\n🚀 Second retrieval (from cache)...")
start_time = time.time()
all_secrets_cached = secrets_manager.get_secrets()
second_duration = time.time() - start_time

print(f"⚡ Retrieved {len(all_secrets_cached)} secret(s) in {second_duration:.3f} seconds")

# Show performance improvement
if first_duration > 0:
    improvement = ((first_duration - second_duration) / first_duration) * 100
    print(f"\n📊 Performance improvement: {improvement:.1f}% faster with cache!")

# Display secret information
print(f"\n--- Secret Details ---")
for i, secret in enumerate(all_secrets, 1):
    print(f"Secret {i}: {secret.title} ({secret.type})")
```{{copy}}

### 3. Configure Your Token

Replace `[ONE TIME TOKEN]` with your actual token from Keeper (same as Step 1).

### 4. Run the Caching Example

```bash
python3 main-cache.py
```
`python3 main-cache.py`{{execute}}

## Understanding the Output

You should see:
1. **First retrieval**: Takes longer as it fetches from Keeper servers
2. **Second retrieval**: Much faster as it uses cached data
3. **Performance metrics**: Shows the speed improvement

## How Caching Works

The `KSMCache.caching_post_function` parameter:
- **Intercepts API responses** and stores them locally
- **Checks cache first** before making network requests
- **Automatically manages** cache expiration and updates
- **Maintains security** by encrypting cached data

## Cache Storage

Cached data is stored:
- **Securely encrypted** using your application keys
- **Locally on disk** in the same directory as your config
- **Automatically cleaned** when expired or invalid

## Best Practices

- **Use caching** for applications that frequently access the same secrets
- **Consider cache TTL** for secrets that change frequently
- **Monitor performance** to ensure caching provides benefits
- **Test thoroughly** to ensure cached data remains accurate

## Next Steps

In the next step, we'll learn how to create new records programmatically using the KSM SDK.
