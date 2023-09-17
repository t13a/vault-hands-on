terraform {
  required_version = ">= 1.5.0"
  required_providers {
    vault = ">= 3.18.0"
  }
}

resource "vault_auth_backend" "approle" {
  type = "approle"
}
