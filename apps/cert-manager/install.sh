#!/bin/bash +x
set -e

helm upgrade --install cert-manager \
  --repo https://charts.jetstack.io cert-manager \
  --namespace cert-manager --create-namespace \
  --version v1.5.1 \
  --set installCRDs=true