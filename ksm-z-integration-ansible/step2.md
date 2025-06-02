# Step 2: Configuration & Basic Usage

## Navigate to Playbooks Directory

Let's navigate to the directory where we'll store our configuration and playbooks:

```bash
cd my-playbooks
```
`cd my-playbooks`{{execute}}

## Initialize KSM Configuration

The KSM Ansible plugin needs a configuration file to authenticate with Keeper. Initialize it with your One-Time Access Token:

```bash
keeper_ansible --token [ONE TIME TOKEN]
```
`keeper_ansible --token [ONE TIME TOKEN]`{{copy}}

**⚠️ Important**: Replace `[ONE TIME TOKEN]` with your actual token from Keeper Web Vault.

### Set Secure Permissions

Set proper permissions on the configuration file to avoid security warnings:

```bash
chmod 600 client-config.json
```
`chmod 600 client-config.json`{{execute}}

## Create Your First Secure Playbook

Let's create a sample playbook that demonstrates KSM integration:

```bash
touch ksm-sample-playbook.yml
```
`touch ksm-sample-playbook.yml`{{execute}}

### Add the Playbook Content

Copy and paste this secure playbook configuration:

```yaml
---
- name: KSM Plugin Sample Playbook
  hosts: 127.0.0.1
  connection: local
  gather_facts: false
  
  tasks:
    - name: Copy a password to a file securely
      keeper_copy:
        uid: [RECORD UID]
        field: password
        dest: /tmp/my_password
        mode: "0600"
        
    - name: Retrieve login username
      keeper_get:
        uid: [RECORD UID]
        field: login      
      register: my_login
        
    - name: Display login name (safe to show)
      debug:
        var: my_login.value
        verbosity: 0
        
    - name: Verify file was created with correct permissions
      stat:
        path: /tmp/my_password
      register: password_file
      
    - name: Show file permissions
      debug:
        msg: "Password file permissions: {{ password_file.stat.mode }}"
```{{copy}}

### Configure Your Record UID

**Replace `[RECORD UID]` with your actual record UID from Keeper.**

To get your Record UID:
1. Log into Keeper Web Vault
2. Navigate to the record you want to use
3. Click on the record to open it
4. Copy the **Record UID** from the record details

## Understanding the Playbook

### **keeper_copy Module**
- **Purpose**: Securely copies secret values to files
- **Security**: Sets proper file permissions automatically
- **Use Case**: Storing passwords, certificates, or keys as files

### **keeper_get Module**
- **Purpose**: Retrieves secret values into Ansible variables
- **Security**: Values are stored in memory only
- **Use Case**: Using secrets in templates, conditions, or other tasks

### **Security Features**
- **File permissions**: Automatically sets secure permissions (0600)
- **Memory handling**: Secrets are cleared from memory after use
- **Audit logging**: All access is logged in Keeper's audit trail

## Run Your Secure Playbook

Execute the playbook to see KSM in action:

```bash
ansible-playbook ksm-sample-playbook.yml
```
`ansible-playbook ksm-sample-playbook.yml`{{execute}}

## Verify the Results

Check that the password was securely written to the file:

```bash
ls -la /tmp/my_password
```
`ls -la /tmp/my_password`{{execute}}

View the password content (for demonstration only):

```bash
cat /tmp/my_password
```
`cat /tmp/my_password`{{execute}}

**Note**: In production, you would never display passwords like this. This is for educational purposes only.

## What Happened?

1. **Authentication**: The plugin authenticated with Keeper using your token
2. **Secret Retrieval**: Retrieved the password and login from your specified record
3. **Secure Storage**: Wrote the password to a file with 0600 permissions
4. **Variable Registration**: Stored the login in an Ansible variable
5. **Audit Logging**: All actions were logged in Keeper's audit trail

## Next Steps

In the next step, we'll explore advanced playbook examples including database connections, file uploads, and complex automation scenarios.
