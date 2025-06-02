# Step 1: Initialize & Configure KSM CLI

## Verify Installation

First, let's verify that the Keeper Secrets Manager CLI has been installed correctly:

```bash
ksm --version
```
`ksm --version`{{execute}}

**If the command is not found**, activate the virtual environment:

```bash
source /opt/ksm-env/bin/activate
ksm --version
```
`source /opt/ksm-env/bin/activate`{{execute}}

## Understanding KSM CLI

The KSM CLI provides secure access to your Keeper vault through the Secrets Manager. It uses:

- **Zero-Knowledge Architecture**: Your secrets are encrypted/decrypted locally
- **One-Time Access Tokens**: Secure device registration
- **Client Device Authentication**: Each CLI instance is a registered device

## Initialize Your Client Device

To start using KSM CLI, you need to initialize it with a One-Time Access Token from your Keeper vault.

**⚠️ Important**: Replace `XX:XXXX` with your actual One-Time Access Token from Keeper.

```bash
ksm profile init --token XX:XXXX
```
`ksm profile init --token XX:XXXX`{{copy}}

## Verify Configuration

After initialization, verify your configuration:

```bash
ksm profile list
```
`ksm profile list`{{execute}}

## Test Connection

Test that you can connect to your Keeper vault:

```bash
ksm secret list
```
`ksm secret list`{{execute}}

**Note**: If you see an error, make sure you've replaced `XX:XXXX` with your actual token and that your Keeper account has Secrets Manager enabled.

## Understanding the Configuration

The KSM CLI stores its configuration in a local file. You can view the configuration location:

```bash
ksm config show
```
`ksm config show`{{execute}}

This configuration contains encrypted connection details and is safe to store locally.
