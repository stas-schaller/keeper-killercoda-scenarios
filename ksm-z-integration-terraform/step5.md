Create and navigate to the new folder where we will place new Terraform configuration file

`mkdir ~/mysql-example && cd ~/mysql-example`{{execute}}

Create Terraform configuration file

<pre class="file" data-filename="mysql-example/main.tf" data-target="replace">
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.15.0"
    }

    keeper = {
      source  = "github.com/keeper-security/keeper"
      version = ">= 0.1.0"
    }
  }
}

# Configure the docker provider
provider "docker" {}

provider "keeper" {
  # This is where KSM's configuration file will be injected securely. It is up to the user
  # to properly secure this configuration string or file and inected it securely.
  credential = "[CONFING BASE64]"
  # credential = file("~/.keeper/credential")
}

data "keeper_secret_login" "tf_mysql" {
  path       = "[LOGIN RECORD UID]" 
}

# Create a docker image resource
# -> same as 'docker pull mysql:latest'
resource "docker_image" "mysql" {
  name         = "mysql:latest"
  keep_locally = true
}

# Create a docker container resource
# -> same as 'docker run --name mysql -e MYSQL_ROOT_PASSWORD=[PASSWORD FROM KEEPER RECORD]} -p3306:3306 -d mysql:latest'
resource "docker_container" "mysql" {
  name    = "mysql"
  image   = docker_image.mysql.latest
  env     = ["MYSQL_ROOT_PASSWORD=${data.keeper_secret_login.tf_mysql.password}"]

  ports {
    external = 3306
    internal = 3306
  }
}

</pre>

Initialize and apply Terraform Configuration
`terraform init && terraform apply`{{execute}}

In order to connect to MySQL, we need to install MySQL Client

`apt install -y mysql-client-core-5.7`{{execute}}

Connect to MySQL:

`mysql -h 127.0.0.1 -P 3306 --protocol=tcp -p`{{execute}}

Enter your password from Keeper's record in the CLI prompt.

Once connected to MySQL server you should see

```bash
mysql>
```

To exit from MySQL shell just type `exit;`{{execute}}

Now, try to change password to the db in Keeper and re-apply the changes by executing `terraform apply`{{execute}} and then connect to the MySQL
`mysql -h 127.0.0.1 -P 3306 --protocol=tcp -p`{{execute}}
and enter new password
