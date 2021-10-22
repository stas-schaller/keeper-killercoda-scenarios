Wait for the Terraform to be installed

## Create local plugin folder
`mkdir -p ~/.terraform.d/plugins/github.com/keeper-security/keeper`{{execute}}

## Download KSM Terraform provider file
`wget https://github.com/Keeper-Security/terraform-provider-keeper/releases/download/v0.1.4/terraform-provider-keeper_0.1.4_linux_amd64.zip --directory-prefix ~/.terraform.d/plugins/github.com/keeper-security/keeper`{{execute}}

 > *Note: If you are installing this provider in your environment, make sure you are downloading provider for your environment. See list of available provider files [HERE](https://github.com/Keeper-Security/terraform-provider-keeper/releases)*
