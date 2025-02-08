terraform {
  required_providers {
    vault = {
      source = "hashicorp/vault"
    }
  }
}

module "policies" {
  source = "./policies"
}

module "roles" {
  source  = "./roles"
  backend = vault_auth_backend.cert
}
