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
  default = "ubuntu-20.04-cloudimg-template"
}

variable "pm_nic_name" {
  type    = string
  default = "vmbr0"
}

variable "pm_vlan_num" {
  type    = string
  default = "40"
}

variable "pm_subnet_cidr" {
  type    = string
  default = "192.168.40"
}

variable "pm_storage_data_zfs_sda" {
  type    = string
  default = "data_zfs_sda"
}

variable "pm_storage_data_zfs_sdb" {
  type    = string
  default = "data_zfs_sdb"
}
