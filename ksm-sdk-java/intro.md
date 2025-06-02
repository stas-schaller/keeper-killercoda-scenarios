# Keeper Secrets Manager Java SDK Tutorial

Welcome to the official tutorial for the Keeper Secrets Manager (KSM) Java SDK! This guide will walk you through integrating KSM into your Java applications for secure and streamlined secret management.

## What is the KSM Java SDK?

The KSM Java SDK allows your Java applications (including Spring Boot, Quarkus, and other frameworks) to securely retrieve and manage secrets stored in your Keeper Vault. It provides a robust, zero-knowledge interface to protect your sensitive data like API keys, database passwords, certificates, and more.

### Key Features:
- **Zero-Knowledge Encryption**: Secrets are encrypted and decrypted locally; Keeper never has access to your plaintext data.
- **Versatile Storage Options**: Supports local file storage for configuration, and in-memory storage (via Base64 config string) for ephemeral environments.
- **Comprehensive Secret Management**: Retrieve, create, update, and delete records.
- **File Attachments**: Securely upload, download, and delete file attachments associated with your records.
- **Folder Management**: Create, list, update (rename), and delete folders.
- **Password Generation**: Utility to generate strong, random passwords.
- **Caching**: Improve performance with configurable local caching of secrets.
- **Gradle & Maven Compatible**: Easily integrate into your existing Java build systems.

## What You'll Learn

By the end of this tutorial, you will be able to:

1.  **Set up your Java project** with the KSM SDK and Gradle.
2.  **Authenticate** your application with Keeper using a One-Time Token or a Base64 configuration string.
3.  **Retrieve secrets**: Fetch all secrets, query for specific records by UID or title, and access individual field values.
4.  **Create new records** (with password generation) and folders programmatically.
5.  **Update existing records** and their fields.
6.  **Delete records** securely.
7.  **Manage file attachments**: Upload, download, and delete files associated with records.
8.  **Implement advanced configurations**, including in-memory storage and client-side caching.

## Prerequisites

-   Basic understanding of Java programming and object-oriented concepts.
-   Familiarity with a Java build tool (this tutorial uses Gradle).
-   A Keeper Business or Enterprise account with the Secrets Manager add-on enabled.
-   Access to your KSM Application's configuration (One-Time Token or Base64 string) and the UID of a Shared Folder it has access to (for folder/record creation).
-   **Important**: For this tutorial, ensure you use a **test Keeper account or test credentials**. Never use your production secrets in a learning environment.

## Security Best Practices Reminder

-   **Never hardcode secrets** directly in your application code.
-   Always use the **principle of least privilege** when sharing secrets with your KSM application.
-   Regularly **rotate your One-Time Tokens** and application configurations.
-   Store KSM configuration files (`ksm-config.json`) securely with appropriate file permissions, or prefer in-memory configuration for production environments.

Let's get started by setting up your Java project and connecting to Keeper!
