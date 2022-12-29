# Proxmox Inital configuration

Configuration and Script to prep for proxmox VE installation media.

## Usage example

Find and confirm target disk to be imaged.

:warning: Be very careful to not override the wrong disk.

    diskutil list
    diskutil unmountDisk /dev/disk2
    ./prep-media.sh disk2
    diskutil eject /dev/disk2

## TODO

- [x] Initial ISO prep.
- [x] Initial NIC Config.
- [ ] Optimize and add NIC teaming support or LACP.
- [ ] Add PXE support and cloudinit for zero touch bootstrapping.