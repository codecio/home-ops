# cloud init VM template for proxmox

Quick setup of cloud-init template in Promox.

## Create a template in proxmox with Fedora Cloud image.

        ssh root@promox-pve
        cd mkdir -p cloud-init-template
        apt install cloud-init xz-utils -y
        wget https://download.fedoraproject.org/pub/fedora/linux/releases/37/Cloud/x86_64/images/Fedora-Cloud-Base-37-1.7.x86_64.raw.xz
        unxz Fedora-Cloud-Base-37-1.7.x86_64.raw.xz
        export VM_ID="9000"
        qm create 9000 --memory 4096 --net0 virtio,bridge=vmbr0 --sockets 1 --cores 2 --vcpu 2 -hotplug network,disk,cpu,memory --agent 1 --name cloud-init-fedoracloudbase-37 --ostype l26
        qm importdisk $VM_ID Fedora-Cloud-Base-37-1.7.x86_64.raw local-lvm
        qm set $VM_ID --scsihw virtio-scsi-pci --virtio0 local-lvm:vm-$VM_ID-disk-0
        qm set $VM_ID --ide2 local-lvm:cloudinit
        qm set $VM_ID --boot c --bootdisk virtio0
        qm set $VM_ID --serial0 socket
        qm set $VM_ID --numa 1
        qm template $VM_ID
        rm Fedora-Cloud-Base-37-1.7.x86_64.raw
