data "tailscale_devices" "devices" {}

locals {
  tailscale_servers = toset([for each in data.tailscale_devices.devices.devices : each if contains(each.tags, "servers")])
}

resource "vault_cert_auth_backend_role" "cert" {
  name                 = "foo"
  certificate          = file("${path.module}/le_isrg_root_x2.pem")
  backend              = vault_auth_backend.cert.path
  allowed_common_names = ["woo.tailnet-047c.ts.net"]
  display_name         = "tailscale_machine_woo"
  token_policies       = ["default"]
  token_bound_cidrs    = ["1.1.1.1"]
}
