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
  path "pki_consul_rpc_intermediate/issuer/+" {
    capabilities = ["read", "update"]
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
  path "pki_step_x5c_haproxy_intermediate/issuer/+" {
    capabilities = ["read", "update"]
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
  path "pki_openstack_postgres_patroni_intermediate/issuer/+" {
    capabilities = ["read", "update"]
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
  path "pki_openstack_postgres_intermediate/issuer/+" {
    capabilities = ["read", "update"]
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

  path "pki_openstack_rabbitmq_root/config/issuers" {
    capabilities = ["create", "read", "update"]
  }
  path "pki_openstack_rabbitmq_root/issuers/generate/root/internal" {
    capabilities = ["create", "read", "update"]
  }
  path "pki_openstack_rabbitmq_root/issuer/+" {
    capabilities = ["create", "read", "update"]
  }
  path "pki_openstack_rabbitmq_root/root/sign-intermediate" {
    capabilities = ["create", "read", "update"]
  }
  path "pki_openstack_rabbitmq_intermediate/keys/generate/internal" {
    capabilities = ["create", "read", "update"]
  }
  path "pki_openstack_rabbitmq_intermediate/key/+" {
    capabilities = ["create", "read", "update", "delete"]
  }
  path "pki_openstack_rabbitmq_intermediate/issuer/+" {
    capabilities = ["read", "update"]
  }
  path "pki_openstack_rabbitmq_intermediate/issuers/generate/intermediate/internal" {
    capabilities = ["create", "read", "update"]
  }
  path "pki_openstack_rabbitmq_intermediate/issuers/generate/intermediate/existing" {
    capabilities = ["create", "read", "update"]
  }
  path "pki_openstack_rabbitmq_intermediate/intermediate/set-signed" {
    capabilities = ["create", "read", "update"]
  }
  path "pki_openstack_rabbitmq_intermediate/config/issuers" {
    capabilities = ["create", "read", "update", "delete"]
  }
  path "pki_openstack_rabbitmq_intermediate/roles/+" {
    capabilities = ["create", "read", "update", "delete"]
  }

  path "pki_openstack_rabbitmq_cluster_root/config/issuers" {
    capabilities = ["create", "read", "update"]
  }
  path "pki_openstack_rabbitmq_cluster_root/issuers/generate/root/internal" {
    capabilities = ["create", "read", "update"]
  }
  path "pki_openstack_rabbitmq_cluster_root/issuer/+" {
    capabilities = ["create", "read", "update"]
  }
  path "pki_openstack_rabbitmq_cluster_root/root/sign-intermediate" {
    capabilities = ["create", "read", "update"]
  }
  path "pki_openstack_rabbitmq_cluster_intermediate/keys/generate/internal" {
    capabilities = ["create", "read", "update"]
  }
  path "pki_openstack_rabbitmq_cluster_intermediate/key/+" {
    capabilities = ["create", "read", "update", "delete"]
  }
  path "pki_openstack_rabbitmq_cluster_intermediate/issuer/+" {
    capabilities = ["read", "update"]
  }
  path "pki_openstack_rabbitmq_cluster_intermediate/issuers/generate/intermediate/internal" {
    capabilities = ["create", "read", "update"]
  }
  path "pki_openstack_rabbitmq_cluster_intermediate/issuers/generate/intermediate/existing" {
    capabilities = ["create", "read", "update"]
  }
  path "pki_openstack_rabbitmq_cluster_intermediate/intermediate/set-signed" {
    capabilities = ["create", "read", "update"]
  }
  path "pki_openstack_rabbitmq_cluster_intermediate/config/issuers" {
    capabilities = ["create", "read", "update", "delete"]
  }
  path "pki_openstack_rabbitmq_cluster_intermediate/roles/+" {
    capabilities = ["create", "read", "update", "delete"]
  }

  path "transit_openstack_keystone_token/keys/+" {
    capabilities = ["create", "read", "update", "delete"]
  }
  path "transit_openstack_keystone_token/keys/+/config" {
    capabilities = ["create", "read", "update", "delete"]
  }

  path "transit_openstack_keystone_receipt/keys/+" {
    capabilities = ["create", "read", "update", "delete"]
  }
  path "transit_openstack_keystone_receipt/keys/+/config" {
    capabilities = ["create", "read", "update", "delete"]
  }
  
  path "transit_openstack_keystone_credential/keys/+" {
    capabilities = ["create", "read", "update", "delete"]
  }
  path "transit_openstack_keystone_credential/keys/+/config" {
    capabilities = ["create", "read", "update", "delete"]
  }

  path "secret/openstack-keystone/expected-service-users/+" {
    capabilities = ["create", "read", "update", "delete"]
  }
  path "secret/openstack-keystone/expected-project-users/+" {
    capabilities = ["create", "read", "update", "delete"]
  }

  path "pki_openstack_ovn_ovsdb_root/config/issuers" {
    capabilities = ["create", "read", "update"]
  }
  path "pki_openstack_ovn_ovsdb_root/issuers/generate/root/internal" {
    capabilities = ["create", "read", "update"]
  }
  path "pki_openstack_ovn_ovsdb_root/issuer/+" {
    capabilities = ["create", "read", "update"]
  }
  path "pki_openstack_ovn_ovsdb_root/root/sign-intermediate" {
    capabilities = ["create", "read", "update"]
  }
  path "pki_openstack_ovn_ovsdb_intermediate/keys/generate/internal" {
    capabilities = ["create", "read", "update"]
  }
  path "pki_openstack_ovn_ovsdb_intermediate/key/+" {
    capabilities = ["create", "read", "update", "delete"]
  }
  path "pki_openstack_ovn_ovsdb_intermediate/issuer/+" {
    capabilities = ["read", "update"]
  }
  path "pki_openstack_ovn_ovsdb_intermediate/issuers/generate/intermediate/internal" {
    capabilities = ["create", "read", "update"]
  }
  path "pki_openstack_ovn_ovsdb_intermediate/issuers/generate/intermediate/existing" {
    capabilities = ["create", "read", "update"]
  }
  path "pki_openstack_ovn_ovsdb_intermediate/intermediate/set-signed" {
    capabilities = ["create", "read", "update"]
  }
  path "pki_openstack_ovn_ovsdb_intermediate/config/issuers" {
    capabilities = ["create", "read", "update", "delete"]
  }
  path "pki_openstack_ovn_ovsdb_intermediate/roles/+" {
    capabilities = ["create", "read", "update", "delete"]
  }
  EOF
  ```
