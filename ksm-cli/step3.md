# Step 3: Working with Files

**Learning Objective**: Learn to securely store, retrieve, and manage file attachments in your Keeper vault.

## Understanding File Storage in Keeper

Keeper can store any type of file as encrypted attachments to secret records:
- **Certificates**: `.pem`, `.crt`, `.p12`, `.key` files
- **Configuration files**: `.json`, `.yaml`, `.conf`, `.ini`
- **Documentation**: `.pdf`, `.docx`, `.txt`, `.md`
- **Images**: `.png`, `.jpg`, `.gif`, `.svg`
- **Archives**: `.zip`, `.tar.gz`, `.7z`
- **Any file type**: No restrictions on file extensions

## List Files in a Secret

First, let's see if any of your secrets contain file attachments:

```bash
ksm secret get Wyd4dgLyAwaI4k-ScH8TJg
```
`ksm secret get Wyd4dgLyAwaI4k-ScH8TJg`{{execute}}

**🔍 What to look for**: If the secret contains files, you'll see a "Files" section showing file names, sizes, and types.

**💡 Pro Tip**: You can use any secret UID from your `ksm secret list` output. The UID above is from the "Configuration Files" record in the test vault.

## Create a Test File to Upload

Let's create a sample configuration file to work with:

```bash
cat > sample-config.json << 'EOF'
{
  "database": {
    "host": "localhost",
    "port": 5432,
    "name": "myapp"
  },
  "api": {
    "version": "v1",
    "timeout": 30
  }
}
EOF
```
`cat > sample-config.json << 'EOF'
{
  "database": {
    "host": "localhost",
    "port": 5432,
    "name": "myapp"
  },
  "api": {
    "version": "v1",
    "timeout": 30
  }
}
EOF`{{execute}}

**✅ Expected Output**: File created successfully.

## Upload a File to a Secret

Upload the configuration file to one of your secrets:

```bash
ksm secret upload --uid [RECORD_UID] --file sample-config.json --title "Application Configuration"
```
`ksm secret upload --uid [RECORD_UID] --file sample-config.json --title "Application Configuration"`{{copy}}

**⚠️ Action Required**: Replace `[RECORD_UID]` with an actual UID from your secret list (try the "Configuration Files" record).

**✅ Expected Output**: No output means successful upload.

### Alternative Upload Methods

Upload without a custom title (uses filename):
```bash
ksm secret upload --uid [RECORD_UID] --file sample-config.json
```
`ksm secret upload --uid [RECORD_UID] --file sample-config.json`{{copy}}

## Verify File Upload

Check that your file was uploaded successfully:

```bash
ksm secret get [RECORD_UID]
```
`ksm secret get [RECORD_UID]`{{copy}}

**✅ Expected Output**: You should now see a "Files" section listing your uploaded file with name, size, and type.

## Download Files from Secrets

Download a file from a secret to your local system:

```bash
ksm secret download --uid [RECORD_UID] --name "sample-config.json" --file-output "downloaded-config.json"
```
`ksm secret download --uid [RECORD_UID] --name "sample-config.json" --file-output "downloaded-config.json"`{{copy}}

**✅ Expected Output**: File downloaded successfully.

### Verify the Downloaded File

```bash
cat downloaded-config.json
```
`cat downloaded-config.json`{{execute}}

**✅ Expected Output**: Should show the same JSON content you uploaded.

## Alternative Download Methods

### Download to Standard Output
Useful for piping to other commands:

```bash
ksm secret download --uid [RECORD_UID] --name "sample-config.json" --file-output stdout
```
`ksm secret download --uid [RECORD_UID] --name "sample-config.json" --file-output stdout`{{copy}}

### Download with Folder Creation
Create directories automatically if they don't exist:

```bash
ksm secret download --uid [RECORD_UID] --name "sample-config.json" --file-output "/tmp/app-configs/config.json" --create-folders
```
`ksm secret download --uid [RECORD_UID] --name "sample-config.json" --file-output "/tmp/app-configs/config.json" --create-folders`{{copy}}

## Using File Notation for Automation

Access file content using Keeper's notation syntax:

```bash
export CONFIG_CONTENT=$(ksm secret notation "keeper://[RECORD_UID]/file/sample-config.json")
echo "$CONFIG_CONTENT"
```
`export CONFIG_CONTENT=$(ksm secret notation "keeper://[RECORD_UID]/file/sample-config.json")`{{copy}}

**⚠️ Action Required**: Replace `[RECORD_UID]` with your actual record UID.

**🔍 What happened?**: The file content is retrieved as Base64-encoded data, perfect for scripts and automation.

## Real-World File Use Cases

### SSL Certificate Management
```bash
# Upload certificate files
ksm secret upload --uid [SSL_RECORD_UID] --file server.crt --title "SSL Certificate"
ksm secret upload --uid [SSL_RECORD_UID] --file server.key --title "Private Key"

# Download for deployment
ksm secret download --uid [SSL_RECORD_UID] --name "server.crt" --file-output "/etc/ssl/certs/server.crt"
ksm secret download --uid [SSL_RECORD_UID] --name "server.key" --file-output "/etc/ssl/private/server.key"
```

### Application Configuration Deployment
```bash
# Get config file content and deploy
ksm secret download --uid [CONFIG_UID] --name "app-config.json" --file-output stdout > /app/config.json

# Or use notation in deployment scripts
CONFIG=$(ksm secret notation "keeper://[CONFIG_UID]/file/app-config.json")
echo "$CONFIG" | base64 -d > /app/config.json
```

### Docker Secrets Integration
```bash
# Download secret files for Docker containers
ksm secret download --uid [SECRET_UID] --name "docker-secret.txt" --file-output "/var/run/secrets/app-secret"

# Or pipe directly to Docker
ksm secret download --uid [SECRET_UID] --name "secret.txt" --file-output stdout | docker secret create app-secret -
```

## File Security Features

**🔒 Automatic Encryption**: All files are automatically encrypted before upload using AES encryption.

**🔑 Access Control**: File access is controlled by the same permissions as the parent secret record.

**📝 Metadata Protection**: File names, sizes, and types are also encrypted and protected.

**🔄 Version Control**: While KSM doesn't provide file versioning, you can upload new versions by uploading files with the same name.

## Working with Different File Types

### Text Files
```bash
# View content directly
ksm secret download --uid [UID] --name "readme.txt" --file-output stdout

# Edit and re-upload workflow
ksm secret download --uid [UID] --name "config.txt" --file-output "temp-config.txt"
nano temp-config.txt  # Edit the file
ksm secret upload --uid [UID] --file "temp-config.txt" --title "Updated Config"
```

### Binary Files
```bash
# Download binary files (certificates, executables, etc.)
ksm secret download --uid [UID] --name "app.exe" --file-output "application.exe"
chmod +x application.exe
```

### Archive Files
```bash
# Download and extract archives
ksm secret download --uid [UID] --name "backup.tar.gz" --file-output "backup.tar.gz"
tar -xzf backup.tar.gz
```

## Troubleshooting File Operations

### Common Issues

**❌ "File not found" error**: 
- Check the exact filename using `ksm secret get [UID]`
- File names are case-sensitive

**❌ "Directory doesn't exist" error**:
- Use `--create-folders` flag when downloading
- Or create the directory first: `mkdir -p /path/to/directory`

**❌ "Permission denied" error**:
- Ensure you have write permissions to the download location
- Check that the secret record allows file access

### File Size Considerations

- **No hard size limits** in KSM CLI
- **Large files**: May take longer to upload/download
- **Network timeouts**: Consider network stability for very large files
- **Storage quotas**: Check your Keeper account storage limits

## Best Practices for File Management

### Security
- **Sensitive files**: Always store certificates, keys, and config files in Keeper rather than on disk
- **Access control**: Use separate records for files with different access requirements
- **File naming**: Use descriptive names and titles for easy identification

### Organization
- **Group related files**: Store related files (cert + key + config) in the same record
- **Clear titles**: Use descriptive titles that explain the file's purpose
- **Documentation**: Use the record's notes field to document file contents

### Automation
- **CI/CD integration**: Download config files and certificates during deployment
- **Rotation**: Automate certificate and key rotation by uploading new versions
- **Backup**: Use file downloads to create automated backups of critical configurations

## Next Steps

**🎉 Great work!** You now know how to:
- Upload any type of file to Keeper secrets
- Download files for local use or deployment
- Use file notation for automation scripts
- Apply security best practices for file management

**💡 Next Steps**: In Step 4, you'll learn advanced automation techniques for integrating file operations into CI/CD pipelines and production deployments.

**📚 Learn More**: [Official KSM CLI Documentation](https://docs.keeper.io/en/keeperpam/secrets-manager/secrets-manager-command-line-interface)