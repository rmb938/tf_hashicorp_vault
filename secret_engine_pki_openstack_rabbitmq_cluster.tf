# Root
resource "vault_mount" "pki_openstack_rabbitmq_cluster_root" {
  path                  = "pki_openstack_rabbitmq_cluster_root"
  type                  = "pki"
  max_lease_ttl_seconds = "631139040" # 20 years

  lifecycle {
    prevent_destroy = true
  }
}

resource "vault_pki_secret_backend_root_cert" "pki_openstack_rabbitmq_cluster_root" {
  backend     = vault_mount.pki_openstack_rabbitmq_cluster_root.path
  type        = "internal"
  common_name = "Openstack RabbitMQ Cluster Root"
  ttl         = vault_mount.pki_openstack_rabbitmq_cluster_root.max_lease_ttl_seconds
  key_type    = "ec"
  key_bits    = 384

  lifecycle {
    prevent_destroy = true
  }
}

resource "vault_pki_secret_backend_issuer" "pki_openstack_rabbitmq_cluster_root" {
  backend     = vault_pki_secret_backend_root_cert.pki_openstack_rabbitmq_cluster_root.backend
  issuer_ref  = vault_pki_secret_backend_root_cert.pki_openstack_rabbitmq_cluster_root.issuer_id
  issuer_name = "openstack-rabbitmq-root"

  lifecycle {
    prevent_destroy = true
  }
}

resource "vault_pki_secret_backend_config_issuers" "pki_openstack_rabbitmq_cluster_root" {
  backend                       = vault_mount.pki_openstack_rabbitmq_cluster_root.path
  default                       = vault_pki_secret_backend_issuer.pki_openstack_rabbitmq_cluster_root.issuer_id
  default_follows_latest_issuer = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "vault_mount" "pki_openstack_rabbitmq_cluster_intermediate" {
  path                  = "pki_openstack_rabbitmq_cluster_intermediate"
  type                  = "pki"
  max_lease_ttl_seconds = "94670856" # 3 years

  lifecycle {
    prevent_destroy = true
  }
}

locals {
  # Increment this when we want to rotate intermediates since we can't renew
  # we will never be removing old intermediates just no new certs can be signed with expired intermediates
  pki_openstack_rabbitmq_cluster_intermediates = 1
}

resource "vault_pki_secret_backend_key" "pki_openstack_rabbitmq_cluster_intermediate" {
  count = local.pki_openstack_rabbitmq_cluster_intermediates

  backend  = vault_mount.pki_openstack_rabbitmq_cluster_intermediate.path
  type     = vault_pki_secret_backend_root_cert.pki_openstack_rabbitmq_cluster_root.type
  key_type = vault_pki_secret_backend_root_cert.pki_openstack_rabbitmq_cluster_root.key_type
  key_bits = vault_pki_secret_backend_root_cert.pki_openstack_rabbitmq_cluster_root.key_bits
  key_name = "openstack-rabbitmq-cluster-intermediate-${count.index}"
}

resource "vault_pki_secret_backend_intermediate_cert_request" "pki_openstack_rabbitmq_cluster_intermediate" {
  count = local.pki_openstack_rabbitmq_cluster_intermediates

  backend     = vault_mount.pki_openstack_rabbitmq_cluster_intermediate.path
  type        = "existing"
  common_name = "Openstack RabbitMQ Cluster Intermediate ${count.index}"
  key_ref     = vault_pki_secret_backend_key.pki_openstack_rabbitmq_cluster_intermediate[count.index].key_id
  key_type    = vault_pki_secret_backend_key.pki_openstack_rabbitmq_cluster_intermediate[count.index].key_type
  key_bits    = vault_pki_secret_backend_key.pki_openstack_rabbitmq_cluster_intermediate[count.index].key_bits
}

resource "vault_pki_secret_backend_root_sign_intermediate" "pki_openstack_rabbitmq_cluster_intermediate" {
  count = local.pki_openstack_rabbitmq_cluster_intermediates

  backend     = vault_mount.pki_openstack_rabbitmq_cluster_root.path
  csr         = vault_pki_secret_backend_intermediate_cert_request.pki_openstack_rabbitmq_cluster_intermediate[count.index].csr
  common_name = vault_pki_secret_backend_intermediate_cert_request.pki_openstack_rabbitmq_cluster_intermediate[count.index].common_name
  ttl         = vault_mount.pki_openstack_rabbitmq_cluster_intermediate.max_lease_ttl_seconds
}

resource "vault_pki_secret_backend_intermediate_set_signed" "pki_openstack_rabbitmq_cluster_intermediate" {
  count = local.pki_openstack_rabbitmq_cluster_intermediates

  backend     = vault_mount.pki_openstack_rabbitmq_cluster_intermediate.path
  certificate = vault_pki_secret_backend_root_sign_intermediate.pki_openstack_rabbitmq_cluster_intermediate[count.index].certificate_bundle

  lifecycle {
    prevent_destroy = true
  }
}

resource "vault_pki_secret_backend_issuer" "pki_openstack_rabbitmq_cluster_intermediate" {
  count = local.pki_openstack_rabbitmq_cluster_intermediates

  backend     = vault_mount.pki_openstack_rabbitmq_cluster_intermediate.path
  issuer_ref  = vault_pki_secret_backend_intermediate_set_signed.pki_openstack_rabbitmq_cluster_intermediate[local.pki_openstack_rabbitmq_cluster_intermediates - 1].imported_issuers[0]
  issuer_name = "openstack-rabbitmq-cluster-intermediate-${count.index}"

  lifecycle {
    prevent_destroy = true
  }
}


resource "vault_pki_secret_backend_config_issuers" "pki_openstack_rabbitmq_cluster_intermediate" {
  backend = vault_mount.pki_openstack_rabbitmq_cluster_intermediate.path

  # Always set the default issuer to the latest one created
  default                       = vault_pki_secret_backend_intermediate_set_signed.pki_openstack_rabbitmq_cluster_intermediate[local.pki_openstack_rabbitmq_cluster_intermediates - 1].imported_issuers[0]
  default_follows_latest_issuer = false
}

resource "vault_pki_secret_backend_role" "pki_openstack_rabbitmq_cluster_intermediate_user_rabbitmq" {
  backend             = vault_mount.pki_openstack_rabbitmq_cluster_intermediate.path
  name                = "user-cli"
  issuer_ref          = "default"
  ttl                 = "7776000" # 90 days
  max_ttl             = "7776000"
  allow_ip_sans       = false
  allowed_domains     = ["cli"]
  allow_bare_domains  = true
  allow_subdomains    = false
  enforce_hostnames   = false
  server_flag         = false
  client_flag         = true
  key_type            = "ec"
  key_bits            = 256
  generate_lease      = false
  no_store            = true
  not_before_duration = "30s"
}
