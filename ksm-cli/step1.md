# Step 1: Initialize & Configure KSM CLI

## Verify Installation

First, verify that the Keeper Secrets Manager CLI is working:

```bash
python3 -m keeper_secrets_manager_cli --version
```
`python3 -m keeper_secrets_manager_cli --version`{{execute}}

**Note**: For all commands in this tutorial, use `python3 -m keeper_secrets_manager_cli`.

## Understanding KSM CLI

The KSM CLI provides secure access to your Keeper vault through the Secrets Manager. It uses:

- **Zero-Knowledge Architecture**: Your secrets are encrypted/decrypted locally
- **One-Time Access Tokens**: Secure device registration
- **Client Device Authentication**: Each CLI instance is a registered device

## Initialize Your Client Device

To start using KSM CLI, you need to initialize it with a One-Time Access Token from your Keeper vault.

**⚠️ Important**: Replace `XX:XXXX` with your actual One-Time Access Token from Keeper.

```bash
python3 -m keeper_secrets_manager_cli profile init --token XX:XXXX
```
`python3 -m keeper_secrets_manager_cli profile init --token XX:XXXX`{{copy}}

## Verify Configuration

After initialization, verify your configuration:

```bash
python3 -m keeper_secrets_manager_cli profile list
```
`python3 -m keeper_secrets_manager_cli profile list`{{execute}}

## Test Connection

Test that you can connect to your Keeper vault:

```bash
python3 -m keeper_secrets_manager_cli secret list
```
`python3 -m keeper_secrets_manager_cli secret list`{{execute}}

**Note**: If you see an error, make sure you've replaced `XX:XXXX` with your actual token and that your Keeper account has Secrets Manager enabled.

## Understanding the Configuration

The KSM CLI stores its configuration in a local file. You can view the configuration location:

```bash
python3 -m keeper_secrets_manager_cli config show
```
`python3 -m keeper_secrets_manager_cli config show`{{execute}}

This configuration contains encrypted connection details and is safe to store locally.
