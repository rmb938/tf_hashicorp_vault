resource "vault_cert_auth_backend_role" "hashi_consul" {
  name = "hashi_consul"

  certificate = file("${path.module}/smallstep-homelab-prod.crt")

  backend = var.backend.path
  allowed_common_names = [
    "hashi-consul-1.us-homelab1.hl.rmb938.me",
    "hashi-consul-2.us-homelab1.hl.rmb938.me",
    "hashi-consul-3.us-homelab1.hl.rmb938.me",
  ]
  display_name   = "hashi_consul"
  token_policies = ["step_default", "step_hashi_consul"]
  token_bound_cidrs = [
    "192.168.23.55/32",
    "192.168.23.56/32",
    "192.168.23.57/32"
  ]
}
