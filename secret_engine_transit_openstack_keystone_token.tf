resource "vault_mount" "transit_openstack_keystone_token" {
  path = "transit_openstack_keystone_token"
  type = "transit"

  lifecycle {
    prevent_destroy = true
  }
}

resource "vault_transit_secret_backend_key" "transit_openstack_keystone_token" {
  backend = vault_mount.transit_openstack_keystone_token.path
  name    = "token"

  type             = "ecdsa-p256"
  deletion_allowed = false

  exportable             = false
  allow_plaintext_backup = false

  # min_decryption_version = 0
  min_encryption_version = 0

  auto_rotate_period = 604800 // 1 week

  lifecycle {
    prevent_destroy = true
  }
}
