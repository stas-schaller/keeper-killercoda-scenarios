
Create script file
`touch main.tf`{{execute}}


Open file in Editor:
`main.tf`{{open}}



<pre class="file" data-filename="main.tf" data-target="replace">
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    keeper = {
      source  = "github.com/keeper-security/keeper"
      version = ">= 0.1.0"
    }
    local = {
      source = "hashicorp/local"
      version = "2.1.0"
    }
  }
}

provider "local" { }
provider "keeper" {
  credential = "<CONFIG JSON or BASE64>"
  # credential = file("~/.keeper/credential")
}

data "keeper_secret_login" "kc-secret" {
  path       = "<UID TO LOGIN TYPE RECORD>"
}

resource "local_file" "out" {
    filename        = "${path.module}/out.txt"
    file_permission = "0644"
    content         = <<EOT
UID:    ${ data.keeper_secret_login.kc-secret.path }
Type:   ${ data.keeper_secret_login.kc-secret.type }
Title:  ${ data.keeper_secret_login.kc-secret.title }
Notes:  ${ data.keeper_secret_login.kc-secret.notes }
======

Login:    ${ data.keeper_secret_login.kc-secret.login }
Password: ${ data.keeper_secret_login.kc-secret.password }
URL:      ${ data.keeper_secret_login.kc-secret.url }

TOTP:
-----
%{ for t in data.keeper_secret_login.kc-secret.totp ~}
URL:    ${ t.url }
Token:  ${ t.token }
TTL:    ${ t.ttl }

%{ endfor ~}

FileRefs:
---------
%{ for fr in data.keeper_secret_login.kc-secret.file_ref ~}
UID:      ${ fr.uid }
Title:    ${ fr.title }
Name:     ${ fr.name }
Type:     ${ fr.type }
Size:     ${ fr.size }
Last Modified:  ${ fr.last_modified }
URL:            ${ fr.url }

Content/Base64: ${ fr.content_base64 }


%{ endfor ~}
EOT
}

output "db_secret_login" {
  value = data.keeper_secret_login.kc-secret.login
}
</pre>
