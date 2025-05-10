
resource "vault_kv_secret" "openstack_keystone_project_provider_user_provider-tf" {
  path = "${vault_mount.secret.path}/openstack-keystone/expected-project-users/project_provider_user_provider-tf"
  data_json = jsonencode({
    project  = "provider"
    username = "provider-tf"

    # Need to be admin to create public images and provider networks
    # Having just the admin role in any project automatically makes the
    # user global admin.
    # See: https://bugs.launchpad.net/keystone/+bug/968696
    role = "admin"
  })

  depends_on = [vault_mount.secret]
}


resource "vault_kv_secret" "openstack_keystone_project_application-platform_user_platform-tf" {
  path = "${vault_mount.secret.path}/openstack-keystone/expected-project-users/project_application-platform_user_platform-tf"
  data_json = jsonencode({
    project  = "application-platform"
    username = "platform-tf"
  })

  depends_on = [vault_mount.secret]
}
