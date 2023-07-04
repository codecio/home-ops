# Prepare Proxmox to be managed by Terraform

Some basic requirements to use the proxmox provider in Terraform.

## Create the user

    pveum user add terraform-prov@pve --password <password>

## Assign the user the correct role and permissions

    pveum role add TerraformProv -privs "Datastore.AllocateSpace Datastore.Audit Pool.Allocate Sys.Audit Sys.Console Sys.Modify VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.Cloudinit VM.Config.CPU VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Migrate VM.Monitor VM.PowerMgmt SDN.Allocate SDN.Audit SDN.Use"
    pveum aclmod / -user terraform-prov@pve -role TerraformProv

## Create API Token

Create the token and either pass it to env vars, sops, or some type of secrets vault.

    pveum user token add terraform-prov@pve terraform-prov-token --privsep=0
