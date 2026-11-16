# Talos

| Item | Value |
| --- | --- |
| Talos version | v1.14.5 |
| Schematic ID | `05bdd018b977b3419c717ae2dac043e6fee9317ad93ce22a4569dc3c8aaa8aed` |
| Extensions | `siderolabs/amd-ucode`, `siderolabs/iscsi-tools`, `siderolabs/realtek-firmware`, `siderolabs/util-linux-tools` |
| PXE script | `https://pxe.factory.talos.dev/pxe/05bdd018b977b3419c717ae2dac043e6fee9317ad93ce22a4569dc3c8aaa8aed/v1.14.5/metal-amd64` |

`talosctl` must match the Talos version. Check it with `talosctl version --client --short`.

## Change the extensions

1. Edit `schematic.yaml`.
2. Submit it. Image Factory returns the schematic ID, and the same file always gets the same ID.

   ```bash
   curl -X POST --data-binary @talos/schematic.yaml https://factory.talos.dev/schematics
   ```

3. Update the ID in this file, in the `dhcp-boot=tag:ipxe` line of `network/dnsmasq.conf`, and in the installer image in `talos/patches/controlplane.yaml`.

Change the Talos version in the same three places.
