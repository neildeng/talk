#!/bin/bash +x
set -e

helm uninstall keycloak --namespace keycloak || true

kubectl -n keycloak delete secret keycloak-tld-secret || true
kubectl -n keycloak get pvc | awk '{print $1}' | grep -v NAME | while read -r pvc
do
  kubectl -n keycloak delete pvc $pvc
done
