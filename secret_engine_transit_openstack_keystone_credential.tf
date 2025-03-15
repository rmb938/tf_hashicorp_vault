resource "vault_mount" "transit_openstack_keystone_credential" {
  path                      = "transit_openstack_keystone_credential"
  type                      = "transit"
  description               = "Example description"

  lifecycle {
    prevent_destroy = true
  }
}

resource "vault_transit_secret_backend_key" "transit_openstack_keystone_credential" {
  backend = vault_mount.transit_openstack_keystone_credential.path
  name    = "credential"

  type = "aes256-gcm96"
  deletion_allowed = false
  
  exportable = false
  allow_plaintext_backup = false

  min_decryption_version = 0
  min_encryption_version = 0

  auto_rotate_period = "168h" // 1 week

  lifecycle {
    prevent_destroy = true
  }
}