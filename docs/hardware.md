# Hardware

One row per node. Fill in a cell when you read the value from the unit, its BIOS, or `talosctl` in maintenance mode.

| Hostname | BIOS | CPU | RAM | NIC and driver | NIC MAC | NIC speed | Disks | IP |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| motoko-01 | SER9L104 | | | | 78:55:36:09:6b:c2 | | | 192.168.10.11 |
| batou-02 | SER9L104 | | | | | | | 192.168.10.12 |
| togusa-03 | SER9L104 | Ryzen 7 255, 8C/16T | 24 GiB | `enp3s0`, RTL8125B (`r8169`) | 78:55:36:09:6b:4e | 2.5 Gb/s | `nvme0n1`, 1 TB Crucial CT1000E100SSD8 | 192.168.10.13 |

Flag any NIC that links below 2.5 Gb/s.
