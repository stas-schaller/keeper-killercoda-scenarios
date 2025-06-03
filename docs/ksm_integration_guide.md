# KSM Integration Technical Guide for Assistants

This guide provides essential technical information about Keeper Secrets Manager (KSM) and its integrations. It is intended to assist in building and updating Killercoda tutorials accurately and effectively.

## 1. KSM Application Permissions - CRITICAL CORRECTION

It is crucial to understand the permission model for KSM Applications used in integrations (CLI, SDKs, Actions, Plugins):

*   **Scope of Access**: KSM Applications gain access to secrets by being **shared to specific Shared Folders or individual Records** within the Keeper Vault.
*   **Available Permissions**: For a KSM Application shared to a record or folder, the primary permissions are:
    *   **View Record (Read-Only)**: Allows the application to read secrets, fields, custom fields, and file attachments.
    *   **Edit Record (Read-Write)**: Allows the application to read *and also modify* secrets, fields, and custom fields. This permission is necessary for actions like PowerShell's `Set-Secret` or Terraform's resource management (create/update/delete).
*   **"Share" Permission Inapplicable**: The "Share" permission (and managing users/sharing) is a user-level concept within the Keeper Vault. **KSM Applications themselves do not "share" records with other users or KSM applications in the context of these integrations.** They are service identities for programmatic access.
*   **Least Privilege Principle**: When instructing users or writing tutorial content:
    *   Emphasize sharing KSM Applications *only* to the necessary Shared Folders or individual Records required for the integration's task.
    *   Advise granting **"View Record"** by default.
    *   Only advise granting **"Edit Record"** if the integration explicitly needs to create, update, or delete secrets (e.g., `terraform apply` to create a `secretsmanager_login` resource, or `Set-Secret` in PowerShell).
    *   **Incorrect Statement Example (to avoid)**: "Ensure the KSM application ... only has the minimum necessary permissions (view, edit)..."

## 2. KSM Configuration

*   **Formats**: KSM configurations for applications are typically provided as a JSON string or a Base64 encoded version of that JSON.
*   **Storage/Access**: Integrations use various methods to access this configuration:
    *   **Environment Variable**: Common for CLI, SDKs, and CI/CD. Standard names include `KSM_CONFIG` (for JSON) or `KEEPER_SECRETS_MANAGER_CONFIG_BASE64`.
    *   **Local File**: CLI and SDKs can often read from a local file (e.g., `ksm-config.json`).
    *   **Platform-Specific Secret Stores**: CI/CD systems like GitHub Actions and GitLab CI/CD use their own secret storage mechanisms for the KSM config string. PowerShell uses its SecretManagement framework to store the KSM config securely locally.
*   **Tutorial Guidance**: Emphasize secure storage of this configuration string (e.g., as a protected/masked CI/CD variable).

## 3. Keeper Notation (UIDs & Paths)

*   **General Format**: `keeper://RECORD_UID/FIELD_TYPE/FIELD_LABEL_OR_TITLE`
*   **FIELD_TYPE**: Can be `field` (for standard fields), `custom_field` (for custom fields), or `file`.
*   **FIELD_LABEL_OR_TITLE**: For `field`, it's the standard field type (e.g., `password`, `url`, `login`). For `custom_field`, it's the custom field's label/name. For `file`, it's the filename (e.g., `myconfig.json`).
*   **Placeholders**: In tutorials, always use clear placeholders like `[RECORD_UID]`, `[FIELD_NAME]`, `[FILENAME.EXT]` and instruct users to replace them.
*   **PowerShell Specifics**: The Keeper PowerShell plugin uses a simplified dot notation *within its cmdlets* (e.g., `"RECORD_TITLE.password"` or `"RECORD_TITLE.custom_field_APIKey"` or `"RECORD_TITLE.files[FILENAME.EXT]"`). The `keeper://` prefix is not used directly in these cmdlet parameters.
*   **Escaping**: For PowerShell, if record titles or field names contain `.` or `\`, they must be escaped with a `\` (e.g., `server\.address` for a field named "server.address").

## 4. Integration Types & Tooling

*   **KSM CLI (`ksm`)**: Cross-platform command-line tool. Requires Python. Installed via `pip install keeper-secrets-manager-cli`. Used directly in scripts (shell, GitLab CI, etc.).
*   **Developer SDKs**: For various languages (Python, Java, JS, .NET, Go). Used for programmatic integration into custom applications.
*   **Platform-Specific Plugins/Actions**: These provide a more abstracted or native experience on certain platforms:
    *   **GitHub Actions**: `Keeper-Security/ksm-action@version`.
    *   **GitLab CI/CD**: Uses KSM CLI directly within `.gitlab-ci.yml` (`before_script` for install, `script` for usage).
    *   **PowerShell**: `SecretManagement.Keeper` module for PowerShell Gallery. Integrates with `Microsoft.PowerShell.SecretManagement`.
    *   **Terraform**: `keeper-security/secretsmanager` provider from Terraform Registry.
*   **Tutorial Focus**: Ensure the tutorial uses the correct tool and terminology for the specific integration being taught.

## 5. Common Setup Steps in Killercoda

*   **Installation Scripts (`install-X.sh`)**: Used in `courseData` for global setup or `script` for step setup.
    *   Start with `#!/bin/bash`.
    *   Use `apt-get update -y` and `apt-get install -y [packages]` for Ubuntu.
    *   Use `echo` for progress.
    *   **Command Structure**: Prefer chaining commands into one-liners (e.g., using `&&`) where possible. Killercoda sometimes has issues with the execution of multi-line commands or complex script logic within these setup scripts.
    *   End with `echo "done" >> /opt/.backgroundfinished` for Killercoda step synchronization if it's a background setup script.
*   **PowerShell Environment**: If PowerShell 6+ is needed, the `install-powershell-ubuntu.sh` script (using Microsoft's official repo) is standard. The script should end with `pwsh` to drop the user into the correct shell.

## 6. General Tutorial Content Notes

*   **Prerequisites**: Clearly list all necessary accounts, tools, and permissions.
*   **Placeholders**: Use consistent and obvious placeholders (e.g., `[YOUR_UID]`, `[REPLACE_WITH_YOUR_TOKEN]`).
*   **Security Best Practices**: Include notes on secure KSM config storage, least privilege for KSM app permissions, and avoiding logging raw secrets.
*   **Error States/Troubleshooting**: Briefly mention common issues (e.g., incorrect token, insufficient KSM app permissions, network issues, wrong notation).
*   **Official Documentation Links**: Always provide links to the relevant official Keeper documentation as the authoritative source.

By keeping these points in mind, assistants can create more accurate, secure, and helpful KSM integration tutorials. 