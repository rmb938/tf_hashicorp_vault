resource "vault_kv_secret" "openstack_keystone_service_user_cinder" {
  path = "${vault_mount.secret.path}/openstack-keystone/expected-service-users/cinder"
  data_json = jsonencode({
    foo = "bar"
  })

  depends_on = [vault_mount.secret]
}

resource "vault_kv_secret" "openstack_keystone_service_user_glance" {
  path = "${vault_mount.secret.path}/openstack-keystone/expected-service-users/glance"
  data_json = jsonencode({
    foo = "bar"
  })

  depends_on = [vault_mount.secret]
}


resource "vault_kv_secret" "openstack_keystone_service_user_neutron" {
  path = "${vault_mount.secret.path}/openstack-keystone/expected-service-users/neutron"
  data_json = jsonencode({
    foo = "bar"
  })

  depends_on = [vault_mount.secret]
}

resource "vault_kv_secret" "openstack_keystone_service_user_neutron_compute" {
  path = "${vault_mount.secret.path}/openstack-keystone/expected-service-users/neutron-compute"
  data_json = jsonencode({
    foo = "bar"
  })

  depends_on = [vault_mount.secret]
}

resource "vault_kv_secret" "openstack_keystone_service_user_placement" {
  path = "${vault_mount.secret.path}/openstack-keystone/expected-service-users/placement"
  data_json = jsonencode({
    foo = "bar"
  })

  depends_on = [vault_mount.secret]
}

resource "vault_kv_secret" "openstack_keystone_service_user_nova_controller" {
  path = "${vault_mount.secret.path}/openstack-keystone/expected-service-users/nova-controller"
  data_json = jsonencode({
    foo = "bar"
  })

  depends_on = [vault_mount.secret]
}

resource "vault_kv_secret" "openstack_keystone_service_user_nova_compute" {
  path = "${vault_mount.secret.path}/openstack-keystone/expected-service-users/nova-compute"
  data_json = jsonencode({
    foo = "bar"
  })

  depends_on = [vault_mount.secret]
}

resource "vault_kv_secret" "openstack_keystone_service_user_octavia" {
  path = "${vault_mount.secret.path}/openstack-keystone/expected-service-users/octavia"
  data_json = jsonencode({
    foo = "bar"
  })

  depends_on = [vault_mount.secret]
}
