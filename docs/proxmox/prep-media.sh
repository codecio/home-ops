#!/usr/bin/env bash

set -e

# Proxmox variables
proxmox_ve_ver="8.0-2"
proxmox_ve_url_domain="http://download.proxmox.com"
proxmox_ve_url_path="/iso/"
proxmox_ve_url_base="$proxmox_ve_url_domain$proxmox_ve_url_path"
proxmox_ve_url_page="proxmox-ve_$proxmox_ve_ver.iso"
proxmox_ve_url_iso_sha256sums="SHA256SUMS"

# Pre-flight check: Verify device disk argument is provided.
if [[ -z "$1" ]]; then
    echo "Error: Missing device disk argument."
    echo "Example: $0 /dev/diskXYZ"
    exit 1
fi

# Check if the specified disk is an internal OS drive for a MacBook.
if [[ $1 = "disk0" || $1 = "disk1" ]]; then
    echo "/dev/disk0 or /dev/disk1 are internal OS drives for a MacBook. Aborting..."
    exit 1
fi

# Simple URL validation
function validate_url() {
    wget --spider "$1" >/dev/null 2>&1
}

if ! validate_url "$proxmox_ve_url_base$proxmox_ve_url_page"; then
    echo "Error: Proxmox VE ISO download validation failed."
    exit 1
fi

# Download the Proxmox VE ISO file if it doesn't exist in the current working directory.
wget --no-clobber "$proxmox_ve_url_base$proxmox_ve_url_page"

# Extract and match the ISO version with the sha256sum.
extracted_iso_shasum=$(curl -s "$proxmox_ve_url_base$proxmox_ve_url_iso_sha256sums" |
    grep "$proxmox_ve_url_page" |
    cut -f 1 -d ' ')

function verify_iso() {
    echo "$1 *$2" | shasum -a 256 --check
}

if ! verify_iso "$extracted_iso_shasum" "$proxmox_ve_url_page"; then
    echo "Error: SHA256 verification failed for the downloaded ISO. Aborting.."
    exit 1
fi

# Prompt user for confirmation before erasing the specified disk.
read -r -n 1 -p "You are about to erase /dev/$1. Are you sure? [y/N] "
echo

case $REPLY in
y | Y)
    echo "Copying and converting /dev/$1 with $proxmox_ve_url_page"
    ;;
*)
    echo "Aborting..."
    exit
    ;;
esac

# Image the ISO to the USB flash drive.
function create_usb() {
    sudo dd bs=100M if="./$proxmox_ve_url_page" of="/dev/$1" status=progress
}

if ! create_usb "$1"; then
    echo "Error: /dev/$1 failed to be imaged with $proxmox_ve_url_page. Aborting..."
    exit 1
fi

# Print success message.
echo "/dev/$1 imaged with $proxmox_ve_url_page"
echo "Successfully prepared Proxmox Version: $proxmox_ve_ver"
exit 0
