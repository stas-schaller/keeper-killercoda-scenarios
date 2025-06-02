# Step 1: Basic Connection & Retrieval

## Understanding KSM SDK Authentication

The Keeper Secrets Manager Python SDK uses **One-Time Access Tokens** for secure authentication. These tokens are generated in your Keeper vault and provide access to specific secrets.

## Create Your First KSM Application

Let's create a simple Python application that connects to Keeper and retrieves secrets.

### 1. Create the Python File

```bash
touch main.py
```
`touch main.py`{{execute}}

### 2. Add the Connection Code

Copy and paste this code into `main.py`:

```python
from keeper_secrets_manager_core import SecretsManager
from keeper_secrets_manager_core.storage import FileKeyValueStorage

# Initialize the Secrets Manager
secrets_manager = SecretsManager(
    # Replace with your actual One-Time Access Token
    token='[ONE TIME ACCESS TOKEN]',
    config=FileKeyValueStorage('ksm-config1.json')
)

# Retrieve all secrets shared with this application
all_secrets = secrets_manager.get_secrets()

# Display the secrets
print(f"Found {len(all_secrets)} secret(s):")
for i, secret in enumerate(all_secrets, 1):
    print(f"\n--- Secret {i} ---")
    print(f"Title: {secret.title}")
    print(f"Type: {secret.type}")
    print(f"UID: {secret.uid}")
    # Print field information (without sensitive values)
    fields = secret.dict.get('fields', [])
    print(f"Fields: {len(fields)} field(s)")
    if fields:
        field_types = [field.get('type', 'unknown') for field in fields]
        print(f"Field types: {', '.join(field_types)}")
```{{copy}}

### 3. Configure Your Token

**⚠️ Important**: Replace `[ONE TIME ACCESS TOKEN]` with your actual token from Keeper.

To get your token:
1. Log into your Keeper Web Vault
2. Go to **Secrets Manager** → **Applications**
3. Create a new application or use an existing one
4. Generate a **One-Time Access Token**
5. Copy the token and replace the placeholder in the code

### 4. Run the Application

```bash
python3 main.py
```
`python3 main.py`{{execute}}

## What This Code Does

1. **Imports the SDK**: Loads the necessary KSM components
2. **Creates SecretsManager**: Initializes connection with your token
3. **Retrieves Secrets**: Gets all secrets shared with your application
4. **Displays Information**: Shows secret metadata (not the actual secret values)

## Storage Configuration

The `FileKeyValueStorage('ksm-config1.json')` creates a local configuration file that stores:
- Encrypted connection details
- Application keys
- Session information

This file is safe to store locally and contains no plaintext secrets.

## Next Steps

In the next step, we'll explore how to implement caching for better performance when working with multiple secrets.
