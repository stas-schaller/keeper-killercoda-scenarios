# Keeper Secrets Manager Terraform Provider Tutorial

Welcome to the Keeper Secrets Manager (KSM) Terraform Provider Tutorial! This guide will walk you through integrating KSM into your Terraform configurations for secure and automated secret management within your infrastructure as code (IaC) workflows.

## What is the KSM Terraform Provider?

The Keeper Secrets Manager Terraform Provider allows you to seamlessly and securely access and manage secrets stored in your Keeper Vault directly from your Terraform code. It provides a robust, zero-knowledge interface to protect your sensitive data like API keys, database passwords, certificates, private keys, and more, ensuring they are not hardcoded into your configurations or state files.

### Key Features:
- **Zero-Knowledge Encryption**: Secrets are fetched and utilized in a way that aligns with Keeper's zero-knowledge principles. Sensitive values can be marked as such in Terraform outputs.
- **Versatile Configuration**: Supports initialization via KSM configuration (JSON or Base64 encoded string).
- **Comprehensive Secret Management**:
    - **Data Sources**: Read existing secrets (specific types like `login`, `password`, or generic `record`), record fields, files, and folder information.
    - **Resources**: Create, update, and delete various types of secrets (e.g., `login`, `password`, `note`, and many other standard record types), manage folders, and upload files.
- **Infrastructure as Code (IaC)**: Manage your secrets' lifecycle alongside your infrastructure resources, promoting consistency and auditability.
- **Automation**: Ideal for CI/CD pipelines and automated infrastructure provisioning, ensuring that applications and services receive the secrets they need securely and without manual intervention.
- **HashiCorp Terraform Registry**: Officially available on the Terraform Registry for easy integration (`keeper-security/secretsmanager`).

## What You'll Learn

By the end of this tutorial, you will be able to:

1.  **Set up your Terraform environment** to use the Keeper Secrets Manager provider.
2.  **Authenticate** the provider with your Keeper Secrets Manager application.
3.  **Retrieve secrets**:
    - Fetch specific record types (e.g., login records).
    - Use the generic data source to fetch any record type.
    - Access various field types (standard, custom, notes) and file attachment details.
4.  **Create new secrets** (e.g., login records) and manage their lifecycle using Terraform.
5.  **Update and delete** secrets managed by Terraform.
6.  **Manage folders**: List existing folders and create new folders.
7.  **Manage files**: Upload files and attach them to records.
8.  **Implement advanced use cases**, such as providing secrets to other Terraform resources (e.g., Docker containers).
9.  **Clean up** resources managed by Terraform.

## Prerequisites

-   Basic understanding of Terraform concepts and HCL (HashiCorp Configuration Language).
-   Terraform CLI installed.
-   A Keeper Business or Enterprise account with the Keeper Secrets Manager add-on enabled.
-   An existing KSM Application created in your Keeper Vault, along with its configuration (One-Time Token for initial setup, or the Base64/JSON configuration string).
-   Familiarity with how to obtain record UIDs and folder UIDs from your Keeper Vault (e.g., via Web Vault or Keeper Commander).
-   **Important**: For this tutorial, ensure you use a **test Keeper account or test credentials and a dedicated KSM application**. Never use your production secrets or infrastructure for learning exercises unless in a properly isolated environment.

## Security Best Practices Reminder

-   **Provider Configuration**: Securely manage your KSM provider `credential`. For production, consider using environment variables or other secure methods to inject the Base64 configuration string, rather than hardcoding it.
-   **Sensitive Outputs**: Mark any Terraform outputs that expose secret values as `sensitive = true`.
-   **Least Privilege**: Ensure the KSM Application used by Terraform has only the necessary permissions (e.g., access to specific shared folders or record types).
-   **State File Security**: Terraform state files can potentially contain sensitive data, even if variables are marked as sensitive. Secure your Terraform state (e.g., using Terraform Cloud or other secure backends with encryption at rest).
-   **Review Plans**: Always review `terraform plan` output carefully before applying changes, especially when dealing with secret resources.

Let's get started by setting up your Terraform project and connecting to Keeper Secrets Manager!