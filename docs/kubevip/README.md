# kube-vip setup

Create manifest for [kube-vip daemonset](https://kube-vip.io/docs/installation/daemonset/).

## generate manifest

Set vars, pull kube-vip image, and generate the manifest.

```sh
export VIP=192.168.40.110
export INTERFACE=eth0
KVVERSION=$(curl -sL https://api.github.com/repos/kube-vip/kube-vip/releases | jq -r ".[0].name")
alias kube-vip="ctr image pull ghcr.io/kube-vip/kube-vip:$KVVERSION; ctr run --rm --net-host ghcr.io/kube-vip/kube-vip:$KVVERSION vip /kube-vip"

kube-vip manifest daemonset \
      --interface $INTERFACE \
      --address $VIP \
      --inCluster \
      --taint \
      --controlplane \
      --services \
      --arp \
      --leaderElection | tee ./kube-vip.yaml
```

## verify

Couple quick commmands to verify rbac and daemonset deployed.

```sh
sudo kubectl get clusterroles system:kube-vip-role -o yaml
kubectl get daemonset kube-vip -n kube-system
sudo k3s crictl images
sudo k3s crictl ps
sudo journalctl -e -u k3s
```
