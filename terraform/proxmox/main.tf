terraform {
  cloud {
    hostname     = "app.terraform.io"
    organization = "codecio"
    workspaces {
      name = "home-ops-proxmox"
    }
  }
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "2.9.14"
    }
    sops = {
      source  = "carlpett/sops"
      version = "0.7.2"
    }
    curl = {
      source  = "anschoewe/curl"
      version = "1.0.2"
    }
  }
  required_version = ">= 1.3.0"
}

data "sops_file" "pm_secrets" {
  source_file = "secret.sops.yaml"
}
