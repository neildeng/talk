#!/bin/bash +x
set -e

# remove release
helm uninstall plg-stack --namespace observability --wait || true

# remove secret
kubectl -n observability delete cm mkcertrootca || true
kubectl -n observability delete secret observability-tls || true

# remove pvc
kubectl -n observability get pvc | awk '{print $1}' | grep -v NAME | while read -r pvc
do
  kubectl -n observability delete pvc $pvc
done

kubectl delete ns observability || true
