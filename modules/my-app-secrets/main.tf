terraform {
  required_version = ">= 1.5.0"
  required_providers {
    htpasswd = {
      source  = "loafoe/htpasswd"
      version = ">= 1.0.0"
    }
    vault  = ">= 3.18.0"
  }
}

resource "htpasswd_password" "basic_auth" {
  password = var.htpasswd_password
}

resource "vault_kv_secret_v2" "basic_auth" {
  mount = var.vault_kv_path
  name  = "my-app-basic-auth"
  data_json = jsonencode({
    auth = "${var.htpasswd_username}:${htpasswd_password.basic_auth.bcrypt}"
  })
}
