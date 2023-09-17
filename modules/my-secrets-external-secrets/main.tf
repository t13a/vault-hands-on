terraform {
  required_version = ">= 1.5.0"
  required_providers {
    kubernetes = ">= 2.23.0"
    vault      = ">= 3.18.0"
  }
}

resource "vault_policy" "this" {
  name = format("%s-external-secrets", var.vault_kv_path)
  policy = templatefile("${path.module}/policy.hcl", {
    kv_path = var.vault_kv_path
  })
}

resource "vault_approle_auth_backend_role" "this" {
  backend        = var.vault_approle_path
  role_name      = vault_policy.this.name
  secret_id_ttl  = 0
  token_policies = [vault_policy.this.name]
}

resource "vault_approle_auth_backend_role_secret_id" "this" {
  backend   = vault_approle_auth_backend_role.this.backend
  role_name = vault_approle_auth_backend_role.this.role_name
}

resource "kubernetes_secret" "approle" {
  metadata {
    name      = format("%s-approle", vault_approle_auth_backend_role.this.role_name)
    namespace = var.kube_namespace
  }
  data = {
    "secret-id" = vault_approle_auth_backend_role_secret_id.this.secret_id
  }
}

resource "kubernetes_manifest" "secretstore" {
  manifest = {
    apiVersion : "external-secrets.io/v1beta1"
    kind : "SecretStore"
    metadata : {
      name : var.vault_kv_path
      namespace : var.kube_namespace
    }
    spec : {
      provider : {
        vault : {
          server : var.vault_server
          path : var.vault_kv_path
          version : "v2"
          auth : {
            appRole : {
              path : vault_approle_auth_backend_role.this.backend
              roleId : vault_approle_auth_backend_role.this.role_id
              secretRef : {
                name : kubernetes_secret.approle.metadata[0].name
                key : "secret-id"
              }
            }
          }
        }
      }
    }
  }
}