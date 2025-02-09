resource "vault_policy" "haproxy-t2" {
  name = "step_haproxy-t2"

  policy = <<EOT
path "secret/consul/pki_step_x5c_haproxy_chains" {
  capabilities = ["read"]
}

path "pki_step_x5c_haproxy_intermediate/issue/*" {
  capabilities = ["update"]
}
EOT
}
