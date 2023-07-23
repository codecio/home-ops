#!/usr/bin/env bash

set -e  # Exit immediately on error

# Set script variables
IMAGE_URL_DOMAIN="https://cloud-images.ubuntu.com"
IMAGE_URL_PATH="/jammy/current/"
IMAGE_URL_BASE="$IMAGE_URL_DOMAIN$IMAGE_URL_PATH"
IMAGE_FILE="jammy-server-cloudimg-amd64.img"
IMAGE_IMPORT_DISK_TARGET="local-lvm"
VM_ID=9000
TEMPLATE_NAME="ubuntu-22.04-cloudimg-template"

# Setup PVE packages required
apt-get install -y libguestfs-tools

# Pull image from ubuntu repo if it doesn't exist
if [ ! -f "$IMAGE_FILE" ]; then
    wget --no-clobber "$IMAGE_URL_BASE$IMAGE_FILE"
fi

# Install qemu-guest-agent to bake into img
virt-customize -a "$IMAGE_FILE" --install qemu-guest-agent

# Create VM
qm create $VM_ID \
    --memory 4096 --sockets 1 --cores 2 --vcpu 2 \
    --net0 virtio,bridge=vmbr0 \
    --hotplug network,disk,cpu,memory \
    --agent 1 \
    --name "$TEMPLATE_NAME" \
    --ostype l26

# Import Image
qm importdisk $VM_ID $IMAGE_FILE $IMAGE_IMPORT_DISK_TARGET

# Bind image to a storage device
qm set $VM_ID --scsihw virtio-scsi-pci --virtio0 "$IMAGE_IMPORT_DISK_TARGET:vm-$VM_ID-disk-0"

# Add drive for cloud-init
qm set $VM_ID --ide2 "$IMAGE_IMPORT_DISK_TARGET:cloudinit"

# Configure VM to boot from image
qm set $VM_ID --boot c --bootdisk virtio0

# Add a serial console socket
qm set $VM_ID --serial0 socket

# Convert the VM to a template
qm template $VM_ID

# Clean up img file
rm -f "$IMAGE_FILE"
