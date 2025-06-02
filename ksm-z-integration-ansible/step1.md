# Step 1: Setup & Installation

## Verify Installation

First, let's verify that Ansible and the KSM plugin were installed correctly:

### Check Ansible Version
```bash
ansible --version
```
`ansible --version`{{execute}}

### Verify KSM Plugin Installation
```bash
python3 -c "import keeper_secrets_manager_ansible; print('✅ KSM Ansible plugin is installed and ready!')"
```
`python3 -c "import keeper_secrets_manager_ansible; print('✅ KSM Ansible plugin is installed and ready!')"`{{execute}}

## Configure Environment for KSM Plugin

The KSM Ansible plugin needs to be visible to Ansible. Let's configure the environment:

```bash
export $(keeper_ansible --config)
```
`export $(keeper_ansible --config)`{{execute}}

This command sets the necessary environment variables that tell Ansible where to find the KSM plugins.

### Verify Plugin Configuration
```bash
echo "ANSIBLE_LOOKUP_PLUGINS: $ANSIBLE_LOOKUP_PLUGINS"
echo "ANSIBLE_ACTION_PLUGINS: $ANSIBLE_ACTION_PLUGINS"
```
`echo "ANSIBLE_LOOKUP_PLUGINS: $ANSIBLE_LOOKUP_PLUGINS"`{{execute}}
`echo "ANSIBLE_ACTION_PLUGINS: $ANSIBLE_ACTION_PLUGINS"`{{execute}}

## Understanding the KSM Ansible Plugin

The Keeper Secrets Manager Ansible plugin provides several modules:

### **Lookup Plugins**
- `keeper_get`: Retrieve secret values from Keeper records
- `keeper_password`: Get password fields specifically
- `keeper_file`: Retrieve file attachments from records

### **Action Plugins**
- `keeper_copy`: Copy secret values to files with proper permissions
- `keeper_template`: Use secrets in Jinja2 templates
- `keeper_set_fact`: Store retrieved secrets as Ansible facts

## Plugin Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Ansible       │    │  KSM Plugin      │    │  Keeper Vault   │
│   Playbook      │    │                  │    │                 │
│                 │    │  ┌─────────────┐ │    │  ┌─────────────┐│
│  keeper_get:    │───▶│  │ Lookup      │ │───▶│  │ Encrypted   ││
│    uid: xxx     │    │  │ Plugins     │ │    │  │ Records     ││
│    field: pwd   │    │  └─────────────┘ │    │  └─────────────┘│
│                 │    │                  │    │                 │
│  keeper_copy:   │───▶│  ┌─────────────┐ │    │  ┌─────────────┐│
│    dest: /tmp   │    │  │ Action      │ │───▶│  │ Zero-Know   ││
│    mode: 0600   │    │  │ Plugins     │ │    │  │ Encryption  ││
└─────────────────┘    │  └─────────────┘ │    │  └─────────────┘│
                       └──────────────────┘    └─────────────────┘
```

## Security Features

- **Zero-Knowledge Encryption**: Secrets are decrypted only on the target machine
- **Secure Transport**: All communication uses TLS encryption
- **Access Control**: Respects Keeper's sharing and permission model
- **Audit Logging**: All secret access is logged in Keeper's audit trail
- **No Caching**: Secrets are retrieved fresh each time (unless explicitly cached)

## Next Steps

In the next step, we'll configure authentication and create your first secure playbook that retrieves secrets from Keeper.

