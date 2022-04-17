#!/bin/bash +x
set -e

cd "$(dirname "$0")"

kubectl create ns cattle-system

kubectl -n cattle-system create secret tls tls-rancher-ingress --cert=./../../tls/k8s.edu.local+1.pem --key=./../../tls/k8s.edu.local+1-key.pem
kubectl -n cattle-system create secret generic tls-ca --from-file=cacerts.pem=./../../tls/testGRCA4.pem
kubectl -n cattle-system create secret generic tls-ca-additional --from-file=ca-additional.pem=./../../tls/testGRCA4.pem

helm upgrade --install rancher \
  --repo=https://releases.rancher.com/server-charts/stable rancher \
  --namespace cattle-system --create-namespace \
  --set hostname=rancher.k8s.edu.local \
  --set ingress.tls.source=secret \
  --set ingress.tls.secretName=tls-rancher-ingress \
  --set rancherImage=registry.localhost:5000/rancher/rancher \
  --set systemDefaultRegistry=registry.localhost:5000 \
  --set bootstrapPassword="1qaz@WSX#EDC" \
  --set privateCA=true \
  --set replicas=3
  