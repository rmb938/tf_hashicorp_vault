resource "vault_policy" "default" {
  name = "step_default"

  policy = <<EOT
path "secret/consul/encrypt_key" {
  capabilities = ["read"]
}
path "secret/consul/pki_consul_rpc_chains" {
  capabilities = ["read"]
}
EOT
}
