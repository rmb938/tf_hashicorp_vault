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
  key_type    = "ec"
  key_bits    = 256

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
  max_lease_ttl_seconds = "157784760" # 5 years

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
resource "vault_kv_secret" "consul_pki_consul_rpc_intermediates" {
  path = "${vault_mount.secret.path}/consul/pki_consul_rpc_intermediates"
  data_json = jsonencode(
    {
      pki_consul_rpc_intermediates = local.pki_consul_rpc_intermediates - 1, // sub 1 cause count starts at 0
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
  key_type    = "ec"
  key_bits    = 256
}

resource "vault_pki_secret_backend_root_sign_intermediate" "pki_consul_rpc_intermediate" {
  count = local.pki_consul_rpc_intermediates

  backend     = vault_mount.pki_consul_rpc_root.path
  csr         = vault_pki_secret_backend_intermediate_cert_request.pki_consul_rpc_intermediate[count.index].csr
  common_name = vault_pki_secret_backend_intermediate_cert_request.pki_consul_rpc_intermediate[count.index].common_name
  ttl         = vault_mount.pki_consul_rpc_intermediate.max_lease_ttl_seconds

  lifecycle {
    prevent_destroy = true
  }
}

resource "vault_pki_secret_backend_intermediate_set_signed" "pki_consul_rpc_intermediate" {
  backend     = vault_mount.pki_consul_rpc_intermediate.path
  certificate = vault_pki_secret_backend_root_sign_intermediate.pki_consul_rpc_intermediate[0].certificate

  lifecycle {
    prevent_destroy = true
  }
}

resource "vault_pki_secret_backend_role" "role" {
  count = local.pki_consul_rpc_intermediates

  backend             = vault_mount.pki_consul_rpc_intermediate.path
  name                = "pki_consul_rpc_intermediate_${count.index}"
  issuer_ref          = vault_pki_secret_backend_intermediate_set_signed.pki_consul_rpc_intermediate[count.index].imported_issuers[0]
  ttl                 = "90d"
  max_ttl             = "90d"
  allow_ip_sans       = false
  allowed_domains     = ["server.us-homelab1.consul"] # TODO: hard coding this for now
  allow_bare_domains  = true
  allow_subdomains    = false
  enforce_hostnames   = true
  server_flag         = true
  client_flag         = true
  key_type            = "ec"
  key_bits            = 256
  generate_lease      = false
  no_store            = true
  not_before_duration = "30s"
}
