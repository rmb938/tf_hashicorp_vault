resource "vault_mount" "pki_consul_root" {
  path                  = "pki_consul_root"
  type                  = "pki"
  max_lease_ttl_seconds = "631139040" # 20 years
}

resource "vault_pki_secret_backend_root_cert" "pki_consul_root" {
  backend     = vault_mount.pki_consul_root.path
  type        = "internal"
  common_name = "Consul Root"
  ttl         = "631139040" # 20 years
}

resource "vault_pki_secret_backend_issuer" "pki_consul_root" {
  backend     = vault_pki_secret_backend_root_cert.pki_consul_root.backend
  issuer_ref  = vault_pki_secret_backend_root_cert.pki_consul_root.issuer_id
  issuer_name = "consul-root"
}

resource "vault_pki_secret_backend_config_issuers" "pki_consul_root" {
  backend                       = vault_mount.pki_consul_root.path
  default                       = vault_pki_secret_backend_issuer.pki_consul_root.issuer_id
  default_follows_latest_issuer = true
}

resource "vault_mount" "pki_consul_intermediate" {
  path                  = "pki_consul_intermediate"
  type                  = "pki"
  max_lease_ttl_seconds = "31556952" # 1 year
}

resource "vault_pki_secret_backend_intermediate_cert_request" "pki_consul_intermediate" {
  backend     = vault_mount.pki_consul_intermediate.path
  type        = vault_pki_secret_backend_root_cert.pki_consul_root.type
  common_name = "Consul Intermediate"
}

resource "vault_pki_secret_backend_root_sign_intermediate" "pki_consul_intermediate" {
  backend     = vault_mount.pki_consul_root.path
  csr         = vault_pki_secret_backend_intermediate_cert_request.pki_consul_intermediate.csr
  common_name = "Consul Intermediate"
  ttl         = "31556952" # 1 year
  revoke      = true
}

resource "vault_pki_secret_backend_intermediate_set_signed" "pki_consul_intermediate" {
  backend     = vault_mount.pki_consul_intermediate.path
  certificate = vault_pki_secret_backend_root_sign_intermediate.pki_consul_intermediate.certificate
}
