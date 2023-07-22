#!/usr/bin/env bash

# Check if running with administrative privileges
if [[ "$(id -u)" != "0" ]]; then
    echo "Error: This script requires administrative privileges. Please run with 'sudo' or as the root user."
    exit 1
fi

set -e

# Proxmox variables
proxmox_ve_ver="8.0-2"
proxmox_ve_url_domain="http://download.proxmox.com"
proxmox_ve_url_path="/iso/"
proxmox_ve_url_base="$proxmox_ve_url_domain$proxmox_ve_url_path"
proxmox_ve_url_page="proxmox-ve_$proxmox_ve_ver.iso"
proxmox_ve_url_iso_sha256sums="SHA256SUMS"

# Internal Disks
internal_os_drive_1="disk0"
internal_os_drive_2="disk1"

# Pre-flight check: Verify device disk argument is provided.
if [[ -z "$1" ]]; then
    echo "Error: Missing device disk argument."
    echo "Example: $0 /dev/diskXYZ"
    exit 1
fi

# Check if the specified disk is an internal OS drive for a MacBook.
if [[ $1 = "$internal_os_drive_1" || $1 = "$internal_os_drive_2" ]]; then
    echo "Error: /dev/$1 is an internal OS drive for a MacBook. Aborting..."
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
read -r -n 1 -p "WARNING: You are about to erase the disk /dev/$1 and write the Proxmox VE image to it. This will result in the complete loss of all data on the disk.

**IMPORTANT**: Ensure that you have selected the correct disk, as this action cannot be undone, and all data on the selected disk will be irreversibly destroyed!

Are you absolutely sure you want to proceed? [y/N] "
echo

case $REPLY in
y | Y)
    # Check if the disk is mounted before unmounting
    if grep -qs "/dev/$1" /proc/mounts; then
        echo "Unmounting /dev/$1"
        sudo umount "/dev/$1"
    fi
    echo "Copying and imaging /dev/$1 with $proxmox_ve_url_page"
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

# Unmount the target disk after imaging.
if grep -qs "/dev/$1" /proc/mounts; then
    echo "Unmounting /dev/$1"
    sudo umount "/dev/$1"
fi

# Detach the target disk after imaging.
echo "Detaching /dev/$1"
sudo eject "/dev/$1"

# Print success message.
echo "/dev/$1 imaged with $proxmox_ve_url_page"
echo "Successfully prepared Proxmox Version: $proxmox_ve_ver"
exit 0
