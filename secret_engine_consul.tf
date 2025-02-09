resource "random_password" "consul_encrypt" {
  length      = 32
  special     = true
  min_lower   = 1
  min_upper   = 1
  min_special = 1
}

resource "vault_kv_secret" "consul_encrypt" {
  path = "${vault_mount.secret.path}/consul/encrypt_key"
  data_json = jsonencode(
    {
      key = base64encode(random_password.consul_encrypt.result)
    }
  )

  depends_on = [vault_mount.secret]

  lifecycle {
    prevent_destroy = true
  }
}

resource "random_password" "consul_management_token" {
  length      = 32
  special     = true
  min_lower   = 1
  min_upper   = 1
  min_special = 1
}

resource "vault_kv_secret" "consul_management_token" {
  path = "${vault_mount.secret.path}/consul/management_token"
  data_json = jsonencode(
    {
      key = base64encode(random_password.consul_management_token.result)
    }
  )

  depends_on = [vault_mount.secret]

  lifecycle {
    prevent_destroy = true
  }
}

resource "vault_consul_secret_backend" "consul" {
  path        = "consul"
  description = "Manages the Consul backend"

  # Only giving one consul server since HAProxy isn't setup yet.
  # We probably should use a keep-alived address eventually
  scheme  = "https"
  address = "hashi-consul-1.us-homelab1.hl.rmb938.me:8501"

  token = base64encode(random_password.consul_management_token.result)
}
