terraform {
  cloud {
    hostname     = "app.terraform.io"
    organization = "codecio"
    workspaces {
      name = "homelab-infra-proxmox"
    }
  }
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "2.9.11"
    }
    sops = {
      source  = "carlpett/sops"
      version = "0.7.1"
    }
  }
  required_version = ">= 1.3.0"
}

data "sops_file" "pm_secrets" {
  source_file = "secret.sops.yaml"
}
