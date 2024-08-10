# Root
resource "vault_mount" "pki_consul_connect_root" {
  path                  = "pki_consul_connect_root"
  type                  = "pki"
  max_lease_ttl_seconds = "631139040" # 20 years

  lifecycle {
    prevent_destroy = true
  }
}

resource "vault_pki_secret_backend_root_cert" "pki_consul_connect_root" {
  backend     = vault_mount.pki_consul_connect_root.path
  type        = "internal"
  common_name = "Consul Connect Root"
  ttl         = vault_mount.pki_consul_connect_root.max_lease_ttl_seconds
  key_type    = "ec"
  key_bits    = 256

  lifecycle {
    prevent_destroy = true
  }
}

resource "vault_pki_secret_backend_issuer" "pki_consul_connect_root" {
  backend     = vault_pki_secret_backend_root_cert.pki_consul_connect_root.backend
  issuer_ref  = vault_pki_secret_backend_root_cert.pki_consul_connect_root.issuer_id
  issuer_name = "consul-connect-root"

  lifecycle {
    prevent_destroy = true
  }
}

resource "vault_pki_secret_backend_config_issuers" "pki_consul_connect_root" {
  backend                       = vault_mount.pki_consul_connect_root.path
  default                       = vault_pki_secret_backend_issuer.pki_consul_connect_root.issuer_id
  default_follows_latest_issuer = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "vault_mount" "pki_consul_connect_intermediate" {
  path                  = "pki_consul_connect_intermediate"
  type                  = "pki"
  max_lease_ttl_seconds = "31556952" # 1 year

  lifecycle {
    prevent_destroy = true
  }
}
