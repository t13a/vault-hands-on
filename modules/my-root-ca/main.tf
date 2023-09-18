terraform {
  required_version = ">= 1.5.0"
  required_providers {
    local = ">= 2.4.0"
    tls   = ">= 4.0.0"
  }
}

resource "tls_private_key" "this" {
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "this" {
  allowed_uses = [
    "cert_signing",
    "client_auth",
    "crl_signing",
    "ocsp_signing",
    "server_auth"
  ]
  private_key_pem       = tls_private_key.this.private_key_pem
  validity_period_hours = var.ttl_seconds / 60 / 60
  is_ca_certificate     = true
  subject {
    common_name = var.common_name
  }
}

resource "local_file" "this" {
  content  = tls_self_signed_cert.this.cert_pem
  filename = "${path.root}/.my-root-ca/ca.crt"
}
