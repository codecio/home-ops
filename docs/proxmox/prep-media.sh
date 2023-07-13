#!/usr/bin/env bash

# proxmox variables
proxmox_ve_ver="8.0-2"
proxmox_ve_url_domain="http://download.proxmox.com"
proxmox_ve_url_path="/iso/"
proxmox_ve_url_base="$proxmox_ve_url_domain$proxmox_ve_url_path"
proxmox_ve_url_page="proxmox-ve_$proxmox_ve_ver.iso"
proxmox_ve_url_iso_sha256sums="SHA256SUMS"

# Pre-flight check argument is valid.
disk_target=$1

if [[ -z "$1" ]]; then
    echo -e 'Missing devicedisk argument.\n\tExample: ./prep-media.sh /dev/diskXYZ\nAborting...'
    exit 1
fi

if [[ $1 = "disk0" || $1 = "disk1" ]]; then
    echo -e '/dev/disk0 or /dev/disk1 are internal OS drives for a MacBook. Aborting...'
    exit 1
fi

# Simple URL Validation
function validate_url() {
    wget --spider "$1" >/dev/null 2>&1
    return $?
}

if validate_url $proxmox_ve_url_base$proxmox_ve_url_page; then
    # Get page and check if file already exists in current working directory.
    wget --no-clobber $proxmox_ve_url_base$proxmox_ve_url_page
else
    # Print error message.
    command && echo "download error: validation failed." && exit 1
fi

# Extract and match iso version with sha256sum.
extracted_iso_shasum=$(curl -s $proxmox_ve_url_base$proxmox_ve_url_iso_sha256sums |
    grep "$proxmox_ve_url_page" |
    cut -f 1 -d ' ')

function verify_iso() {
    echo "$1" "*$2" | shasum -a 256 --check
}

if verify_iso "$extracted_iso_shasum" "$proxmox_ve_url_page"; then
    echo "shasum verified: OK"
else
    echo "shasum verified: NO" && exit 1
fi

# Select USB Disk target

read -r -n1 -p "You are about to erase /dev/$disk_target. Are you sure? [y/N] "
echo
case $REPLY in
y | Y)
    echo "Copy and convert /dev/$disk_target with $proxmox_ve_url_page "
    ;;
*)
    echo "Aborting..."
    exit
    ;;
esac

# Simple image file copy to USB flash drive.
function create_usb() {
    sudo dd bs=100M if=./$proxmox_ve_url_page of=/dev/"$1" status=progress
}

if create_usb "$disk_target"; then
    # USB imaged
    echo "/dev/$disk_target imaged with $proxmox_ve_url_page"
else
    # Print error message.
    echo "/dev/$disk_target failed imaged with $proxmox_ve_url_page Aborting..." && exit 1
fi

# Print success or exit for any errors.
if [ $? -eq 0 ]; then
    echo "Successfully prepared Proxmox Version: $proxmox_ve_ver"
else
    echo "Could not prepare Proxmox Version: $proxmox_ve_ver" >&2
fi
