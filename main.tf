terraform {
  required_version = ">= 1.5.0"
  required_providers {
    kubernetes = ">= 2.23.0"
    vault      = ">= 3.18.0"
  }
}

provider "kubernetes" {
  config_path = var.kubernetes_config_path
}

provider "vault" {
  address = var.vault_address
  token   = var.vault_token
}

module "vault" {
  source = "./modules/vault"
}

module "my_root_ca" {
  source      = "./modules/my-root-ca"
  common_name = "My Root CA"
  ttl_seconds = 60 * 60 * 24 * 365 * 10 # 10 years
}

module "my_int_ca" {
  source                  = "./modules/my-int-ca"
  common_name             = "My Intermediate CA"
  domain_name             = "my.example"
  issuer_name             = "my-int-ca"
  max_lease_ttl_seconds   = 60 * 60 * 24 * 90 # 90 days
  root_ca_cert_pem        = module.my_root_ca.cert_pem
  root_ca_private_key_pem = module.my_root_ca.private_key_pem
  ttl_seconds             = 60 * 60 * 24 * 365 # 1 years
}

module "my_int_ca_cert_manager" {
  source              = "./modules/my-int-ca-cert-manager"
  vault_approle_path  = module.vault.approle_path
  vault_pki_path      = module.my_int_ca.vault_pki_path
  vault_pki_role_name = module.my_int_ca.vault_pki_role_name
  vault_server        = var.vault_server
}

module "my_secrets" {
  source        = "./modules/my-secrets"
  vault_kv_path = "my-secrets"
}

module "my_secrets_external_secrets" {
  source             = "./modules/my-secrets-external-secrets"
  vault_approle_path = module.vault.approle_path
  vault_kv_path      = module.my_secrets.vault_kv_path
  vault_server       = var.vault_server
}

module "my_app_secrets" {
  source            = "./modules/my-app-secrets"
  htpasswd_password = "12345"
  htpasswd_username = "alice"
  vault_kv_path     = module.my_secrets.vault_kv_path
}
