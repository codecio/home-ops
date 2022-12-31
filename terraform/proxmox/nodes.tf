resource "proxmox_vm_qemu" "k3s_control_nodes" {
  name        = "k3s-control-${count.index}"
  count       = 3
  target_node = var.pm_host
  clone       = var.pm_template_name
  full_clone  = "true"
  vmid        = "10${count.index}"
  agent       = 1
  os_type     = "cloud-init"
  cores       = 2
  sockets     = 1
  cpu         = "host"
  numa        = true
  memory      = 4096
  scsihw      = "virtio-scsi-pci"
  bootdisk    = "virtio0"
  ipconfig0   = "ip=${var.pm_subnet_cidr}.10${count.index}/24,gw=${var.pm_subnet_cidr}.1"
  nameserver  = "8.8.8.8,1.1.1.1"
  onboot      = true
  ssh_user    = "ansible"
  sshkeys     = local.ssh_pub_keys

  disk {
    slot    = 0
    size    = "50G"
    type    = "scsi"
    storage = var.pm_storage_data_zfs_sda
    ssd     = 1
    discard = "on"
  }

  network {
    model    = "virtio"
    bridge   = var.pm_nic_name
    tag      = var.pm_vlan_num
    firewall = false
  }

  lifecycle {
    ignore_changes = [
      network,
    ]
  }
}
