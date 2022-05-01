#!/usr/bin/env bash

# "---------------------------------------------------------"
# "-                                                       -"
# "-  Uninstall metallb                                   -"
# "-                                                       -"
# "---------------------------------------------------------"

set -o errexit
set -o pipefail
set -o nounset

WORKDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$WORKDIR"

kubectl delete -f https://kind.sigs.k8s.io/examples/loadbalancer/usage.yaml
kubectl delete -f metallb-configmap.yaml
kubectl delete -f https://raw.githubusercontent.com/metallb/metallb/v0.12.1/manifests/metallb.yaml
kubectl delete -f https://raw.githubusercontent.com/metallb/metallb/v0.12.1/manifests/namespace.yaml
