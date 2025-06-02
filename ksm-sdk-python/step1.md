# Step 1: Basic Connection & Configuration Options

This step guides you through setting up a basic Python application to connect to Keeper Secrets Manager (KSM) using the SDK. We will cover both file-based configuration (initialized with a One-Time Token) and in-memory configuration (using a Base64 encoded string).

## 1. Create Your Python Application File

```bash
touch main.py
```
`touch main.py`{{execute}}

## 2. Add Connection Code (File-based & In-Memory)

Copy and paste the following Python code into `main.py`:

```python
import os
from keeper_secrets_manager_core import SecretsManager
from keeper_secrets_manager_core.storage import FileKeyValueStorage, MemoryKeyValueStorage
from keeper_secrets_manager_core.options import SecretsManagerOptions

# --- Option 1: File-Based Configuration (using One-Time Token for first run) ---
# Replace with your actual One-Time Access Token for initial file setup
ONE_TIME_TOKEN_FILE = os.environ.get("KSM_ONE_TIME_TOKEN_FILE", "[ONE_TIME_TOKEN_FOR_FILE_CONFIG]")
CONFIG_FILE_NAME = "ksm-config.json"

# --- Option 2: In-Memory Configuration (using Base64 encoded config string) ---
# Replace with your Base64 encoded KSM configuration string
# Obtain from Keeper Vault: Secrets Manager -> Applications -> (Your App) -> Devices -> Add Device -> Configuration File
KSM_CONFIG_BASE64 = os.environ.get("KSM_CONFIG_BASE64", "[YOUR_KSM_CONFIG_BASE64_STRING_HERE]")

def list_secrets_info(secrets_manager_instance, config_type_name):
    print(f"\n--- Attempting to retrieve secrets using {config_type_name} ---")
    try:
        all_secrets = secrets_manager_instance.get_secrets()
        print(f"Found {len(all_secrets)} secret(s) with {config_type_name}:")
        for i, secret in enumerate(all_secrets, 1):
            print(f"  --- Secret {i} ---")
            print(f"  Title: {secret.title}")
            print(f"  Type: {secret.type}")
            print(f"  UID: {secret.uid}")
            fields = secret.fields
            print(f"  Fields: {len(fields)} field(s)")
            if fields:
                field_types = [str(field.type) for field in fields]
                print(f"  Field types: {', '.join(field_types)}")
    except Exception as e:
        print(f"Error with {config_type_name}: {e}")

# --- Initialize and use File-Based Configuration ---
print("🚀 Demonstrating File-Based Configuration...")
if ONE_TIME_TOKEN_FILE and ONE_TIME_TOKEN_FILE != "[ONE_TIME_TOKEN_FOR_FILE_CONFIG]":
    print(f"Initializing FileKeyValueStorage ('{CONFIG_FILE_NAME}') with One-Time Token.")
    # For the first run, token is used. For subsequent runs, ksm-config.json is used.
    # SecretsManagerOptions allows more granular control if needed.
    file_storage = FileKeyValueStorage(CONFIG_FILE_NAME)
    options_file = SecretsManagerOptions(token=ONE_TIME_TOKEN_FILE, config=file_storage)
    secrets_manager_file = SecretsManager(options=options_file)
    list_secrets_info(secrets_manager_file, "File-Based Config")
else:
    print("Skipping File-Based Config example: ONE_TIME_TOKEN_FILE not provided or placeholder not replaced.")
    print(f"If '{CONFIG_FILE_NAME}' already exists from a previous run, that would be used by default if token is omitted.")


# --- Initialize and use In-Memory Configuration ---
print("\n🚀 Demonstrating In-Memory Configuration...")
if KSM_CONFIG_BASE64 and KSM_CONFIG_BASE64 != "[YOUR_KSM_CONFIG_BASE64_STRING_HERE]":
    print("Initializing MemoryKeyValueStorage with Base64 configuration string.")
    # The Base64 string is passed directly to MemoryKeyValueStorage
    memory_storage = MemoryKeyValueStorage(KSM_CONFIG_BASE64)
    options_memory = SecretsManagerOptions(config=memory_storage)
    # Token is not needed here as the Base64 config contains all necessary keys
    secrets_manager_memory = SecretsManager(options=options_memory)
    list_secrets_info(secrets_manager_memory, "In-Memory Config (Base64)")
else:
    print("Skipping In-Memory Config example: KSM_CONFIG_BASE64 not provided or placeholder not replaced.")

### 3. Configure Your Token/Base64 String

**For File-Based Configuration (Option 1):**
-   **⚠️ Important**: Replace `[ONE_TIME_TOKEN_FOR_FILE_CONFIG]` in `main.py` (or set the `KSM_ONE_TIME_TOKEN_FILE` environment variable) with your actual One-Time Access Token from Keeper. This is primarily for the *first run* to create the `ksm-config.json` file.
    -   To get a token: Log into Keeper Web Vault → Secrets Manager → Applications → Select/Create Application → Devices → Add Device → Method: One-Time Token.

**For In-Memory Configuration (Option 2):**
-   **⚠️ Important**: Replace `[YOUR_KSM_CONFIG_BASE64_STRING_HERE]` in `main.py` (or set the `KSM_CONFIG_BASE64` environment variable) with the actual Base64 encoded configuration string for your KSM application.
    -   To get this string: Log into Keeper Web Vault → Secrets Manager → Applications → Select/Create Application → Devices → (Select existing or Add New Device) → View: Configuration File. Copy the Base64 string.

### 4. Run the Application

```bash
python3 main.py
```
`python3 main.py`{{execute}}

## What This Code Does

1.  **Imports SDK Components**: Loads `SecretsManager`, storage types (`FileKeyValueStorage`, `MemoryKeyValueStorage`), and `SecretsManagerOptions`.
2.  **File-Based Configuration**: 
    -   Initializes `FileKeyValueStorage('ksm-config.json')`.
    -   Uses a `SecretsManagerOptions` object, passing the `token` (for the first run) and `config` (the file storage instance).
    -   Creates a `SecretsManager` instance with these options.
    -   On the first run, the SDK uses the token to bind with Keeper and stores cryptographic keys and connection info in `ksm-config.json`.
    -   Subsequent runs with the same `ksm-config.json` will not require the token if the file is valid.
3.  **In-Memory Configuration**: 
    -   Initializes `MemoryKeyValueStorage(KSM_CONFIG_BASE64)`, passing the Base64 encoded string directly.
    -   Uses `SecretsManagerOptions` with this memory storage instance.
    -   The token is not required as the Base64 string contains all necessary keys.
4.  **Retrieves and Displays Secrets**: For each configuration type, it fetches all secrets shared with the application and prints their basic information (title, type, UID, field count, and types).

## Configuration Storage Explained

-   **`FileKeyValueStorage('ksm-config.json')`**: Creates/uses a local JSON file to securely store the application's keys and connection details after the initial token-based binding. This file contains no plaintext secrets.
-   **`MemoryKeyValueStorage(base64_config_string)`**: Stores the KSM client configuration directly in memory from a Base64 encoded string. This is ideal for environments where file system persistence is not desired or available (e.g., serverless functions, containers). No files are created on disk for this method.

## Next Steps

In the next step, we'll explore how to retrieve specific secrets and access their individual fields in detail, and also how to implement client-side caching for performance.
