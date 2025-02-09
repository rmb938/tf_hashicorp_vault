terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "4.5.0"
    }
  }

  backend "gcs" {
    bucket = "rmb-lab-tf_hashicorp_vault"
  }
}
