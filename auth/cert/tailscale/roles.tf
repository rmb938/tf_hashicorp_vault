data "tailscale_devices" "devices" {}

locals {
  tailscale_servers = {
    for each in data.tailscale_devices.devices.devices : each => {
      each.name : each
    }
  }
}

resource "null_resource" "tailscale_servers" {
  triggers = {
    value = jsonencode(local.tailscale_servers)
  }
}

resource "vault_cert_auth_backend_role" "tailscale_server_role" {
  for_each = { for name, device in local.tailscale_servers : name => device if contains(device.tags, "tag:servers") }

  name                 = each.value.name
  certificate          = file("${path.module}/le_isrg_root_x2.pem")
  backend              = vault_auth_backend.cert.path
  allowed_common_names = [each.value.name]
  display_name         = each.value.name
  token_policies       = ["default"]
  token_bound_cidrs    = each.value.addresses
}
