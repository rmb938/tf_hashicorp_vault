resource "vault_cert_auth_backend_role" "hashi_consule_server" {
  name = "hashi_console_server"

  certificate = file("${path.module}/smallstep-homelab-prod.crt")

  backend = backend.path
  allowed_common_names = [
    "consul-server-1.us-homelab1.hl.rmb938.me",
    "consul-server-2.us-homelab1.hl.rmb938.me",
    "consul-server-3.us-homelab1.hl.rmb938.me",
  ]
  display_name   = "hashi_console_server"
  token_policies = ["step_default", "step_hashi_console_server"]
  token_bound_cidrs = [
    "192.168.23.55/32",
    "192.168.23.56/32",
    "192.168.23.57/32"
  ]
}
