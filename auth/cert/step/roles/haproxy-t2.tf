resource "vault_cert_auth_backend_role" "haproxy-t2" {
  name = "haproxy-t2"

  certificate = file("${path.module}/smallstep-homelab-prod.crt")

  backend = var.backend.path
  allowed_common_names = [
    "haproxy-t2-1.us-homelab1.hl.rmb938.me",
    "haproxy-t2-2.us-homelab1.hl.rmb938.me",
  ]
  display_name   = "haproxy-t2"
  token_policies = ["step_default", "step_haproxy-t2"]
  token_bound_cidrs = [
    "192.168.23.49/32",
    "192.168.23.50/32",
  ]
}
