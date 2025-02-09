# https://developer.hashicorp.com/consul/tutorials/operate-consul/vault-pki-consul-connect-ca#create-vault-policies
resource "vault_policy" "hashi_consul" {
  name = "step_hashi_consul"

  policy = <<EOT
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
