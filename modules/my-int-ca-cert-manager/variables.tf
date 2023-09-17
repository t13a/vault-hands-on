variable "kube_namespace" {
  type    = string
  default = "default"
}

variable "vault_approle_path" {
  type = string
}

variable "vault_pki_path" {
  type = string
}

variable "vault_pki_role_name" {
  type = string
}

variable "vault_server" {
  type = string
}
