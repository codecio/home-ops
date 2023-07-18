# 🏠 home-ops

My monorepo project for the homelab with a focus on using GitOps practices with [Kubernetes](https://kubernetes.io/) to learn new tools and tech.

## 📖 Docs

At some point I'm going clean up the chicken scratch notes markdown files in [docs/](docs) and render them in some fancy way. The focus for now is getting k3s up.

## 🕸️ Networking

| Name                                          | CIDR              |
|-----------------------------------------------|-------------------|
| Management VLAN                               | `192.168.50.0/24` |
| Kubernetes Nodes VLAN                         | `192.168.40.0/24` |

### 🗺️ IPAM Details

| Name                                          | CIDR               |
|-----------------------------------------------|--------------------|
| EdgeRouter X (Default Gateway & DNS Resolver) | `192.168.40.1/24`  |
| Proxmox VE 8.0                                | `192.168.40.3/24`  |
| Kubernetes Control Node 1                     | `192.168.40.100`  |
| Kubernetes Control Node 2                     | `192.168.40.101`  |
| Kubernetes Control Node 3                     | `192.168.40.102`  |
| Kubernetes Worker Node 1                      | `192.168.40.103`  |
| Kubernetes Worker Node 2                      | `192.168.40.104`  |
| Kubernetes Worker Node 3                      | `192.168.40.105`  |
| Kube VIP Address IP                           | `192.168.40.110`  |

## 🤝 Inspiration and Thanks

Thanks to the awesome folks working on ([flux-cluster-template](https://github.com/onedr0p/flux-cluster-template)), Many others shared homelab projects ([k8s-at-home](https://github.com/topics/k8s-at-home)), and community at ([k8s@home](https://discord.gg/k8s-at-home)) Discord server.
