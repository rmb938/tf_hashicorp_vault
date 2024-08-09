data "tailscale_devices" "devices" {}

locals {
  tailscale_servers = toset([for each in data.tailscale_devices.devices.devices : each if contains(each.tags, "servers")])
}

resource "vault_cert_auth_backend_role" "cert" {
  for_each = local.tailscale_servers

  name                 = each.key.name
  certificate          = file("${path.module}/le_isrg_root_x2.pem")
  backend              = vault_auth_backend.cert.path
  allowed_common_names = [each.key.name]
  display_name         = each.key.name
  token_policies       = ["default"]
  token_bound_cidrs    = each.key.addresses
}
