# Root
resource "vault_mount" "pki_consul_root" {
  path                  = "pki_consul_root"
  type                  = "pki"
  max_lease_ttl_seconds = "631139040" # 20 years

  lifecycle {
    prevent_destroy = true
  }
}

resource "vault_pki_secret_backend_root_cert" "pki_consul_root" {
  backend     = vault_mount.pki_consul_root.path
  type        = "internal"
  common_name = "Consul Root"
  ttl         = vault_mount.pki_consul_root.max_lease_ttl_seconds

  lifecycle {
    prevent_destroy = true
  }
}

resource "vault_pki_secret_backend_issuer" "pki_consul_root" {
  backend     = vault_pki_secret_backend_root_cert.pki_consul_root.backend
  issuer_ref  = vault_pki_secret_backend_root_cert.pki_consul_root.issuer_id
  issuer_name = "consul-root"

  lifecycle {
    prevent_destroy = true
  }
}

resource "vault_pki_secret_backend_config_issuers" "pki_consul_root" {
  backend                       = vault_mount.pki_consul_root.path
  default                       = vault_pki_secret_backend_issuer.pki_consul_root.issuer_id
  default_follows_latest_issuer = true

  lifecycle {
    prevent_destroy = true
  }
}

# Intermediates
locals {
  # When we want to create a new intermediate increase this by 1
  # The old intermediate will be kept around forever but once it expires it can no longer make certs
  pki_consul_intermediates = 1
}

resource "vault_mount" "pki_consul_intermediate" {
  count                 = local.pki_consul_intermediates
  path                  = "pki_consul_intermediate_${count.index}"
  type                  = "pki"
  max_lease_ttl_seconds = "31556952" # 1 year

  lifecycle {
    prevent_destroy = true
  }
}

resource "vault_pki_secret_backend_intermediate_cert_request" "pki_consul_intermediate" {
  count       = local.pki_consul_intermediates
  backend     = vault_mount.pki_consul_intermediate[count.index].path
  type        = vault_pki_secret_backend_root_cert.pki_consul_root.type
  common_name = "Consul Intermediate ${count.index}"

  lifecycle {
    prevent_destroy = true
  }
}

resource "vault_pki_secret_backend_root_sign_intermediate" "pki_consul_intermediate" {
  count       = local.pki_consul_intermediates
  backend     = vault_mount.pki_consul_root.path
  csr         = vault_pki_secret_backend_intermediate_cert_request.pki_consul_intermediate[count.index].csr
  common_name = "Consul Intermediate ${count.index}"
  ttl         = vault_mount.pki_consul_intermediate[count.index].max_lease_ttl_seconds

  lifecycle {
    prevent_destroy = true
  }
}

resource "vault_pki_secret_backend_intermediate_set_signed" "pki_consul_intermediate" {
  count       = local.pki_consul_intermediates
  backend     = vault_mount.pki_consul_intermediate[count.index].path
  certificate = vault_pki_secret_backend_root_sign_intermediate.pki_consul_intermediate[count.index].certificate

  lifecycle {
    prevent_destroy = true
  }
}
