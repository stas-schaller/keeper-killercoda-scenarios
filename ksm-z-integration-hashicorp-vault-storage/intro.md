# Welcome to the Keeper Secrets Manager and HashiCorp Vault Integration Tutorial!

## About This Integration

Keeper Secrets Manager (KSM) provides your DevOps and IT teams with a fully cloud-based, zero-knowledge platform for managing all your infrastructure secrets, such as API keys, database passwords, access keys, certificates, and any type of confidential data.

HashiCorp Vault is a tool for securely accessing secrets. It provides a unified interface to any secret, while providing tight access control and recording a detailed audit log.

This integration allows you to use KSM as a secure backend to store secrets that can then be accessed and managed through HashiCorp Vault's interface. This combines Keeper's zero-knowledge security architecture with Vault's flexible secret management capabilities.

## Key Features & Benefits

*   **Centralized Secret Management**: Store your secrets securely in Keeper's zero-knowledge vault.
*   **Vault Compatibility**: Access KSM-managed secrets using standard HashiCorp Vault CLI commands and API calls.
*   **Fine-Grained Access Control**: Leverage Vault's policies to control access to secrets stored in KSM.
*   **Audit Trails**: Utilize audit logs from both KSM and Vault for comprehensive tracking.

## What You'll Learn

In this tutorial, you will learn how to:

*   Install and configure the Keeper Secrets Manager plugin for HashiCorp Vault.
*   Start a HashiCorp Vault server in development mode with the KSM plugin enabled.
*   Configure the KSM plugin within Vault using your KSM application credentials.
*   List and read secrets from your Keeper Vault using HashiCorp Vault commands.
*   Retrieve Time-based One-Time Passwords (TOTP) codes using the plugin.
*   Deregister the plugin and stop the Vault server.

## Prerequisites

*   A Keeper Business or Enterprise account.
*   A configured KSM Application. You will need its Base64 configuration string. 
    *   The KSM application must have at least **"View Record" (Read-Only)** permission on the Shared Folders or individual Records you intend to access through Vault for read operations (list, read record, read TOTP).
    *   If you plan to test the create, update, or delete secret operations (covered later in this tutorial), the KSM application will additionally need **"Edit Record" (Read-Write)** permission on the target Shared Folder (for creating secrets) or specific records (for updating/deleting).
*   Basic understanding of command-line interfaces.
*   Familiarity with Keeper Vault and HashiCorp Vault concepts is helpful but not strictly required.

## Environment Setup

This Killercoda environment will automatically install HashiCorp Vault for you. Please wait for the installation script in the terminal to complete. You will be placed in the `/root/hashicorp-vault` directory, which will be your primary working directory for this tutorial.

Let's get started!