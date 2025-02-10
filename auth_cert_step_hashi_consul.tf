# https://developer.hashicorp.com/consul/tutorials/operate-consul/vault-pki-consul-connect-ca#create-vault-policies
resource "vault_policy" "hashi_consul" {
  name = "hashi_consul"

  policy = <<EOT
path "secret/consul/encrypt_key" {
  capabilities = ["read"]
}

path "secret/consul/management_token" {
  capabilities = ["read"]
}

path "/sys/mounts/pki_consul_connect_root" {
  capabilities = [ "read" ]
}
path "/sys/mounts/pki_consul_connect_intermediate" {
  capabilities = [ "read" ]
}
path "/sys/mounts/pki_consul_connect_intermediate/tune" {
  capabilities = [ "update" ]
}
path "/pki_consul_connect_root/" {
  capabilities = [ "read" ]
}
path "/pki_consul_connect_root/root/sign-intermediate" {
  capabilities = [ "update" ]
}
path "/pki_consul_connect_intermediate/*" {
  capabilities = [ "create", "read", "update", "delete", "list" ]
}
path "auth/token/renew-self" {
  capabilities = [ "update" ]
}
path "auth/token/lookup-self" {
  capabilities = [ "read" ]
}

path "pki_consul_rpc_intermediate/issue/*" {
  capabilities = ["update"]
}
EOT
}

resource "vault_cert_auth_backend_role" "hashi_consul" {
  backend = vault_auth_backend.auth_step_cert.path

  name         = vault_policy.hashi_consul.name
  display_name = vault_policy.hashi_consul.name

  certificate = file("/usr/local/share/ca-certificates/smallstep-homelab-prod.crt")

  allowed_common_names = [
    "hashi-consul-1.us-homelab1.hl.rmb938.me",
    "hashi-consul-2.us-homelab1.hl.rmb938.me",
    "hashi-consul-3.us-homelab1.hl.rmb938.me",
  ]
  token_bound_cidrs = [
    "192.168.23.55/32",
    "192.168.23.56/32",
    "192.168.23.57/32"
  ]

  token_policies = [
    "default",
    vault_policy.hashi_consul.name,
  ]
}
