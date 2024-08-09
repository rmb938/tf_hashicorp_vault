provider "vault" {
  address = "https://hashi-vault.tailnet-047c.ts.net:8200"
}

provider "tailscale" {
  // creds pulled from TAILSCALE_OAUTH_CLIENT_ID & TAILSCALE_OAUTH_CLIENT_SECRET
}
