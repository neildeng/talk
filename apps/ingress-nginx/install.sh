#!/bin/bash +x
set -e

cd "$(dirname "$0")"

#kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/cloud/deploy.yaml

helm upgrade --install ingress-nginx \
  --repo=https://kubernetes.github.io/ingress-nginx ingress-nginx \
  --namespace ingress-nginx --create-namespace \
  --version "4.0.19" \
  --values - <<EOF
---
EOF