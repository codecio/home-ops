resource "proxmox_vm_qemu" "pm_test" {
  name        = "k3s-vm-${count.index + 1}"
  count       = 1
  target_node = var.pm_host
  clone       = var.pm_template_name
  full_clone  = "true"
  agent       = 1
  os_type     = "cloud-init"
  cores       = 2
  sockets     = 1
  cpu         = "host"
  memory      = 4096
  scsihw      = "virtio-scsi-pci"
  bootdisk    = "scsi0"

  disk {
    slot    = 0
    size    = "55G"
    type    = "scsi"
    storage = "data_zfs_sda"
    ssd     = 1
    discard = "on"
  }

  network {
    model  = "virtio"
    bridge = var.pm_nic_name
    tag    = var.pm_vlan_num
  }

  lifecycle {
    ignore_changes = [
      network,
    ]
  }
}
