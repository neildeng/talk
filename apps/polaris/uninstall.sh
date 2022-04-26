#!/bin/bash +x
set -e

# remove release
helm uninstall polaris --namespace polaris --wait || true

# remove secret
kubectl -n polaris delete cm mkcertrootca || true
kubectl -n polaris delete secret polaris-tls || true

# remove pvc
kubectl -n polaris get pvc | awk '{print $1}' | grep -v NAME | while read -r pvc
do
  kubectl -n polaris delete pvc $pvc
done

kubectl delete ns polaris || true
