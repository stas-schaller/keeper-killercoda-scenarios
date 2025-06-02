# Step 2: Secret Management Operations

## List All Available Secrets

Start by viewing all secrets accessible to your KSM CLI:

```bash
ksm secret list
```
`ksm secret list`{{execute}}

This command shows all records you have access to, including their UIDs and titles.

## Get Detailed Secret Information

To view detailed information about a specific secret, use its UID:

```bash
ksm secret get [UID]
```
`ksm secret get [UID]`{{copy}}

**Replace `[UID]` with an actual UID from your secret list above.**

## Retrieve Specific Fields

You can retrieve specific fields from a secret:

### Get Password Only
```bash
ksm secret get [UID] --field password
```
`ksm secret get [UID] --field password`{{copy}}

### Get Username Only
```bash
ksm secret get [UID] --field login
```
`ksm secret get [UID] --field login`{{copy}}

### Get Custom Fields
```bash
ksm secret get [UID] --field [FIELD_NAME]
```
`ksm secret get [UID] --field [FIELD_NAME]`{{copy}}

## Search for Secrets

Search for secrets by title or other criteria:

```bash
ksm secret list --search "database"
```
`ksm secret list --search "database"`{{copy}}

## Update Secret Fields

You can update secret fields directly from the CLI:

### Update Password
```bash
ksm secret update --uid [UID] --field password=MyNewPassword123!
```
`ksm secret update --uid [UID] --field password=MyNewPassword123!`{{copy}}

### Update Username
```bash
ksm secret update --uid [UID] --field login=newusername
```
`ksm secret update --uid [UID] --field login=newusername`{{copy}}

### Update Custom Fields
```bash
ksm secret update --uid [UID] --field [FIELD_NAME]=[NEW_VALUE]
```
`ksm secret update --uid [UID] --field [FIELD_NAME]=[NEW_VALUE]`{{copy}}

## View Secret History

See the modification history of a secret:

```bash
ksm secret history [UID]
```
`ksm secret history [UID]`{{copy}}

## Export Secrets

Export secrets in various formats:

### JSON Format
```bash
ksm secret export --format json
```
`ksm secret export --format json`{{execute}}

### CSV Format
```bash
ksm secret export --format csv
```
`ksm secret export --format csv`{{execute}}

**⚠️ Security Note**: Be careful when exporting secrets. Ensure the output is handled securely and not logged or stored in insecure locations.
