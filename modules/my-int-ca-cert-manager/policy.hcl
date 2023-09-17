path "${pki_path}/*" {
  capabilities = ["read", "list"]
}

path "${pki_path}/sign/*" {
  capabilities = ["create", "update"]
}

path "${pki_path}/issue/*" {
  capabilities = ["create"]
}
