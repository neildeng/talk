#!/usr/bin/env bash

# "---------------------------------------------------------"
# "-                                                       -"
# "-  Release Rancher                                      -"
# "-                                                       -"
# "---------------------------------------------------------"

set -o errexit
set -o pipefail
set -o nounset

WORKDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$WORKDIR"

kubectl create ns cattle-system || true

kubectl -n cattle-system create secret tls tls-rancher-ingress --cert=./../../tls/rancher.k8s.edu.local.pem --key=./../../tls/rancher.k8s.edu.local-key.pem || true
kubectl -n cattle-system create secret generic tls-ca --from-file=cacerts.pem="$(mkcert --CAROOT)/rootCA.pem" || true
kubectl -n cattle-system create secret generic tls-ca-additional --from-file=ca-additional.pem="$(mkcert --CAROOT)/rootCA.pem" || true

helm upgrade --install rancher \
  --repo=https://releases.rancher.com/server-charts/stable rancher \
  --namespace cattle-system --create-namespace \
  --value - <<EOF
replicas: 1
privateCA: "true"
bootstrapPassword: "1qaz@WSX#EDC"
hostname: rancher.k8s.edu.local
ingress:
  extraAnnotations:
    kubernetes.io/ingress.class: nginx
  tls:
    source: secret
    secretName: tls-rancher-ingress
---
EOF
  