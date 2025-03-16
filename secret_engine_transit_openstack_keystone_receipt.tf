resource "vault_mount" "transit_openstack_keystone_receipt" {
  path = "transit_openstack_keystone_receipt"
  type = "transit"

  lifecycle {
    prevent_destroy = true
  }
}

resource "vault_transit_secret_backend_key" "transit_openstack_keystone_receipt" {
  backend = vault_mount.transit_openstack_keystone_receipt.path
  name    = "receipt"

  type             = "ecdsa-p256"
  deletion_allowed = false

  exportable             = false
  allow_plaintext_backup = false

  # min_decryption_version = 0
  min_encryption_version = 0

  auto_rotate_period = "7776000" # 90 days

  lifecycle {
    prevent_destroy = true
  }
}
