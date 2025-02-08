resource "vault_auth_backend" "cert" {
  path = "step-cert"
  type = "cert"
}
