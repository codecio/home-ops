variable "pm_api_url" {
  description = "The Proxmox Virtual Environment API URL for target hypervisors"
  type        = string
  default     = "https://192.168.50.3:8006/api2/json"
}

variable "pm_host" {
  type    = string
  default = "pve"
}

variable "pm_template_name" {
  type    = string
  default = "cloud-init-fedoracloudbase-37"
}

variable "pm_nic_name" {
  type    = string
  default = "vmbr0"
}

variable "pm_vlan_num" {
  type    = string
  default = "40"
}
