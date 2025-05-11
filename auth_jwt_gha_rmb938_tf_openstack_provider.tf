resource "vault_policy" "gha_rmb938_tf_openstack_provider" {
  name = "gha_rmb938_tf_openstack_provider"

  policy = <<EOT
path "auth/token/create" {
  capabilities = ["update"]
}

path "secret/openstack-keystone/project-users/project_provider_user_provider-tf" {
  capabilities = ["read"]
}
EOT
}

resource "vault_jwt_auth_backend_role" "gha_rmb938_tf_openstack_provider" {
  backend   = "jwt-gha"
  role_name = "gha_rmb938_tf_openstack_provider"

  user_claim      = "repository"
  bound_audiences = ["https://github.com/rmb938"]
  role_type       = "jwt"
  token_policies  = ["default", vault_policy.gha_rmb938_tf_openstack_provider.name]
  token_ttl       = "3600" # 1h
  bound_claims = {
    repository_id = "981676403"
  }
}
