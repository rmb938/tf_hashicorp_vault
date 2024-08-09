resource "vault_cert_auth_backend_role" "cert" {
  name                 = "foo"
  certificate          = file("${path.module}/le_isrg_root_x2.pem")
  backend              = vault_auth_backend.cert.path
  allowed_common_names = ["woo.tailnet-047c.ts.net"]
  display_name         = "tailscale_machine_woo"
  token_policies       = ["default"]
  token_bound_cidrs    = ["1.1.1.1"]
}
