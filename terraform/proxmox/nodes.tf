# kubernetes cluster control nodes
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
  memory      = 2048
  scsihw      = "virtio-scsi-pci"
  bootdisk    = "virtio0"
  onboot      = true
  ipconfig0   = "ip=${var.pm_subnet_cidr}.10${count.index}/24,gw=${var.pm_subnet_cidr}.1"
  nameserver  = var.pm_nameserver
  ciuser      = var.pm_ciuser_name
  sshkeys     = local.ssh_pub_keys

  disk {
    type    = var.pm_storage_type
    size    = var.pm_storage_size
    storage = var.pm_storage_local_lvm
  }

  network {
    model    = var.pm_nic_type
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

# kubernetes cluster worker nodes
resource "proxmox_vm_qemu" "k3s_worker_nodes" {
  name        = "k3s-worker-${count.index + 3}"
  count       = 3
  target_node = var.pm_host
  clone       = var.pm_template_name
  full_clone  = "true"
  vmid        = "10${count.index + 3}"
  agent       = 1
  os_type     = "cloud-init"
  cores       = 2
  sockets     = 1
  cpu         = "host"
  memory      = 6144
  scsihw      = "virtio-scsi-pci"
  bootdisk    = "virtio0"
  onboot      = true
  ipconfig0   = "ip=${var.pm_subnet_cidr}.10${count.index + 3}/24,gw=${var.pm_subnet_cidr}.1"
  nameserver  = var.pm_nameserver
  ciuser      = var.pm_ciuser_name
  sshkeys     = local.ssh_pub_keys

  disk {
    type    = var.pm_storage_type
    size    = var.pm_storage_size
    storage = var.pm_storage_local_lvm
  }

  network {
    model    = var.pm_nic_type
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
