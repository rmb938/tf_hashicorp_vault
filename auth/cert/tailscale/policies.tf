resource "vault_policy" "ts_default" {
  name = "ts_default"

  policy = <<EOT
path "secret/data/consul/encrypt_key" {
  capabilities = ["read"]
}

path "/sys/mounts/pki_consul_root" {
  capabilities = [ "read" ]
}
path "/sys/mounts/pki_consul_intermediate_0" {
  capabilities = [ "read" ]
}
path "/sys/mounts/pki_consul_intermediate_0/tune" {
  capabilities = [ "update" ]
}
path "/pki_consul_root/" {
  capabilities = [ "read" ]
}
path "/pki_consul_root/root/sign-intermediate" {
  capabilities = [ "update" ]
}
path "/pki_consul_intermediate_0/*" {
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

resource "vault_policy" "ts_hashiconsulserver" {
  name = "ts_hashiconsulserver"

  policy = <<EOT
path "/sys/mounts/pki_consul_root" {
  capabilities = [ "read" ]
}
path "/sys/mounts/pki_consul_intermediate_0" {
  capabilities = [ "read" ]
}
path "/sys/mounts/pki_consul_intermediate_0/tune" {
  capabilities = [ "update" ]
}
path "/pki_consul_root/" {
  capabilities = [ "read" ]
}
path "/pki_consul_root/root/sign-intermediate" {
  capabilities = [ "update" ]
}
path "/pki_consul_intermediate_0/*" {
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
