#!/usr/bin/env bash

# "---------------------------------------------------------"
# "-                                                       -"
# "-  Release ingress-nginx                                -"
# "-                                                       -"
# "---------------------------------------------------------"

set -o errexit
set -o pipefail
set -o nounset

WORKDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$WORKDIR"

#kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/cloud/deploy.yaml

helm upgrade --install ingress-nginx \
  --repo=https://kubernetes.github.io/ingress-nginx ingress-nginx \
  --namespace ingress-nginx --create-namespace \
  --version "4.0.19" \
  --values - <<EOF
defaultBackend:
  enabled: true
---
EOF