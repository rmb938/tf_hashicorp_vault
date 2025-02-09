resource "vault_policy" "gha_rmb938_tf_hashicorp_vault_apps" {
  name = "gha_rmb938_tf_hashicorp_vault_apps"

  policy = <<EOT
path "secret/consul/management_token" {
  capabilities = ["read"]
}

path "auth/token/create" {
  capabilities = ["update"]
}

path "sys/policies/*" {
  capabilities = ["create", "read", "update", "delete"]
}

path "auth/step-cert/certs/*" {
  capabilities = ["create", "read", "update", "delete"]
}

path "consul/roles/*" {
  capabilities = ["create", "read", "update", "delete"]
}
EOT
}

resource "vault_jwt_auth_backend_role" "gha_rmb938_tf_hashicorp_vault_apps" {
  backend   = "jwt-gha"
  role_name = "gha_rmb938_tf_hashicorp_vault_apps"

  user_claim      = "repository"
  bound_audiences = ["https://github.com/rmb938"]
  role_type       = "jwt"
  token_policies  = ["default", vault_policy.gha_rmb938_tf_hashicorp_vault_apps.name]
  token_ttl       = "3600" # 1h
  bound_claims = {
    repository_id = "929992146"
  }
}
