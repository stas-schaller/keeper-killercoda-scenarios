
### 1. Configure KSM

`vault write myksm/config ksm_config=[KSM CONFIG IN BASE 64]`{{copy}}

Use Commander to obtain a configuration string

### 2. List secrets

`vault list myksm/records`{{execute}}

### 3. Read record by UID

`vault read -format=json myksm/record uid=[RECORD UID]`{{copy}}

### 4. Get TOTP values from record

`vault read -format=json myksm/record/totp uid=[RECORD UID]`{{copy}}


### Deregister the plugin

Make sure that the server is running

`vault secrets disable myksm`{{execute T2}}

`vault plugin deregister secret vault-plugin-secrets-ksm`{{execute T2}}

`vault plugin list secret`{{execute T2}}


### Stop the server
`echo 'Vault stopped'`{{execute interrupt T1}}
