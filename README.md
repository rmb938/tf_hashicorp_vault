# tf_hashicorp_vault
Terraform to manage Hashicorp Vault

## Requirements

* Setup JWT auth backend for Github Actions OIDC
  ```bash
  vault auth enable -path=jwt-gha jwt
  vault write auth/jwt-gha/config oidc_discovery_url="https://token.actions.githubusercontent.com" bound_issuer="https://token.actions.githubusercontent.com"
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
  path "auth/token/create" {
    capabilities = ["update"]
  }

  path "sys/policies/*" {
    capabilities = ["create", "read", "update", "delete"]
  }

  path "sys/auth/*" {
    capabilities = ["sudo", "create", "read", "update", "delete"]
  }

  path "sys/mounts/*" {
    capabilities = ["create", "read", "update", "delete"]
  }

  path "auth/*" {
    capabilities = ["create", "read", "update", "delete"]
  }

  path "secret/config" {
    capabilities = ["create", "read", "update"]
  }

  path "pki_consul_root/config/issuers" {
    capabilities = ["create", "read", "update"]
  }
  path "pki_consul_root/issuers/generate/root/internal" {
    capabilities = ["create", "read", "update"]
  }
  path "pki_consul_root/issuer/+" {
    capabilities = ["create", "read", "update"]
  }

  path "pki_consul_intermediate_0/intermediate/set-signed" {
    capabilities = ["create", "read", "update"]
  }
  EOF
  ```