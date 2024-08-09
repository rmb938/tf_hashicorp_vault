terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "4.4.0"
    }

    tailscale = {
      source  = "tailscale/tailscale"
      version = "0.16.2"
    }
  }

  backend "gcs" {
    bucket      = "rmb-lab-tf_hashicorp_vault"
    credentials = "secrets/decrypted/terraform-state-sa.json"
  }
}

module "auth" {
  source = "./auth"
}
