# Keeper Secrets Manager JavaScript SDK Tutorial

Welcome to the Keeper Secrets Manager (KSM) JavaScript SDK Tutorial! This guide will walk you through integrating KSM into your Node.js applications for secure and streamlined secret management.

## What is the KSM JavaScript SDK?

The KSM JavaScript SDK allows your Node.js applications to securely retrieve and manage secrets stored in your Keeper Vault. It provides a robust, zero-knowledge interface to protect your sensitive data like API keys, database passwords, certificates, and more.

### Key Features:
- **Zero-Knowledge Encryption**: Secrets are encrypted and decrypted locally; Keeper never has access to your plaintext data.
- **Versatile Configuration**: Supports initialization via One-Time Tokens, local configuration files, and direct Base64 encoded configuration strings (for in-memory setup).
- **Comprehensive Secret Management**: Retrieve, create, update, and delete records. 
- **File Attachments**: Upload files to records, download files, and manage file references.
- **Folder Organization**: Create, list, rename, and delete folders to organize your secrets.
- **Password Generation**: Utility to generate strong, random passwords.
- **Typed Fields**: Use specific classes for different field types when creating/updating records.
- **Asynchronous Operations**: Leverages async/await for non-blocking operations suitable for Node.js applications.
- **Client-Side Caching**: Options to implement client-side caching to reduce network calls and improve performance (demonstrated with a Node.js example).
- **NPM Package**: Easily integrated into your projects via npm (`@keeper-security/secrets-manager-core`).

## What You'll Learn

By the end of this tutorial, you will be able to:

1.  **Set up your Node.js project** with the KSM SDK.
2.  **Authenticate** your application with Keeper using a One-Time Token, a configuration file, or a Base64 configuration string.
3.  **Retrieve secrets**: List all shared secrets, fetch specific records by UID or title, and access various field types (standard, custom, notes).
4.  **Create new records** with different field types using SDK helper classes and generate passwords.
5.  **Update existing records**.
6.  **Manage file attachments**: Upload files to records, download files from records, and remove file references.
7.  **Delete records** securely.
8.  **Organize secrets with folders**: Create, list, rename, and delete folders.
9.  **Implement advanced configurations**: Use in-memory configuration and implement client-side caching (Node.js example).

## Prerequisites

-   Basic understanding of JavaScript and Node.js.
-   Node.js and npm installed.
-   A Keeper Business or Enterprise account with the Secrets Manager add-on enabled.
-   Access to your KSM Application's configuration (One-Time Token or Base64 string) and the UID of a Shared Folder it has access to.
-   **Important**: For this tutorial, ensure you use a **test Keeper account or test credentials**. Never use your production secrets in a learning environment.

## Security Best Practices Reminder

-   **Never hardcode secrets** directly in your application code.
-   Always use the **principle of least privilege** when sharing secrets with your KSM application.
-   Regularly **rotate your One-Time Tokens** and application configurations if not using automated rotation methods.
-   Store KSM configuration files (`ksm-config.json`) securely with appropriate file permissions if used, or prefer in-memory configuration (e.g., via environment variables storing the Base64 config) for production environments.

Let's get started by setting up your project and connecting to Keeper!
