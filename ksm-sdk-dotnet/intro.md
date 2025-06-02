# Keeper Secrets Manager .NET SDK Tutorial

Welcome to the official tutorial for the Keeper Secrets Manager (KSM) .NET SDK! This guide will help you integrate KSM into your .NET applications (including ASP.NET Core, Console Apps, Worker Services, etc.) for robust and secure secret management.

## What is the KSM .NET SDK?

The KSM .NET SDK empowers your .NET applications to securely access and manage secrets stored within your Keeper Vault. Built on Keeper's zero-knowledge architecture, it ensures that your sensitive data (API keys, database credentials, certificates, connection strings, etc.) remains protected at all times.

### Key Features:
- **Zero-Knowledge Security**: Secrets are encrypted and decrypted locally on your client. Keeper never has access to your plaintext secret data.
- **Cross-Platform**: Compatible with .NET Core and .NET Framework, running on Windows, macOS, and Linux.
- **Flexible Storage Options**: Supports local file storage for KSM configuration, in-memory storage for dynamic environments, and can be integrated with cloud-specific configuration providers.
- **Full Secret Lifecycle Management**: Programmatically retrieve, create, update, and delete records and folders.
- **File Attachment Handling**: Securely manage files attached to your Keeper records.
- **Caching Capabilities**: Enhance performance with client-side caching of secrets.
- **NuGet Package**: Easily integrated into your .NET projects via NuGet.

## What You'll Learn

Throughout this tutorial, you will master how to:

1.  **Set up a .NET project** (Console Application) and install the KSM SDK.
2.  **Authenticate your application** with Keeper using a One-Time Token or a stored configuration.
3.  **Retrieve secrets**: Fetch all shared secrets, specific records by UID or title, and access individual field values (standard and custom).
4.  **Create new records** with various field types and file attachments.
5.  **Implement best practices** for using the SDK, including in-memory configuration for secure and flexible deployments.

## Prerequisites

-   Basic understanding of C# and .NET programming.
-   .NET SDK installed (this tutorial assumes .NET 8, but principles apply to other supported versions).
-   A Keeper Business or Enterprise account with the Secrets Manager add-on enabled.
-   **Crucial**: For this learning environment, please use a **test Keeper account or non-production credentials**. Avoid using your live production secrets.

## Security Best Practices Reminder

-   **Centralize Secrets**: Avoid hardcoding secrets. Store them in Keeper and retrieve them at runtime.
-   **Least Privilege**: Grant your KSM application only the necessary permissions to the secrets it needs.
-   **Secure Configuration**: Protect your KSM configuration file (`ksm-config.json`) with restrictive file permissions if used, or prefer in-memory configuration via environment variables in production.
-   **Audit Regularly**: Utilize Keeper's audit logs to monitor secret access by your applications.

Let's get started with setting up your .NET project and connecting it to Keeper Secrets Manager!
