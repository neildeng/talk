#!/usr/bin/env bash

# "---------------------------------------------------------"
# "-                                                       -"
# "-  Kubernetes Dashboard                                 -"
# "-                                                       -"
# "---------------------------------------------------------"

set -o errexit
set -o pipefail
set -o nounset

WORKDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$WORKDIR"

kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.12.1/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.12.1/manifests/metallb.yaml
docker network inspect -f '{{.IPAM.Config}}' kind
kubectl apply -f metallb-configmap.yaml
kubectl apply -f https://kind.sigs.k8s.io/examples/loadbalancer/usage.yaml