resource "vault_policy" "ts_default" {
  name = "ts_default"

  policy = <<EOT
path "secret/data/consul/encrypt_key" {
  capabilities = ["read"]
}
EOT
}
