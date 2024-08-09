resource "vault_auth_backend" "cert" {
  path = "tailscale_cert"
  type = "cert"
}
