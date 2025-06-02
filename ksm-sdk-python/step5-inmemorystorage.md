# Step 5: In-Memory Configuration

## Why Use In-Memory Storage?

In-memory configuration storage is essential for modern deployment scenarios:

- **Containerized applications** - No persistent file system
- **Serverless functions** - Stateless execution environments  
- **CI/CD pipelines** - Temporary execution contexts
- **Security compliance** - Avoid storing config files on disk
- **Kubernetes deployments** - Configuration via secrets/configmaps

## Configuration File vs In-Memory Storage

| Aspect | File Storage | In-Memory Storage |
|--------|--------------|-------------------|
| **Persistence** | Survives restarts | Loaded each time |
| **Security** | File system dependent | Memory only |
| **Deployment** | Requires file management | Environment variables |
| **Containers** | Needs volume mounts | Native support |

## Setting Up In-Memory Configuration

### 1. Generate Base64 Configuration

First, you need to create a KSM Application with **Configuration File** authentication:

1. Log into Keeper Web Vault
2. Go to **Secrets Manager** → **Applications**
3. Create new application or edit existing
4. Set **Authentication Method** to **"Configuration File"**
5. **Copy the base64 encoded configuration string**

### 2. Create the In-Memory Storage Script

```bash
touch main-inmemorystorage.py
```
`touch main-inmemorystorage.py`{{execute}}

### 3. Add the In-Memory Configuration Code

Copy and paste this code into `main-inmemorystorage.py`:

```python
import os
from keeper_secrets_manager_core import SecretsManager
from keeper_secrets_manager_core.storage import InMemoryKeyValueStorage

print("🧠 Using In-Memory Configuration Storage")

# Get configuration from environment variable
ksm_config_b64 = os.getenv('KSM_CONFIGB64')

if not ksm_config_b64:
    print("❌ Environment variable KSM_CONFIGB64 not found!")
    print("💡 Set it using:")
    print("   export KSM_CONFIGB64='your_base64_config_here'")
    print("\n📋 To get your config:")
    print("   1. Go to Keeper Web Vault")
    print("   2. Secrets Manager → Applications")
    print("   3. Create/Edit application")
    print("   4. Set Authentication to 'Configuration File'")
    print("   5. Copy the base64 configuration")
    exit(1)

try:
    # Initialize Secrets Manager with in-memory storage
    secrets_manager = SecretsManager(
        config=InMemoryKeyValueStorage(ksm_config_b64)
    )
    
    print("✅ Successfully initialized with in-memory config!")
    
    # Retrieve all secrets
    print("\n🔍 Retrieving secrets...")
    all_secrets = secrets_manager.get_secrets()
    
    print(f"📊 Found {len(all_secrets)} secret(s):")
    
    # Display secret information
    for i, secret in enumerate(all_secrets, 1):
        print(f"\n--- Secret {i} ---")
        print(f"📝 Title: {secret.title}")
        print(f"🔑 Type: {secret.type}")
        print(f"🆔 UID: {secret.uid}")
        
        # Get fields from the record dictionary
        fields = secret.dict.get('fields', [])
        print(f"📋 Fields: {len(fields)} field(s)")
        
        # Show field types (without values for security)
        if fields:
            field_types = [field.get('type', 'unknown') for field in fields]
            print(f"🏷️  Field types: {', '.join(field_types)}")
    
    print(f"\n🎉 In-memory configuration working perfectly!")
    
except Exception as e:
    print(f"❌ Error: {str(e)}")
    print("💡 Common issues:")
    print("   - Invalid base64 configuration")
    print("   - Expired or revoked application")
    print("   - Network connectivity problems")
    print("   - Incorrect environment variable format")
```{{copy}}

### 4. Set Environment Variable (Demo)

For demonstration purposes, let's set a placeholder environment variable:

```bash
export KSM_CONFIGB64="REPLACE_WITH_YOUR_ACTUAL_BASE64_CONFIG"
```
`export KSM_CONFIGB64="REPLACE_WITH_YOUR_ACTUAL_BASE64_CONFIG"`{{execute}}

**⚠️ Important**: Replace the placeholder with your actual base64 configuration from Keeper.

### 5. Run the In-Memory Storage Script

```bash
python3 main-inmemorystorage.py
```
`python3 main-inmemorystorage.py`{{execute}}

## Production Deployment Examples

### Docker Container
```dockerfile
FROM python:3.12-slim
RUN pip install keeper-secrets-manager-core
COPY app.py /app/
ENV KSM_CONFIGB64=""
CMD ["python", "/app/app.py"]
```{{copy}}

### Kubernetes Deployment
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ksm-app
spec:
  template:
    spec:
      containers:
      - name: app
        image: my-ksm-app:latest
        env:
        - name: KSM_CONFIGB64
          valueFrom:
            secretKeyRef:
              name: ksm-config
              key: config-b64
```{{copy}}

### AWS Lambda
```python
import os
from keeper_secrets_manager_core import SecretsManager
from keeper_secrets_manager_core.storage import InMemoryKeyValueStorage

def lambda_handler(event, context):
    config_b64 = os.environ['KSM_CONFIGB64']
    sm = SecretsManager(config=InMemoryKeyValueStorage(config_b64))
    secrets = sm.get_secrets()
    return {'statusCode': 200, 'body': f'Found {len(secrets)} secrets'}
```{{copy}}

## Security Best Practices

- **Environment Variables**: Store config in secure environment variables
- **Secret Management**: Use platform-native secret stores (AWS Secrets Manager, Azure Key Vault, etc.)
- **Access Control**: Limit who can access the base64 configuration
- **Rotation**: Regularly rotate application configurations
- **Monitoring**: Log access attempts and failures

## Advantages of In-Memory Storage

✅ **No file system dependencies**  
✅ **Container-friendly**  
✅ **Serverless compatible**  
✅ **Reduced attack surface**  
✅ **Environment-based configuration**  
✅ **Easy CI/CD integration**  

## When to Use Each Storage Type

| Use Case | Recommended Storage |
|----------|-------------------|
| **Local development** | FileKeyValueStorage |
| **Traditional servers** | FileKeyValueStorage |
| **Docker containers** | InMemoryKeyValueStorage |
| **Kubernetes pods** | InMemoryKeyValueStorage |
| **AWS Lambda** | InMemoryKeyValueStorage |
| **CI/CD pipelines** | InMemoryKeyValueStorage |

## Congratulations! 🎉

You've completed the KSM Python SDK tutorial! You now know how to:

- ✅ Connect to Keeper and retrieve secrets
- ✅ Implement caching for better performance  
- ✅ Create records programmatically
- ✅ Upload files and attachments
- ✅ Use in-memory configuration for modern deployments

### Next Steps

- **Integrate KSM** into your applications
- **Explore advanced features** like custom field types
- **Implement error handling** and retry logic
- **Set up monitoring** and logging
- **Review security best practices** for production use