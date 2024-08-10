resource "vault_mount" "secret" {
  path = "secret"
  type = "kv"
  options = {
    version = "2"
  }
}

resource "vault_kv_secret_backend_v2" "example" {
  mount        = vault_mount.secret.path
  max_versions = 5
}
