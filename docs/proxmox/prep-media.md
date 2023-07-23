# Proxmox Inital configuration

Configuration and Script to prep for proxmox VE installation media.

## Usage example

Find and confirm target disk to be imaged ad-hoc if you want. Otherwise the script will display all valid external physical block devices to be imaged.

:warning: Be very careful to not override the wrong disk. The prepare-media utility will unmount and eject the target disk.

    ./prep-media.sh

## TODO

- [x] Initial ISO prep.
- [x] Initial NIC Config.
- [ ] Optimize and add NIC teaming support or LACP.
- [ ] Add PXE support and cloudinit for zero touch bootstrapping.
