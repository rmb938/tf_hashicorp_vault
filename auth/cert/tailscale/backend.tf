resource "vault_auth_backend" "cert" {
  path = "tailscale-cert"
  type = "cert"
}
