output "vault_pki_path" {
  value = vault_mount.this.path
}

output "vault_pki_role_name" {
  value = vault_pki_secret_backend_role.domain.name
}