#!/usr/bin/env bash

# Set script variables
image_url_domain="https://cloud-images.ubuntu.com"
image_url_path="/jammy/current/"
image_url_base="$image_url_domain$image_url_path"
image_file="jammy-server-cloudimg-amd64.img"
image_import_disk_target="local-lvm"
vm_id=9000
template_name="ubuntu-22.04-cloudimg-template"

# Setup PVE packages required
apt install cloud-init xz-utils libguestfs-tools -y

# Pull image from ubuntu repo
wget --no-clobber $image_url_base$image_file

# Install qemu-guest-agent to bake into img
virt-customize -a $image_file --install qemu-guest-agent

# Create VM
qm create $vm_id \
--memory 4096 --sockets 1 --cores 2 --vcpu 2 \
--net0 virtio,bridge=vmbr0 \
--hotplug network,disk,cpu,memory \
--agent 1 \
--name $template_name \
--ostype l26

# Import Image
qm importdisk $vm_id $image_file $image_import_disk_target

# Bind image to a storage device
qm set $vm_id --scsihw virtio-scsi-pci --virtio0 $image_import_disk_target:vm-$vm_id-disk-0

# Add drive for cloud-init
qm set $vm_id --ide2 $image_import_disk_target:cloudinit

# Configure VM to boot from image
qm set $vm_id --boot c --bootdisk virtio0

# Add a serial console socket
qm set $vm_id --serial0 socket

# Convert the VM to a template
qm template $vm_id

# Clean up img file
rm -f jammy-server-cloudimg-amd64.img
