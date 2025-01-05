terraform {
  required_providers {
    vault = {
      source = "hashicorp/vault"
    }

    tailscale = {
      source = "tailscale/tailscale"
    }
  }
}
