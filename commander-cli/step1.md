# Step 1: Setup & Connect to Keeper

## Verify Installation

First, verify that Keeper Commander CLI is working:

```bash
keeper --version
```
`keeper --version`{{execute}}

**Note**: For all commands in this tutorial, use `keeper`.

## Understanding Keeper Data Centers

Keeper Security operates multiple data centers around the world to ensure optimal performance and compliance with local data residency requirements. Before connecting, you need to specify which data center hosts your Keeper account.

## Connecting to Your Data Center

Choose the appropriate command based on your account's data center location:

### 🇺🇸 United States (Default)
```bash
keeper shell
```
`keeper shell`{{execute}}

### 🇪🇺 European Union
```bash
keeper shell --server keepersecurity.eu
```
`keeper shell --server keepersecurity.eu`{{execute}}

### 🇦🇺 Australia
```bash
keeper shell --server keepersecurity.com.au
```
`keeper shell --server keepersecurity.com.au`{{execute}}

### 🇺🇸 Government Cloud
```bash
keeper shell --server govcloud.keepersecurity.us
```
`keeper shell --server govcloud.keepersecurity.us`{{execute}}

### 🇨🇦 Canada
```bash
keeper shell --server keepersecurity.ca
```
`keeper shell --server keepersecurity.ca`{{execute}}

### 🇯🇵 Japan
```bash
keeper shell --server keepersecurity.jp
```
`keeper shell --server keepersecurity.jp`{{execute}}

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
