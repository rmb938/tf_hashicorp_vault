resource "vault_policy" "ts_default" {
  name = "ts_default"

  policy = <<EOT
path "secret/data/consul/encrypt_key" {
  capabilities = ["read"]
}
EOT
}

# https://developer.hashicorp.com/consul/tutorials/operate-consul/vault-pki-consul-connect-ca#create-vault-policies
resource "vault_policy" "ts_hashiconsulserver" {
  name = "ts_hashiconsulserver"

  policy = <<EOT
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
EOT
}
