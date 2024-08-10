# Root
resource "vault_mount" "pki_consul_rpc_root" {
  path                  = "pki_consul_rpc_root"
  type                  = "pki"
  max_lease_ttl_seconds = "631139040" # 20 years

  lifecycle {
    prevent_destroy = true
  }
}

resource "vault_pki_secret_backend_root_cert" "pki_consul_rpc_root" {
  backend     = vault_mount.pki_consul_rpc_root.path
  type        = "internal"
  common_name = "Consul RPC Root"
  ttl         = vault_mount.pki_consul_rpc_root.max_lease_ttl_seconds

  lifecycle {
    prevent_destroy = true
  }
}

resource "vault_pki_secret_backend_issuer" "pki_consul_rpc_root" {
  backend     = vault_pki_secret_backend_root_cert.pki_consul_rpc_root.backend
  issuer_ref  = vault_pki_secret_backend_root_cert.pki_consul_rpc_root.issuer_id
  issuer_name = "consul-rpc-root"

  lifecycle {
    prevent_destroy = true
  }
}

resource "vault_pki_secret_backend_config_issuers" "pki_consul_rpc_root" {
  backend                       = vault_mount.pki_consul_rpc_root.path
  default                       = vault_pki_secret_backend_issuer.pki_consul_rpc_root.issuer_id
  default_follows_latest_issuer = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "vault_mount" "pki_consul_rpc_intermediate" {
  path                  = "pki_consul_rpc_intermediate"
  type                  = "pki"
  max_lease_ttl_seconds = "31556952" # 1 year

  lifecycle {
    prevent_destroy = true
  }
}

locals {
  # Increment this when we want to rotate intermediates since we can't renew
  # we will never be removing old intermediates just no new certs can be signed with expired intermediates
  pki_consul_rpc_intermediates = 1
}

# write pki_consul_rpc_intermediates to a kv so servers and clients can figure out what intermediates to trust
resource "vault_kv_secret_v2" "consul_pki_consul_rpc_intermediates" {
  mount = vault_kv_secret_backend_v2.secret.mount
  name  = "consul/pki_consul_rpc_intermediates"
  data_json = jsonencode(
    {
      pki_consul_rpc_intermediates = local.pki_consul_rpc_intermediates,
    }
  )

  lifecycle {
    prevent_destroy = true
  }
}

resource "vault_pki_secret_backend_intermediate_cert_request" "pki_consul_rpc_intermediate" {
  count = local.pki_consul_rpc_intermediates

  backend     = vault_mount.pki_consul_rpc_intermediate.path
  type        = vault_pki_secret_backend_root_cert.pki_consul_rpc_root.type
  common_name = "Consul RPC Intermediate ${count.index}"

  lifecycle {
    prevent_destroy = true
  }
}

resource "vault_pki_secret_backend_root_sign_intermediate" "pki_consul_rpc_intermediate" {
  count = local.pki_consul_rpc_intermediates

  backend     = vault_mount.pki_consul_rpc_root.path
  csr         = vault_pki_secret_backend_intermediate_cert_request.pki_consul_rpc_intermediate[count.index].csr
  common_name = vault_pki_secret_backend_intermediate_cert_request.pki_consul_rpc_intermediate[count.index].common_name
  ttl         = vault_mount.pki_consul_rpc_intermediate.max_lease_ttl_seconds
}

resource "vault_pki_secret_backend_intermediate_set_signed" "pki_consul_rpc_intermediate" {
  backend     = vault_mount.pki_consul_rpc_intermediate.path
  certificate = vault_pki_secret_backend_root_sign_intermediate.pki_consul_rpc_intermediate[0].certificate
}
