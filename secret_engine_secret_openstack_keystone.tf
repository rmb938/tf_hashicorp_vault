resource "vault_kv_secret" "openstack_keystone_service_user_cinder" {
  path = "${vault_mount.secret.path}/openstack-keystone/expected-service-users/cinder"
  data_json = jsonencode({
    foo = "bar"
  })

  depends_on = [vault_mount.secret]
}
