terraform {
  required_version = ">= 1.5.0"
  required_providers {
    vault = ">= 3.18.0"
  }
}

resource "vault_mount" "kv" {
  path    = var.vault_kv_path
  type    = "kv"
  options = { version = "2" }
}
