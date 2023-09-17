variable "kubernetes_config_path" {
  type = string
}

variable "vault_address" {
  type = string
}

variable "vault_server" {
  type    = string
  default = "http://vault.default:8200"
}

variable "vault_token" {
  type = string
}
