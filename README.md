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
    "bound_claims": { "repository_id": ["840079927"] }
  }
  EOF
  ```
* Create a policy for this github repo TODO: This will forever grow, we need a better way...
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

  path "pki_consul_connect_root/config/issuers" {
    capabilities = ["create", "read", "update"]
  }
  path "pki_consul_connect_root/issuers/generate/root/internal" {
    capabilities = ["create", "read", "update"]
  }
  path "pki_consul_connect_root/issuer/+" {
    capabilities = ["create", "read", "update"]
  }

  path "secret/consul/encrypt_key" {
    capabilities = ["create", "read", "update"]
  }
  path "secret/consul/management_token" {
    capabilities = ["create", "read", "update"]
  }
  path "pki_consul_rpc_root/config/issuers" {
    capabilities = ["create", "read", "update"]
  }
  path "pki_consul_rpc_root/issuers/generate/root/internal" {
    capabilities = ["create", "read", "update"]
  }
  path "pki_consul_rpc_root/issuer/+" {
    capabilities = ["create", "read", "update"]
  }
  path "pki_consul_rpc_root/root/sign-intermediate" {
    capabilities = ["create", "read", "update"]
  }
  path "pki_consul_rpc_intermediate/keys/generate/internal" {
    capabilities = ["create", "read", "update"]
  }
  path "pki_consul_rpc_intermediate/key/+" {
    capabilities = ["create", "read", "update", "delete"]
  }
  path "pki_consul_rpc_intermediate/issuers/generate/intermediate/internal" {
    capabilities = ["create", "read", "update"]
  }
  path "pki_consul_rpc_intermediate/issuers/generate/intermediate/existing" {
    capabilities = ["create", "read", "update"]
  }
  path "pki_consul_rpc_intermediate/intermediate/set-signed" {
    capabilities = ["create", "read", "update"]
  }
  path "pki_consul_rpc_intermediate/roles/+" {
    capabilities = ["create", "read", "update", "delete"]
  }
  path "pki_consul_rpc_intermediate/config/issuers" {
    capabilities = ["create", "read", "update", "delete"]
  }

  path "pki_step_x5c_haproxy_root/config/issuers" {
    capabilities = ["create", "read", "update"]
  }
  path "pki_step_x5c_haproxy_root/issuers/generate/root/internal" {
    capabilities = ["create", "read", "update"]
  }
  path "pki_step_x5c_haproxy_root/issuer/+" {
    capabilities = ["create", "read", "update"]
  }
  path "pki_step_x5c_haproxy_root/root/sign-intermediate" {
    capabilities = ["create", "read", "update"]
  }
  path "pki_step_x5c_haproxy_intermediate/keys/generate/internal" {
    capabilities = ["create", "read", "update"]
  }
  path "pki_step_x5c_haproxy_intermediate/key/+" {
    capabilities = ["create", "read", "update", "delete"]
  }
  path "pki_step_x5c_haproxy_intermediate/issuers/generate/intermediate/internal" {
    capabilities = ["create", "read", "update"]
  }
  path "pki_step_x5c_haproxy_intermediate/issuers/generate/intermediate/existing" {
    capabilities = ["create", "read", "update"]
  }
  path "pki_step_x5c_haproxy_intermediate/intermediate/set-signed" {
    capabilities = ["create", "read", "update"]
  }
  path "pki_step_x5c_haproxy_intermediate/config/issuers" {
    capabilities = ["create", "read", "update", "delete"]
  }
  path "pki_step_x5c_haproxy_intermediate/roles/+" {
    capabilities = ["create", "read", "update", "delete"]
  }

  path "consul/config/access" {
    capabilities = ["create", "read", "update"]
  }

  path "pki_openstack_postgres_patroni_root/config/issuers" {
    capabilities = ["create", "read", "update"]
  }
  path "pki_openstack_postgres_patroni_root/issuers/generate/root/internal" {
    capabilities = ["create", "read", "update"]
  }
  path "pki_openstack_postgres_patroni_root/issuer/+" {
    capabilities = ["create", "read", "update"]
  }
  path "pki_openstack_postgres_patroni_root/root/sign-intermediate" {
    capabilities = ["create", "read", "update"]
  }
  path "pki_openstack_postgres_patroni_intermediate/keys/generate/internal" {
    capabilities = ["create", "read", "update"]
  }
  path "pki_openstack_postgres_patroni_intermediate/key/+" {
    capabilities = ["create", "read", "update", "delete"]
  }
  path "pki_openstack_postgres_patroni_intermediate/issuers/generate/intermediate/internal" {
    capabilities = ["create", "read", "update"]
  }
  path "pki_openstack_postgres_patroni_intermediate/issuers/generate/intermediate/existing" {
    capabilities = ["create", "read", "update"]
  }
  path "pki_openstack_postgres_patroni_intermediate/intermediate/set-signed" {
    capabilities = ["create", "read", "update"]
  }
  path "pki_openstack_postgres_patroni_intermediate/config/issuers" {
    capabilities = ["create", "read", "update", "delete"]
  }
  path "pki_openstack_postgres_patroni_intermediate/roles/+" {
    capabilities = ["create", "read", "update", "delete"]
  }

  path "pki_openstack_postgres_root/config/issuers" {
    capabilities = ["create", "read", "update"]
  }
  path "pki_openstack_postgres_root/issuers/generate/root/internal" {
    capabilities = ["create", "read", "update"]
  }
  path "pki_openstack_postgres_root/issuer/+" {
    capabilities = ["create", "read", "update"]
  }
  path "pki_openstack_postgres_root/root/sign-intermediate" {
    capabilities = ["create", "read", "update"]
  }
  path "pki_openstack_postgres_intermediate/keys/generate/internal" {
    capabilities = ["create", "read", "update"]
  }
  path "pki_openstack_postgres_intermediate/key/+" {
    capabilities = ["create", "read", "update", "delete"]
  }
  path "pki_openstack_postgres_intermediate/issuers/generate/intermediate/internal" {
    capabilities = ["create", "read", "update"]
  }
  path "pki_openstack_postgres_intermediate/issuers/generate/intermediate/existing" {
    capabilities = ["create", "read", "update"]
  }
  path "pki_openstack_postgres_intermediate/intermediate/set-signed" {
    capabilities = ["create", "read", "update"]
  }
  path "pki_openstack_postgres_intermediate/config/issuers" {
    capabilities = ["create", "read", "update", "delete"]
  }
  path "pki_openstack_postgres_intermediate/roles/+" {
    capabilities = ["create", "read", "update", "delete"]
  }
  EOF
  ```
