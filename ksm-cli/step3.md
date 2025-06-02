# Step 3: Advanced Usage & Automation

## Environment Variable Configuration

For automation and CI/CD pipelines, you can use KSM CLI with environment variables instead of local config files.

### Export Configuration to Environment Variable

First, get your current configuration:

```bash
ksm config export
```
`ksm config export`{{execute}}

### Set Configuration as Environment Variable

Set the configuration as an environment variable (replace with your actual config):

```bash
export KSM_CONFIG='[YOUR_KSM_CONFIG_JSON_OR_BASE64]'
```
`export KSM_CONFIG='[YOUR_KSM_CONFIG_JSON_OR_BASE64]'`{{copy}}

### Test Environment Variable Configuration

Now test that KSM CLI works with the environment variable:

```bash
ksm secret list
```
`ksm secret list`{{execute}}

## Secret Notation for Automation

KSM CLI supports a special notation syntax for retrieving secrets in scripts and automation:

### Get Password Using Notation
```bash
export MY_PASSWORD=$(ksm secret notation keeper://[RECORD_UID]/field/password)
```
`export MY_PASSWORD=$(ksm secret notation keeper://[RECORD_UID]/field/password)`{{copy}}

### Verify the Retrieved Password
```bash
echo "Password retrieved: $MY_PASSWORD"
```
`echo "Password retrieved: $MY_PASSWORD"`{{execute}}

### Get Other Fields Using Notation
```bash
export MY_USERNAME=$(ksm secret notation keeper://[RECORD_UID]/field/login)
export MY_URL=$(ksm secret notation keeper://[RECORD_UID]/field/url)
```
`export MY_USERNAME=$(ksm secret notation keeper://[RECORD_UID]/field/login)`{{copy}}

## File Operations

KSM CLI can handle file attachments and downloads:

### Download a File from a Secret
```bash
ksm secret download --uid [RECORD_UID] --name "certificate.pem" --file-output "/tmp/certificate.pem"
```
`ksm secret download --uid [RECORD_UID] --name "certificate.pem" --file-output "/tmp/certificate.pem"`{{copy}}

### Verify Downloaded File
```bash
file /tmp/certificate.pem
ls -la /tmp/certificate.pem
```
`file /tmp/certificate.pem`{{execute}}

### Upload a File to a Secret
```bash
ksm secret upload --uid [RECORD_UID] --file "/path/to/local/file.txt"
```
`ksm secret upload --uid [RECORD_UID] --file "/path/to/local/file.txt"`{{copy}}

## Automation Examples

### Script Example: Database Connection
```bash
#!/bin/bash
# Get database credentials
DB_HOST=$(ksm secret notation keeper://[DB_RECORD_UID]/field/url)
DB_USER=$(ksm secret notation keeper://[DB_RECORD_UID]/field/login)
DB_PASS=$(ksm secret notation keeper://[DB_RECORD_UID]/field/password)

# Use credentials (example)
echo "Connecting to database at $DB_HOST as $DB_USER"
```

### Script Example: API Key Retrieval
```bash
#!/bin/bash
# Get API key for external service
API_KEY=$(ksm secret notation keeper://[API_RECORD_UID]/field/password)
export API_KEY

# Use in curl request
curl -H "Authorization: Bearer $API_KEY" https://api.example.com/data
```

## CI/CD Integration

### GitHub Actions Example
```yaml
- name: Get secrets from Keeper
  run: |
    export KSM_CONFIG="${{ secrets.KSM_CONFIG }}"
    export DB_PASSWORD=$(ksm secret notation keeper://[UID]/field/password)
    export API_KEY=$(ksm secret notation keeper://[UID]/field/api_key)
```

### Docker Integration
```bash
# Pass secrets to Docker container
docker run -e DB_PASSWORD="$(ksm secret notation keeper://[UID]/field/password)" myapp
```

## Advanced Configuration

### Multiple Profiles
```bash
# Create additional profiles
ksm profile init --token [TOKEN] --profile production
ksm profile init --token [TOKEN] --profile staging

# Use specific profile
ksm secret list --profile production
```

### Configuration Management
```bash
# Show current configuration
ksm config show

# Validate configuration
ksm config validate

# Reset configuration
ksm config reset
```

## Best Practices for Automation

1. **Use Environment Variables**: Store KSM_CONFIG in secure environment variables
2. **Rotate Tokens**: Regularly rotate your One-Time Access Tokens
3. **Least Privilege**: Only grant access to secrets that are actually needed
4. **Secure Logging**: Ensure secrets don't appear in logs or console output
5. **Error Handling**: Always handle cases where secret retrieval might fail

## Documentation and Help

For more commands and options, see the official documentation:
- [KSM CLI Documentation](https://docs.keeper.io/secrets-manager/secrets-manager/secrets-manager-command-line-interface)
- Built-in help: `ksm --help`
- Command-specific help: `ksm secret --help`
