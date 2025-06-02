### Step 5: Advanced Integration, State Sync & Cleanup

This final step explores how KSM secrets integrate with other Terraform resources, how Terraform state synchronizes with out-of-band changes, and the proper way to clean up resources managed by Terraform.

**A. Integrating KSM Secrets with Other Terraform Resources (Docker Example)**

A primary use case for KSM is to provide secrets to other infrastructure components. This example demonstrates fetching a MySQL password from Keeper and using it to configure a Docker container running MySQL.

**Prerequisites for this part:**
- Docker installed and running on your Katacoda environment (or local machine).
- A Keeper Login record containing a MySQL root password, with its UID available.

Create a new `main.tf` (or clear your existing one) for this example:

```terraform
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker" # Community Docker provider
      version = "~> 2.15"            # Specify a compatible version
    }
    secretsmanager = {
      source  = "keeper-security/secretsmanager"
      version = ">= 1.0.0" # Use your desired KSM provider version
    }
  }
}

# Configure the Docker provider (usually defaults are fine for local Docker)
provider "docker" {}

# Configure the Keeper Secrets Manager provider
provider "secretsmanager" {
  credential = "[CONFIG JSON or BASE64]" # Replace with your KSM config
}

# Data source to fetch the MySQL login record from Keeper
data "secretsmanager_login" "mysql_root_creds" {
  path = "[UID_OF_MYSQL_LOGIN_RECORD]" # Replace with your MySQL Login Record UID
}

# Docker image resource for MySQL
resource "docker_image" "mysql_image" {
  name         = "mysql:8.0" # Using MySQL 8.0 image
  keep_locally = true       # Keep the image cached locally
}

# Docker container resource for MySQL
resource "docker_container" "mysql_server" {
  name  = "tf-mysql-server"
  image = docker_image.mysql_image.latest
  
  # Inject the password from Keeper into the container's environment variables
  env = [
    "MYSQL_ROOT_PASSWORD=${data.secretsmanager_login.mysql_root_creds.password}",
    "MYSQL_DATABASE=mydatabase", # Example: create a default database
  ]

  ports {
    internal = 3306
    external = 3306 # Map container port 3306 to host port 3306
  }
}

output "mysql_container_name" {
  description = "Name of the deployed MySQL container."
  value       = docker_container.mysql_server.name
}

output "mysql_root_password_source" {
  description = "Source of the MySQL root password (should be from Keeper)."
  value       = "Fetched from Keeper Secrets Manager (UID: ${data.secretsmanager_login.mysql_root_creds.path})"
  sensitive   = false # The actual password is not output here, just its source info
}
```{{copy}}

**Instructions for Docker Integration:**

1.  Replace `[CONFIG JSON or BASE64]` and `[UID_OF_MYSQL_LOGIN_RECORD]` in `main.tf`.
2.  Initialize Terraform: `terraform init`{{execute}}
3.  Apply the configuration: `terraform apply -auto-approve`{{execute}}
    This will pull the MySQL image (if not present) and start a Docker container with the root password set from Keeper.
4.  To verify (optional, requires MySQL client):
    `apt update && apt install -y mysql-client`{{execute}}
    Connect to MySQL (password will be the one from your Keeper record):
    `mysql -h 127.0.0.1 -P 3306 --protocol=tcp -u root -p`{{execute}}
    Enter password when prompted. Type `exit` to leave MySQL shell.

**B. Understanding State Synchronization**

Terraform maintains a state file (`terraform.tfstate` by default) that records the resources it manages and their current known state. What happens if a secret is changed in Keeper *outside* of Terraform?

1.  **External Change**: After applying the above Docker example, go to your Keeper Vault and change the password for the MySQL record that `[UID_OF_MYSQL_LOGIN_RECORD]` points to.
2.  **Check Terraform Plan**: Run `terraform plan`{{execute}} in the same directory.
    -   **Data Sources**: For data sources like `secretsmanager_login`, Terraform will typically read the *current* value from Keeper during the plan/apply phase. If the value (like the password) is used in a resource attribute that would cause a change (e.g., restarting a container due to an environment variable change), the plan will show this intended change.
    -   **Resources**: If you manage a secret record as a `resource` (e.g., `secretsmanager_login` resource from Step 3) and its value is changed externally, `terraform plan` will detect this drift. It will propose to revert the change to match your Terraform configuration, as Terraform sees your HCL code as the source of truth for resources it manages.
3.  **Apply (if needed)**: If the plan shows changes due to the external update (e.g., the Docker container needs to be updated with the new password), you can run `terraform apply -auto-approve`{{execute}} to reconcile.

This demonstrates that for data sources, Terraform fetches fresh data. For resources, Terraform enforces the configuration unless you explicitly update the configuration or import the changes.

**C. Cleaning Up Resources**

After you are done experimenting with the resources created by Terraform in this tutorial (records, folders, files, Docker containers, etc.), it's crucial to clean them up to avoid unintended ongoing services or charges (if applicable to the resources).

The `terraform destroy` command is used to remove all resources managed by the current Terraform configuration.

**Instructions for Cleanup:**

1.  Navigate to the directory containing your `main.tf` file that manages the resources you want to delete.
2.  Execute the destroy command:
    `terraform destroy -auto-approve`{{execute}}
    The `-auto-approve` flag skips the confirmation prompt. Omit it if you want to review what will be destroyed before confirming.
3.  Terraform will now delete all resources defined in your configuration from the respective providers (Keeper, Docker, etc.).
4.  Verify in your Keeper Vault and Docker environment that the resources have been removed.

This cleanup process is vital for any Terraform workflow to ensure a tidy environment and manage costs effectively.

This concludes the comprehensive tutorial on the Keeper Secrets Manager Terraform Provider! You should now have a solid foundation for securely managing your Keeper secrets as part of your Infrastructure as Code practices. 