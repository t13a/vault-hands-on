terraform {
  required_version = ">= 1.5.0"
  required_providers {
    kubernetes = ">= 2.23.0"
    vault      = ">= 3.18.0"
  }
}

resource "vault_policy" "this" {
  name = format("%s-cert-manager", var.vault_pki_path)
  policy = templatefile("${path.module}/policy.hcl", {
    pki_path = var.vault_pki_path
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

resource "kubernetes_manifest" "issuer" {
  provider = kubernetes
  manifest = {
    apiVersion : "cert-manager.io/v1"
    kind : "Issuer"
    metadata : {
      name : var.vault_pki_path
      namespace : var.kube_namespace
    }
    spec : {
      vault : {
        server : var.vault_server
        path : format("%s/sign/%s", var.vault_pki_path, var.vault_pki_role_name)
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