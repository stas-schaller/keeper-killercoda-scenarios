
Create script file
`touch main.tf`{{execute}}


Open file in Editor:
`main.tf`{{open}}



<pre class="file" data-filename="main.tf" data-target="replace">
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    secretsmanager = {
      source  = "keeper-security/secretsmanager"
      version = ">= 1.0.0"
    }
    local = {
      source = "hashicorp/local"
      version = "2.1.0"
    }
  }
}

provider "local" { }
provider "secretsmanager" {
  credential = "<CONFIG JSON or BASE64>"
  # credential = file("~/.keeper/credential")
}

data "secretsmanager_login" "kc-secret" {
  path       = "<UID TO LOGIN TYPE RECORD>"
}

resource "local_file" "out" {
    filename        = "${path.module}/out.txt"
    file_permission = "0644"
    content         = <<EOT
UID:    ${ data.secretsmanager_login.kc-secret.path }
Type:   ${ data.secretsmanager_login.kc-secret.type }
Title:  ${ data.secretsmanager_login.kc-secret.title }
Notes:  ${ data.secretsmanager_login.kc-secret.notes }
======

Login:    ${ data.secretsmanager_login.kc-secret.login }
Password: ${ data.secretsmanager_login.kc-secret.password }
URL:      ${ data.secretsmanager_login.kc-secret.url }

TOTP:
-----
%{ for t in data.secretsmanager_login.kc-secret.totp ~}
URL:    ${ t.url }
Token:  ${ t.token }
TTL:    ${ t.ttl }

%{ endfor ~}

FileRefs:
---------
%{ for fr in data.secretsmanager_login.kc-secret.file_ref ~}
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
  value = data.secretsmanager_login.kc-secret.login
}
</pre>
