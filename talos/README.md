# Talos

| Item | Value |
| --- | --- |
| Talos version | v1.14.5 |
| Schematic ID | `743d53d3c9cc1942e0a3fc7167565665ea25823e6261d82bf022e9a9e50ed84d` |
| Extensions | `siderolabs/amd-ucode`, `siderolabs/iscsi-tools`, `siderolabs/util-linux-tools` |
| PXE script | `https://pxe.factory.talos.dev/pxe/743d53d3c9cc1942e0a3fc7167565665ea25823e6261d82bf022e9a9e50ed84d/v1.14.5/metal-amd64` |

`talosctl` must match the Talos version. Check it with `talosctl version --client --short`.

## Change the extensions

1. Edit `schematic.yaml`.
2. Submit it. Image Factory returns the schematic ID, and the same file always gets the same ID.

   ```bash
   curl -X POST --data-binary @talos/schematic.yaml https://factory.talos.dev/schematics
   ```

3. Update the ID in this file and in the `dhcp-boot=tag:ipxe` line of `network/dnsmasq.conf`.

Change the Talos version in the same two places.
