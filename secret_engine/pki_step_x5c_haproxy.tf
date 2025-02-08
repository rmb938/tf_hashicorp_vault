# Root
resource "vault_mount" "pki_step_x5c_haproxy_root" {
  path                  = "pki_step_x5c_haproxy_root"
  type                  = "pki"
  max_lease_ttl_seconds = "631139040" # 20 years

  lifecycle {
    prevent_destroy = true
  }
}

resource "vault_pki_secret_backend_root_cert" "pki_step_x5c_haproxy_root" {
  backend     = vault_mount.pki_step_x5c_haproxy_root.path
  type        = "internal"
  common_name = "Step X5C HAProxy Root"
  ttl         = vault_mount.pki_step_x5c_haproxy_root.max_lease_ttl_seconds
  key_type    = "ec"
  key_bits    = 384

  lifecycle {
    prevent_destroy = true
  }
}

resource "vault_pki_secret_backend_issuer" "pki_step_x5c_haproxy_root" {
  backend     = vault_pki_secret_backend_root_cert.pki_step_x5c_haproxy_root.backend
  issuer_ref  = vault_pki_secret_backend_root_cert.pki_step_x5c_haproxy_root.issuer_id
  issuer_name = "step-x5c-haproxy-root"

  lifecycle {
    prevent_destroy = true
  }
}

resource "vault_pki_secret_backend_config_issuers" "pki_step_x5c_haproxy_root" {
  backend                       = vault_mount.pki_step_x5c_haproxy_root.path
  default                       = vault_pki_secret_backend_issuer.pki_step_x5c_haproxy_root.issuer_id
  default_follows_latest_issuer = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "vault_mount" "pki_step_x5c_haproxy_intermediate" {
  path                  = "pki_step_x5c_haproxy_intermediate"
  type                  = "pki"
  max_lease_ttl_seconds = "94670856" # 3 years

  lifecycle {
    prevent_destroy = true
  }
}

locals {
  # Increment this when we want to rotate intermediates since we can't renew
  # we will never be removing old intermediates just no new certs can be signed with expired intermediates
  pki_step_x5c_haproxy_intermediates = 1
}

resource "vault_pki_secret_backend_key" "pki_step_x5c_haproxy_intermediate" {
  count = local.pki_step_x5c_haproxy_intermediates

  backend  = vault_mount.pki_step_x5c_haproxy_intermediate.path
  type     = vault_pki_secret_backend_root_cert.pki_step_x5c_haproxy_root.type
  key_type = vault_pki_secret_backend_root_cert.pki_step_x5c_haproxy_root.key_type
  key_bits = vault_pki_secret_backend_root_cert.pki_step_x5c_haproxy_root.key_bits
}

resource "vault_pki_secret_backend_intermediate_cert_request" "pki_step_x5c_haproxy_intermediate" {
  count = local.pki_step_x5c_haproxy_intermediates

  backend     = vault_mount.pki_step_x5c_haproxy_intermediate.path
  type        = "existing"
  common_name = "Step X5C HAProxy Intermediate ${count.index}"
  key_ref     = vault_pki_secret_backend_key.pki_step_x5c_haproxy_intermediate[count.index].key_id
  key_type    = vault_pki_secret_backend_key.pki_step_x5c_haproxy_intermediate[count.index].key_type
  key_bits    = vault_pki_secret_backend_key.pki_step_x5c_haproxy_intermediate[count.index].key_bits
}

resource "vault_pki_secret_backend_root_sign_intermediate" "pki_step_x5c_haproxy_intermediate" {
  count = local.pki_step_x5c_haproxy_intermediates

  backend     = vault_mount.pki_step_x5c_haproxy_intermediate.path
  csr         = vault_pki_secret_backend_intermediate_cert_request.pki_step_x5c_haproxy_intermediate[count.index].csr
  common_name = vault_pki_secret_backend_intermediate_cert_request.pki_step_x5c_haproxy_intermediate[count.index].common_name
  ttl         = vault_mount.pki_step_x5c_haproxy_intermediate.max_lease_ttl_seconds
}

resource "vault_pki_secret_backend_intermediate_set_signed" "pki_step_x5c_haproxy_intermediate" {
  count = local.pki_step_x5c_haproxy_intermediates

  backend     = vault_mount.pki_step_x5c_haproxy_intermediate.path
  certificate = vault_pki_secret_backend_root_sign_intermediate.pki_step_x5c_haproxy_intermediate[count.index].certificate_bundle

  lifecycle {
    prevent_destroy = true
  }
}

resource "vault_pki_secret_backend_role" "pki_step_x5c_haproxy_intermediate" {
  count = local.pki_step_x5c_haproxy_intermediates

  backend             = vault_mount.pki_step_x5c_haproxy_intermediate.path
  name                = "pki_step_x5c_haproxy_intermediate_${count.index}"
  issuer_ref          = vault_pki_secret_backend_intermediate_set_signed.pki_step_x5c_haproxy_intermediate[count.index].imported_issuers[0]
  ttl                 = "7776000" # 90 days
  max_ttl             = "7776000"
  allow_ip_sans       = false
  allowed_domains     = ["haproxy.us-homelab1.hl.rmb938.me"] # TODO: hard coding this for now
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

# write all chains so it's easy to copy into step x5c
resource "vault_kv_secret" "pki_step_x5c_haproxy_chains" {
  path = "${vault_mount.secret.path}/haproxy/pki_step_x5c_haproxy_chains"
  data_json = jsonencode(
    {
      chains = join("\n", [for signedCert in vault_pki_secret_backend_root_sign_intermediate.pki_step_x5c_haproxy_intermediate : signedCert.certificate_bundle])
    }
  )

  depends_on = [vault_mount.secret]

  lifecycle {
    prevent_destroy = true
  }
}
