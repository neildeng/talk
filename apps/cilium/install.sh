#!/usr/bin/env bash

# "---------------------------------------------------------"
# "-                                                       -"
# "-  Install cilium                                       -"
# "-                                                       -"
# "---------------------------------------------------------"

set -o errexit
set -o pipefail
set -o nounset

helm upgrade --install cilium \
   --repo=https://helm.cilium.io/ cilium \
   --namespace kube-system \
   --version 1.11.4 \
   --reuse-values \
   --values - <<EOF
image:
  pullPolicy: IfNotPresent
kubeProxyReplacement: partial
hostServices:
  enabled: "false"
externalIPs:
  enabled: "true"
nodePort:
  enabled: "true"
hostPort:
  enabled: "true"
bpf:
  masquerade: "false"
ipam:
  mode: kubernetes
hubble:
  relay:
    enabled: "true"
  ui:
    enabled: "true"
EOF