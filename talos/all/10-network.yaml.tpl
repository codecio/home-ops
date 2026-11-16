apiVersion: v1alpha1
kind: LinkConfig
name: enp3s0
addresses:
  - address: {{ .Node.IP }}/24
routes:
  - gateway: 192.168.10.1
---
apiVersion: v1alpha1
kind: ResolverConfig
nameservers:
  - address: 192.168.10.1
