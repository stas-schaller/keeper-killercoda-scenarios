# Keeper Secrets Manager Python SDK Tutorial

Welcome to the Keeper Secrets Manager Python SDK Tutorial! 

## What is Keeper Secrets Manager SDK?

The Keeper Secrets Manager (KSM) Python SDK provides a powerful, secure way to integrate your Python applications with Keeper's zero-knowledge security platform. It allows you to:

- **Retrieve secrets programmatically** from your Keeper vault.
- **Create, update, and delete records** directly from your applications.
- **Generate strong passwords** for new records.
- **Upload, download, and delete files/attachments** securely.
- **Create, list, update, and delete folders** for organization.
- **Cache secrets** for improved performance.
- **Use multiple storage backends** (file-based, in-memory using Base64 configuration).

## What You'll Learn

In this interactive tutorial, you will:

1.  **Connect to Keeper**: Set up basic authentication (token, file config, Base64 config) and retrieve secrets.
2.  **Implement Caching**: Improve performance with intelligent caching.
3.  **Create Records**: Programmatically add new secrets to your vault, including password generation.
4.  **Manage Records & Files**: Update records, and handle file uploads, downloads, and deletions.
5.  **Organize with Folders**: Create, list, update, and delete folders, and delete records.

## Prerequisites

-   A Keeper Security account with Secrets Manager enabled.
-   Basic familiarity with Python programming.
-   Access to your KSM Application's configuration (One-Time Token or Base64 string) and the UID of a Shared Folder it has access to (for folder/record creation).
-   **Test credentials only** (this is a learning environment).

## Key Features You'll Explore

- **Zero-Knowledge Security**: End-to-end encrypted secret access.
- **Multiple Authentication Methods**: Token-based, file-based config, and in-memory Base64 config.
- **Flexible Storage Options**: File and memory storage backends.
- **Full Record Lifecycle**: Create, read, update, and delete secrets programmatically.
- **Password Generation**: Utility to create strong, random passwords.
- **Comprehensive File Operations**: Upload, download, and delete file attachments.
- **Full Folder Management**: Create, list, update (rename), and delete folders.
- **Performance Optimization**: Built-in caching.

## ⚠️ IMPORTANT SECURITY NOTICE

**DO NOT USE YOUR PRODUCTION CREDENTIALS IN ANY OF THESE EXAMPLES**

This is a learning environment. Always use test accounts and dummy data for educational purposes. Never enter your real production passwords or sensitive information in tutorial environments.

Let's get started by setting up your KSM Python SDK environment!
