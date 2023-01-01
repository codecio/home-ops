#!/usr/bin/env bash

# variables
fedora_cb_ver="37-1.7"
fedora_cb_url_domain="https://download.fedoraproject.org"
fedora_cb_url_path="/pub/fedora/linux/releases/37/Cloud/x86_64/images/"
fedora_cb_url_base="$fedora_cb_url_domain$fedora_cb_url_path"
fedora_cb_url_file="Fedora-Cloud-Base-$fedora_cb_ver.x86_64.raw.xz"
fedora_cb_url_file_raw="Fedora-Cloud-Base-$fedora_cb_ver.x86_64.raw"
fedora_cd_import_disk_target="data_zfs_sdb"
fedora_vm_id=9000

# setup
apt install cloud-init xz-utils libguestfs-tools -y
wget --no-clobber $fedora_cb_url_base$fedora_cb_url_file
unxz $fedora_cb_url_file
virt-customize -a "$fedora_cb_url_file_raw" --install qemu-guest-agent
qm create $fedora_vm_id \
--memory 4096 --sockets 1 --cores 2 --vcpu 2 \
--net0 virtio,bridge=vmbr0 \
--hotplug network,disk,cpu,memory \
--agent 1 \
--name fedora-cloud-base-37-cloudinit-template \
--ostype l26
qm importdisk $fedora_vm_id $fedora_cb_url_file_raw $fedora_cd_import_disk_target
qm set $fedora_vm_id --scsihw virtio-scsi-pci --virtio0 $fedora_cd_import_disk_target:vm-$fedora_vm_id-disk-0
qm set $fedora_vm_id --ide2 $fedora_cd_import_disk_target:cloudinit
qm set $fedora_vm_id --boot c --bootdisk virtio0
qm set $fedora_vm_id --serial0 socket
qm set $fedora_vm_id --numa 1
qm template $fedora_vm_id

# clean up
rm -f Fedora-Cloud-Base-37-1.7.x86_64.raw.xz
rm -f Fedora-Cloud-Base-37-1.7.x86_64.raw