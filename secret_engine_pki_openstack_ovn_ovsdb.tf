# Root
resource "vault_mount" "pki_openstack_ovn_ovsdb_root" {
  path                  = "pki_openstack_ovn_ovsdb_root"
  type                  = "pki"
  max_lease_ttl_seconds = "631139040" # 20 years

  lifecycle {
    prevent_destroy = true
  }
}

resource "vault_pki_secret_backend_root_cert" "pki_openstack_ovn_ovsdb_root" {
  backend     = vault_mount.pki_openstack_ovn_ovsdb_root.path
  type        = "internal"
  common_name = "Openstack OVN OVSDB Root"
  ttl         = vault_mount.pki_openstack_ovn_ovsdb_root.max_lease_ttl_seconds
  key_type    = "ec"
  key_bits    = 384

  lifecycle {
    prevent_destroy = true
  }
}

resource "vault_pki_secret_backend_issuer" "pki_openstack_ovn_ovsdb_root" {
  backend     = vault_pki_secret_backend_root_cert.pki_openstack_ovn_ovsdb_root.backend
  issuer_ref  = vault_pki_secret_backend_root_cert.pki_openstack_ovn_ovsdb_root.issuer_id
  issuer_name = "openstack-ovn-ovsdb-root"

  lifecycle {
    prevent_destroy = true
  }
}

resource "vault_pki_secret_backend_config_issuers" "pki_openstack_ovn_ovsdb_root" {
  backend                       = vault_mount.pki_openstack_ovn_ovsdb_root.path
  default                       = vault_pki_secret_backend_issuer.pki_openstack_ovn_ovsdb_root.issuer_id
  default_follows_latest_issuer = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "vault_mount" "pki_openstack_ovn_ovsdb_intermediate" {
  path                  = "pki_openstack_ovn_ovsdb_intermediate"
  type                  = "pki"
  max_lease_ttl_seconds = "94670856" # 3 years

  lifecycle {
    prevent_destroy = true
  }
}

locals {
  # Increment this when we want to rotate intermediates since we can't renew
  # we will never be removing old intermediates just no new certs can be signed with expired intermediates
  pki_openstack_ovn_ovsdb_intermediates = 1
}

resource "vault_pki_secret_backend_key" "pki_openstack_ovn_ovsdb_intermediate" {
  count = local.pki_openstack_ovn_ovsdb_intermediates

  backend  = vault_mount.pki_openstack_ovn_ovsdb_intermediate.path
  type     = vault_pki_secret_backend_root_cert.pki_openstack_ovn_ovsdb_root.type
  key_type = vault_pki_secret_backend_root_cert.pki_openstack_ovn_ovsdb_root.key_type
  key_bits = vault_pki_secret_backend_root_cert.pki_openstack_ovn_ovsdb_root.key_bits
  key_name = "openstack-ovn-ovsdb-intermediate-${count.index}"
}

resource "vault_pki_secret_backend_intermediate_cert_request" "pki_openstack_ovn_ovsdb_intermediate" {
  count = local.pki_openstack_ovn_ovsdb_intermediates

  backend     = vault_mount.pki_openstack_ovn_ovsdb_intermediate.path
  type        = "existing"
  common_name = "Openstack OVN OVSDB Intermediate ${count.index}"
  key_ref     = vault_pki_secret_backend_key.pki_openstack_ovn_ovsdb_intermediate[count.index].key_id
  key_type    = vault_pki_secret_backend_key.pki_openstack_ovn_ovsdb_intermediate[count.index].key_type
  key_bits    = vault_pki_secret_backend_key.pki_openstack_ovn_ovsdb_intermediate[count.index].key_bits
}

resource "vault_pki_secret_backend_root_sign_intermediate" "pki_openstack_ovn_ovsdb_intermediate" {
  count = local.pki_openstack_ovn_ovsdb_intermediates

  backend     = vault_mount.pki_openstack_ovn_ovsdb_root.path
  csr         = vault_pki_secret_backend_intermediate_cert_request.pki_openstack_ovn_ovsdb_intermediate[count.index].csr
  common_name = vault_pki_secret_backend_intermediate_cert_request.pki_openstack_ovn_ovsdb_intermediate[count.index].common_name
  ttl         = vault_mount.pki_openstack_ovn_ovsdb_intermediate.max_lease_ttl_seconds
}

resource "vault_pki_secret_backend_intermediate_set_signed" "pki_openstack_ovn_ovsdb_intermediate" {
  count = local.pki_openstack_ovn_ovsdb_intermediates

  backend     = vault_mount.pki_openstack_ovn_ovsdb_intermediate.path
  certificate = vault_pki_secret_backend_root_sign_intermediate.pki_openstack_ovn_ovsdb_intermediate[count.index].certificate_bundle

  lifecycle {
    prevent_destroy = true
  }
}

resource "vault_pki_secret_backend_issuer" "pki_openstack_ovn_ovsdb_intermediate" {
  count = local.pki_openstack_ovn_ovsdb_intermediates

  backend     = vault_mount.pki_openstack_ovn_ovsdb_intermediate.path
  issuer_ref  = vault_pki_secret_backend_intermediate_set_signed.pki_openstack_ovn_ovsdb_intermediate[local.pki_openstack_ovn_ovsdb_intermediates - 1].imported_issuers[0]
  issuer_name = "openstack-ovn-ovsdb-intermediate-${count.index}"

  lifecycle {
    prevent_destroy = true
  }
}


resource "vault_pki_secret_backend_config_issuers" "pki_openstack_ovn_ovsdb_intermediate" {
  backend = vault_mount.pki_openstack_ovn_ovsdb_intermediate.path

  # Always set the default issuer to the latest one created
  default                       = vault_pki_secret_backend_intermediate_set_signed.pki_openstack_ovn_ovsdb_intermediate[local.pki_openstack_ovn_ovsdb_intermediates - 1].imported_issuers[0]
  default_follows_latest_issuer = false
}

# OVSDB uses the same cert for inter-cluster and user listeners
# So we need to allow the server hostnames in this cert as well.
# Not really ideal but nothing we can do.
resource "vault_pki_secret_backend_role" "pki_openstack_ovn_ovsdb_intermediate_server" {
  backend       = vault_mount.pki_openstack_ovn_ovsdb_intermediate.path
  name          = "server"
  issuer_ref    = "default"
  ttl           = "7776000" # 90 days
  max_ttl       = "7776000"
  allow_ip_sans = false
  allowed_domains = [
    "openstack-ovn-northd-1.node.consul",
    "openstack-ovn-northd-2.node.consul",
    "openstack-ovn-northd-3.node.consul",
    "openstack-ovn-northd-nb-ovsdb.service.consul",
    "openstack-ovn-northd-sb-ovsdb.service.consul"
  ]
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

# OVSDB uses the same CA for cluster auth and user auth
# so we can't seperate them. This lets user certs modify
# cluster things which isn't ideal but nothing we can do.
resource "vault_pki_secret_backend_role" "pki_openstack_ovn_ovsdb_intermediate_user_northd" {
  backend             = vault_mount.pki_openstack_ovn_ovsdb_intermediate.path
  name                = "user-northd"
  issuer_ref          = "default"
  ttl                 = "7776000" # 90 days
  max_ttl             = "7776000"
  allow_ip_sans       = false
  allowed_domains     = ["northd"]
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

resource "vault_pki_secret_backend_role" "pki_openstack_ovn_ovsdb_intermediate_user_neutron_controller" {
  backend             = vault_mount.pki_openstack_ovn_ovsdb_intermediate.path
  name                = "user-neutron-controller"
  issuer_ref          = "default"
  ttl                 = "7776000" # 90 days
  max_ttl             = "7776000"
  allow_ip_sans       = false
  allowed_domains     = ["neutron-controller"]
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

resource "vault_pki_secret_backend_role" "pki_openstack_ovn_ovsdb_intermediate_user_neutron_compute" {
  backend             = vault_mount.pki_openstack_ovn_ovsdb_intermediate.path
  name                = "user-neutron-compute"
  issuer_ref          = "default"
  ttl                 = "7776000" # 90 days
  max_ttl             = "7776000"
  allow_ip_sans       = false
  allowed_domains     = ["neutron-compute"]
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

resource "vault_pki_secret_backend_role" "pki_openstack_ovn_ovsdb_intermediate_user_ovn_controller" {
  backend             = vault_mount.pki_openstack_ovn_ovsdb_intermediate.path
  name                = "user-ovn-controller"
  issuer_ref          = "default"
  ttl                 = "7776000" # 90 days
  max_ttl             = "7776000"
  allow_ip_sans       = false
  allowed_domains     = ["ovn-controller"]
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
