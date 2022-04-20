#!/bin/bash +x
set -e

helm uninstall harbor --namespace harbor || true

kubectl -n harbor delete secret harbor-tls || true
kubectl -n harbor delete secret mkcertrootca-ca-tls || true
kubectl -n harbor delete configmap mkcertrootca || true
kubectl -n harbor get pvc | awk '{print $1}' | grep -v NAME | while read -r pvc
do
  kubectl -n harbor delete pvc $pvc
done
