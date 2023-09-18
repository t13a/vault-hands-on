variable "htpasswd_password" {
  type      = string
  sensitive = true
}

variable "htpasswd_username" {
  type = string
}

variable "vault_kv_path" {
  type = string
}
