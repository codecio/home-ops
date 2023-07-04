provider "proxmox" {
  pm_api_url          = var.pm_api_url
  pm_api_token_secret = data.sops_file.pm_secrets.data["pm_api_token_secret"]
  pm_api_token_id     = data.sops_file.pm_secrets.data["pm_api_token_id"]
  pm_tls_insecure     = true
  #pm_debug = true
}

provider "curl" {
}
