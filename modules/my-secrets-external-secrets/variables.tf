variable "kube_namespace" {
  type    = string
  default = "default"
}

variable "vault_approle_path" {
  type = string
}

variable "vault_kv_path" {
  type = string
}

variable "vault_server" {
  type = string
}
