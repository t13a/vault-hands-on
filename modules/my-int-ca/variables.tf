variable "common_name" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "issuer_name" {
  type = string
}

variable "max_lease_ttl_seconds" {
  type = number
}

variable "root_ca_cert_pem" {
  type = string
}

variable "root_ca_private_key_pem" {
  type = string
}

variable "ttl_seconds" {
  type = number
}
