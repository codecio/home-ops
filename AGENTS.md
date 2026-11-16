# home-ops

A 3-node Talos Kubernetes lab on Beelink SER9 Pro mini PCs.

The lab runs on one of two networks:

- At home, a dedicated static network. It isn't built yet.
- When traveling, the MacBook is the gateway.

Both networks use the addresses below, so the cluster runs the same on either one.

## Layout

- `README.md` has the setup steps in order: lab network, BIOS, and Talos.
- `docs/hardware.md` records each unit's BIOS version, NIC, and disks.
- `network/dnsmasq.conf` is the DHCP, DNS, and PXE config for the lab segment.
- `scripts/lab-net-up.sh` and `scripts/lab-net-down.sh` turn the MacBook gateway on and off.
- `scripts/lab-net.env` holds the values both scripts share.
- `talos/schematic.yaml` lists the Talos extensions. `talos/README.md` records the Talos version and the schematic ID.

## Lab network

| Address | Use |
| --- | --- |
| 192.168.10.1 | Gateway. When traveling, the MacBook on `en13` also serves DHCP, DNS, and PXE. |
| 192.168.10.10 | `section9`, the Kubernetes API VIP. DHCP never hands it out. |
| 192.168.10.11 | `motoko-01` |
| 192.168.10.12 | `batou-02` |
| 192.168.10.13 | `togusa-03` |
| 192.168.10.100 to 192.168.10.150 | DHCP pool for first boot |

When the MacBook is the gateway, it NATs 192.168.10.0/24 out of the interface that holds the default route.

## Rules

- Scope every MacBook network change to `en13`. Don't touch Wi-Fi or other network services.
- Keep MacBook changes non-persistent and reversible, such as `sysctl -w` and the `com.apple/lab-nat` pf anchor. Don't edit `/etc/pf.conf` or other system files, and don't use `brew services`.
- Show every `sudo` command before it runs.
- Before `diskutil erase*` or `dd`, run `diskutil list`, name the target disk and why (external, physical, size), and wait for confirmation. Never touch `disk0`, an internal disk, or an APFS container.
- Never commit secrets or large binaries. Keep Talos secrets outside the repo.
- Keep serial numbers out of the repo.
- Don't pick or download BIOS files. The operator supplies them.
- Keep the lab segment behind NAT. The Talos maintenance API on port 50000 has no authentication.
- `talosctl` must match the Talos version in `talos/README.md`.

## Git

- Start each change on a branch from an up-to-date `main`: `git switch main && git pull --ff-only && git switch -c <type>/<slug>`. The slug is 2 to 4 words, such as `feat/lab-network`.
- `main` changes only through a PR. Push with `git push -u origin HEAD`, then run `gh pr create --fill`.
- Write commit messages as [Conventional Commits 1.0](https://www.conventionalcommits.org/en/v1.0.0/): `<type>(<scope>): <summary>`.
  - Types are `feat`, `fix`, `docs`, `refactor`, `chore`, `ci`, and `revert`. Use `chore(deps)` for version bumps.
  - The scope is optional and names the area: `network`, `scripts`, `talos`, or `docs`.
  - The summary is imperative and lowercase, with no trailing period and at most 72 characters.
  - The body explains why.
  - A change that forces a cluster rebuild gets `!` after the type or scope and a `BREAKING CHANGE:` footer that names the steps.
- Make one logical change per commit.

## Keep the docs current

When a change adds a rule or an address, update this file in the same commit. When it adds or changes a setup step, update `README.md`. When it adds or changes a component, a connection, or a boot step, update the Mermaid diagrams in `README.md`.

This file is the only agent instructions file. `CLAUDE.md` only points Claude Code at it. Don't add tool-specific rule files.
