#!/usr/bin/env bash

# "---------------------------------------------------------"
# "-                                                       -"
# "-  Patch ingress-nginx                                  -"
# "-                                                       -"
# "---------------------------------------------------------"

set -o errexit
set -o pipefail
set -o nounset

WORKDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$WORKDIR"

INTERNAL_IP=$(kubectl get nodes -o wide | grep control-plane | awk '{print $6}')

kubectl -n ingress-nginx patch svc ingress-nginx-controller \
  -p '{"spec":{"externalIPs":["'"$INTERNAL_IP"'"]}}'

