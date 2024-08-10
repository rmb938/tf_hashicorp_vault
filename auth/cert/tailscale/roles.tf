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
  token_policies       = concat(["default"], [for tag in each.value.tags : "ts_${trimprefix(tag, "tag:hvpolicy-")}" if startswith(tag, "tag:hvpolicy-")])
  token_bound_cidrs    = concat([for ip in each.value.addresses : "${ip}/32" if strcontains(ip, ".")], [for ip in each.value.addresses : "${ip}/128" if strcontains(ip, ":")])
}
