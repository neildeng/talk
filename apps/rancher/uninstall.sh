#!/usr/bin/env bash

# "---------------------------------------------------------"
# "-                                                       -"
# "-  Uninstall Rancher                                    -"
# "-                                                       -"
# "---------------------------------------------------------"

set -o errexit
set -o pipefail
set -o nounset

# remove release
helm uninstall rancher --namespace cattle-system --wait || true

# remove secret
kubectl -n cattle-system delete secret tls-rancher-ingress|| true
kubectl -n cattle-system create secret tls-ca || true
kubectl -n cattle-system create secret tls-ca-additional || true

# remove pvc
kubectl -n cattle-system get pvc | awk '{print $1}' | grep -v NAME | while read -r pvc
do
  kubectl -n cattle-system  delete pvc $pvc
done

kubectl delete ns cattle-system || true