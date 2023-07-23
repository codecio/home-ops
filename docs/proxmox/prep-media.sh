#!/usr/bin/env bash

# Define color codes for messages
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Function to print error messages in red
function print_error() {
    echo -e "${RED}[Error] $1${NC}"
}

# Function to print success messages in green
function print_success() {
    echo -e "${GREEN}[Success] $1${NC}"
}

# Check if running with administrative privileges
if [[ "$(id -u)" != "0" ]]; then
    print_error "This script requires administrative privileges. Please run with 'sudo' or as the root user."
    exit 1
fi

set -e

# Function to display the list of external physical disks in a table format.
function list_external_physical_disks() {
    echo "Listing External Physical Disks:"
    local disks=()
    while read -r line; do
        disks+=("$line")
    done < <(diskutil list | grep "(external, physical)")

    # Check if any disks were found.
    if [[ ${#disks[@]} -eq 0 ]]; then
        print_error "No external physical disks found."
        exit 1
    fi

    # Display disks in a table with numbers.
    echo "+----+----------------------+"
    echo "| No | Disk Identifier      |"
    echo "+----+----------------------+"
    local counter=1
    for disk in "${disks[@]}"; do
        printf "| %-2d | %-20s |\n" "$counter" "$disk"
        counter=$((counter + 1))
    done
    echo "+----+----------------------+"
}

# Function to prompt the user for disk selection and set it as the disk_device.
function select_disk_device() {
    local total_disks
    total_disks=$(diskutil list | grep -c "(external, physical)")
    read -rp "Enter the number of the disk you want to use (e.g., 1, 2, 3): " choice

    # Validate user input as an integer within the valid range.
    if [[ ! $choice =~ ^[0-9]+$ || $choice -lt 1 || $choice -gt $total_disks ]]; then
        print_error "Invalid selection. Please enter a number between 1 and $total_disks."
        exit 1
    fi

    # Get the selected disk identifier from the list.
    disk_device=$(diskutil list | grep "(external, physical)" | sed -n "${choice}p" | awk '{print $1}')
    print_success "Selected Disk: $disk_device"
}

# Disk logic setup
list_external_physical_disks
select_disk_device

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

# Check if the specified disk is an internal OS drive for a MacBook.
if [[ $disk_device = "$internal_os_drive_1" || $disk_device = "$internal_os_drive_2" ]]; then
    print_error "$disk_device is an internal OS drive for a MacBook. Aborting..."
    exit 1
fi

# Check if the provided argument is a valid block device.
if [[ ! -b "$disk_device" ]]; then
    print_error "The specified device '$disk_device' is not a valid block device."
    exit 1
fi

# Simple URL validation
function validate_url() {
    wget --spider "$1" >/dev/null 2>&1
}

if ! validate_url "$proxmox_ve_url_base$proxmox_ve_url_page"; then
    print_error "Proxmox VE ISO download validation failed."
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
    print_error "SHA256 verification failed for the downloaded ISO. Aborting.."
    exit 1
fi

# Prompt user for confirmation before erasing the specified disk.
read -r -n 1 -p "WARNING: You are about to erase the disk $disk_device and write the Proxmox VE image to it. This will result in the complete loss of all data on the disk.

**IMPORTANT**: Ensure that you have selected the correct disk, as this action cannot be undone, and all data on the selected disk will be irreversibly destroyed!

Are you absolutely sure you want to proceed? [y/N] "
echo

case $REPLY in
y | Y)
    # Check if the disk is mounted before unmounting
    if mount | grep -qs "$disk_device"; then
        echo "Unmounting $disk_device"
        sudo diskutil unmountDisk "$disk_device"
    fi
    echo "Copying and imaging $disk_device with $proxmox_ve_url_page"
    ;;
*)
    echo "Aborting..."
    exit
    ;;
esac

# Image the ISO to the USB flash drive.
function create_usb() {
    sudo dd bs=100M if="./$proxmox_ve_url_page" of="$disk_device" status=progress
}

if ! create_usb "$disk_device"; then
    print_error "Error: $disk_device failed to be imaged with $proxmox_ve_url_page. Aborting..."
    exit 1
fi

# Unmount the target disk after imaging.
if mount | grep -qs "$disk_device"; then
    echo "Unmounting $disk_device"
    sudo diskutil unmountDisk "$disk_device"
fi

# Detach the target disk after imaging.
echo "Detaching $disk_device"
sudo diskutil eject "$disk_device"

# Display a summary report after successful completion.
echo "===== Summary Report ====="
print_success "Disk: $disk_device"
print_success "Proxmox Version: $proxmox_ve_ver"
print_success "Successfully prepared Proxmox VE USB flash drive."
echo "=========================="
exit 0
