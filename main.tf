terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "4.5.0"
    }

    tailscale = {
      source  = "tailscale/tailscale"
      version = "0.17.2"
    }
  }

  backend "gcs" {
    bucket = "rmb-lab-tf_hashicorp_vault"
  }
}

module "auth" {
  source = "./auth"
}

module "secret_engine" {
  source = "./secret_engine"
}
