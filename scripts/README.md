# Create installation media

Script to prep for proxmox VE installation media.

## Usage example

Find and confirm target disk to be imaged.

:warning: Be very careful to not override the wrong disk.

    diskutil list
    diskutil unmountDisk /dev/disk2
    ./prep-media.sh disk2

## TODO

- [ ] Add PXE support for zero touch provisioning.