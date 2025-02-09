resource "vault_auth_backend" "auth_step_cert" {
  path = "step-cert"
  type = "cert"
}
