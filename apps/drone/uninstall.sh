#!/usr/bin/env bash

# "---------------------------------------------------------"
# "-                                                       -"
# "-  Uninstall drone                                      -"
# "-                                                       -"
# "---------------------------------------------------------"

set -o errexit
set -o pipefail
set -o nounset

WORKDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$WORKDIR"

helm --namespace drone uninstall drone-runner  || true
helm --namespace drone uninstall drone || true

kubectl -n drone delete configmap mkcertrootca || true
kubectl -n drone delete secret drone-tls || true

kubectl -n drone get pvc | awk '{print $1}' | grep -v NAME | while read -r pvc
do
  kubectl -n drone delete pvc $pvc
done

kubectl delete ns drone
