# Step 1: Setup & Connect to Keeper

## Activate the Environment

First, activate the Keeper Commander CLI environment:

```bash
source /opt/keeper-env/bin/activate
```
`source /opt/keeper-env/bin/activate`{{execute}}

## Verify Installation

Now verify that Keeper Commander CLI is working:

```bash
python -m keepercommander.cli --version
```
`python -m keepercommander.cli --version`{{execute}}

**Note**: For all commands in this tutorial, use `python -m keepercommander.cli` instead of just `keeper`.

## Understanding Keeper Data Centers

Keeper Security operates multiple data centers around the world to ensure optimal performance and compliance with local data residency requirements. Before connecting, you need to specify which data center hosts your Keeper account.

## Connecting to Your Data Center

Choose the appropriate command based on your account's data center location:

### 🇺🇸 United States (Default)
```bash
python -m keepercommander.cli shell
```
`python -m keepercommander.cli shell`{{execute}}

### 🇪🇺 European Union
```bash
python -m keepercommander.cli shell --server keepersecurity.eu
```
`python -m keepercommander.cli shell --server keepersecurity.eu`{{execute}}

### 🇦🇺 Australia
```bash
python -m keepercommander.cli shell --server keepersecurity.com.au
```
`python -m keepercommander.cli shell --server keepersecurity.com.au`{{execute}}

### 🇺🇸 Government Cloud
```bash
python -m keepercommander.cli shell --server govcloud.keepersecurity.us
```
`python -m keepercommander.cli shell --server govcloud.keepersecurity.us`{{execute}}

### 🇨🇦 Canada
```bash
python -m keepercommander.cli shell --server keepersecurity.ca
```
`python -m keepercommander.cli shell --server keepersecurity.ca`{{execute}}

### 🇯🇵 Japan
```bash
python -m keepercommander.cli shell --server keepersecurity.jp
```
`python -m keepercommander.cli shell --server keepersecurity.jp`{{execute}}

## What Happens Next

When you run the command:

1. **Connection Established**: Commander connects to your specified data center
2. **Authentication Prompt**: You'll be asked for your email and master password
3. **Two-Factor Authentication**: If enabled, you'll need to provide your 2FA code
4. **Interactive Shell**: You'll enter the Keeper Commander interactive environment

## Troubleshooting Connection Issues

If you encounter connection problems:

- **Check Data Center**: Ensure you're connecting to the correct regional server
- **Network Access**: Verify your network allows HTTPS connections to Keeper servers
- **Credentials**: Double-check your email address and master password
- **2FA**: Ensure your two-factor authentication device is available

**⚠️ Security Reminder**: This is a learning environment. Use test credentials only!
