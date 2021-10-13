
<pre class="file" data-filename="main.tf" data-target="replace">
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    keeper = {
      source  = "github.com/keeper-security/keeper"
      version = ">= 0.1.0"
    }
  }
}

provider "keeper" {
  credential = "[CONFIG JSON or BASE64]"
  # credential = file("~/.keeper/config.json")
}

data "keeper_secret_login" "kc-secret" {
  path       = "[UID TO LOGIN TYPE RECORD]" # QabbPIdM8Unw4hwVM-F8VQ
}

output "kc_secret_login" {
  value = data.keeper_secret_login.kc-secret.login
}

output "kc_secret_password" {
  value = data.keeper_secret_login.kc-secret.password
  sensitive = true
}
</pre>

## Replace credentials in main.tf file

## Inialize Terraform
`terraform init`{{execute}}

Execute Terraform steps
`terraform apply -auto-approve`{{execute}}

View terraform state file.
`terraform.tfstate`{{open}}

