terraform {
  required_version = ">= 1.5.0"
  required_providers {
    tls   = ">= 4.0.0"
    vault = ">= 3.18.0"
  }
}

resource "vault_mount" "this" {
  path                      = var.issuer_name
  type                      = "pki"
  default_lease_ttl_seconds = var.max_lease_ttl_seconds
  max_lease_ttl_seconds     = var.max_lease_ttl_seconds
}

# XXX: work around for missing private key when `type = "internal"` is specified in `vault_pki_secret_backend_intermediate_cert_request`
resource "vault_pki_secret_backend_key" "this" {
  backend = vault_mount.this.path
  type    = "internal"
}

resource "vault_pki_secret_backend_intermediate_cert_request" "this" {
  backend     = vault_mount.this.path
  type        = "existing"
  common_name = var.common_name
  key_ref     = vault_pki_secret_backend_key.this.key_id
}

resource "tls_locally_signed_cert" "this" {
  allowed_uses = [
    "cert_signing",
    "client_auth",
    "crl_signing",
    "ocsp_signing",
    "server_auth"
  ]
  ca_cert_pem           = var.root_ca_cert_pem
  ca_private_key_pem    = var.root_ca_private_key_pem
  cert_request_pem      = vault_pki_secret_backend_intermediate_cert_request.this.csr
  validity_period_hours = var.ttl_seconds / 60 / 60
  is_ca_certificate     = true
}

resource "vault_pki_secret_backend_intermediate_set_signed" "this" {
  backend     = vault_mount.this.path
  certificate = join("", [tls_locally_signed_cert.this.cert_pem, tls_locally_signed_cert.this.ca_cert_pem])
}

resource "vault_pki_secret_backend_config_issuers" "this" {
  backend = vault_mount.this.path
  default = vault_pki_secret_backend_intermediate_set_signed.this.imported_issuers[0]
}

resource "vault_pki_secret_backend_role" "domain" {
  backend          = vault_mount.this.path
  name             = var.domain_name
  allowed_domains  = [var.domain_name]
  allow_subdomains = true
  server_flag      = true
  key_usage        = ["DigitalSignature", "KeyEncipherment"]
  ext_key_usage    = ["ServerAuth"]
  no_store         = true
  require_cn       = false
}
