# tf_hashicorp_vault
Terraform to manage Hashicorp Vault

## Requirements

* Setup JWT auth backend for Github Actions OIDC
  ```bash
  vault auth enable -path=jwt-gha jwt
  ```
* Create a role for this github repo
  ```bash
  vault write auth/jwt-gha/role/gha_rmb938_tf_hashicorp_vault -<<EOF
  {
    "user_claim": "repository",
    "bound_audiences": "https://github.com/rmb938",
    "role_type": "jwt",
    "policies": ["default", "gha_rmb938_tf_hashicorp_vault"],
    "ttl": "1h",
    "bound_claims": { "repository_id": ["X"] }
  }
  EOF
  ```
* Create a policy for this github repo
  ```bash
  vault policy write gha_rmb938_tf_hashicorp_vault -<<EOF
  path "sys/policy/*" {
    capabilities = ["create", "read", "update", "delete"]
  }

  path "sys/auth/*" {
    capabilities = ["sudo", "create", "read", "update", "delete"]
  }
  EOF
  ```