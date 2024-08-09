data "tailscale_devices" "devices" {}

locals {
  tailscale_servers = {
    for each in data.tailscale_devices.devices.devices : each.name => each if contains(each.tags, "tag:servers")
  }
}

resource "vault_cert_auth_backend_role" "tailscale_server_role" {
  for_each = local.tailscale_servers

  name                 = each.value.name
  certificate          = file("${path.module}/le_isrg_root_x2.pem")
  backend              = vault_auth_backend.cert.path
  allowed_common_names = [each.value.name]
  display_name         = each.value.name
  token_policies       = concat(["default"], [for tag in "ts_${trimprefix(each.value.tags, "hvpolicy-")}" : tag if startswith(tag, "hvpolicy-")])
  token_bound_cidrs    = each.value.addresses
}
