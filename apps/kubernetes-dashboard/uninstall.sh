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

helm -n kubernetes-dashboard uninstall kubernetes-dashboard || true

kubectl -n kubernetes-dashboard delete secret tls-ca || true
kubectl -n kubernetes-dashboard delete secret kubernetes-dashboard-tls || true

kubectl delete ns kubernetes-dashboard || true