# Step 1: Initialize & Configure KSM CLI

**Learning Objective**: Set up secure CLI access to your Keeper vault and understand basic configuration.

## What You'll Learn
Secrets management solves the problem of hardcoded passwords, API keys, and credentials in code. Instead of storing sensitive data in files or environment variables, KSM CLI securely retrieves secrets from your encrypted Keeper vault.

## Verify Installation

First, verify that the Keeper Secrets Manager CLI is working:

```bash
ksm version
```
`ksm version`{{execute}}

**✅ Expected Output**: You should see version information for Python, CLI, and SDK.

## Understanding KSM CLI

The KSM CLI provides secure access to your Keeper vault through the Secrets Manager. It uses:

- **Zero-Knowledge Architecture**: Your secrets are encrypted/decrypted locally (Keeper never sees your data)
- **One-Time Access Tokens**: Secure device registration (tokens expire after first use)
- **Client Device Authentication**: Each CLI instance is a registered device in your vault

## Get Your One-Time Access Token

**Where to find your token:**
1. Log into your Keeper vault
2. Go to **Settings** → **Secrets Manager**
3. Create or select an Application
4. Click **"One-Time Access Token"**
5. Copy the token (format: `US:ABC123...`)

## Initialize Your Client Device

A "profile" is a saved configuration that connects your CLI to your Keeper vault. You need to initialize it once with a One-Time Access Token.

**⚠️ Important**: Replace `XX:XXXX` with your actual token from Keeper.

```bash
ksm profile init --token XX:XXXX
```
`ksm profile init --token XX:XXXX`{{copy}}

**✅ Expected Output**: `Added profile _default to INI config file`

## Verify Configuration

After initialization, verify your profile was created:

```bash
ksm profile list
```
`ksm profile list`{{execute}}

**✅ Expected Output**: Shows your `_default` profile with an asterisk (*) indicating it's active.

## Test Connection

Test that you can connect to your Keeper vault:

```bash
ksm secret list
```
`ksm secret list`{{execute}}

**✅ Expected Output**: A table showing your secrets with UID, Record Type, and Title columns.

## Understanding the Configuration

The KSM CLI stores its configuration in a local encrypted file. You can view the configuration details:

```bash
ksm config show
```
`ksm config show`{{execute}}

**🔍 What just happened?**
- Your CLI is now registered as a trusted device in your Keeper vault
- The configuration file contains encrypted connection details (safe to store locally)
- The One-Time Access Token has been consumed and cannot be reused

## Troubleshooting

**❌ "Signature is invalid" error**: Your token has expired or been used. Generate a new token in Keeper.

**❌ "Access denied" error**: Check that Secrets Manager is enabled in your Keeper account and the application has the correct permissions.

**💡 Real-world use case**: You've just set up secure CLI access that developers can use in CI/CD pipelines, local development, and production deployments without hardcoded secrets.
