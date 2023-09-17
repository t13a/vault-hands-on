# variable "kubernetes_provider_args" {
#   type = object({
#     config_path = string
#   })
# }

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

# variable "vault_provider_args" {
#   type = object({
#     address = string
#     token = string
#   })
#   sensitive = true
# }

variable "vault_server" {
  type = string
}
