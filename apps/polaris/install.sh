#!/usr/bin/env bash

# "---------------------------------------------------------"
# "-                                                       -"
# "-  Release Polaris                                      -"
# "-                                                       -"
# "---------------------------------------------------------"

set -o errexit
set -o pipefail
set -o nounset

WORKDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$WORKDIR"

kubectl create ns polaris || true
kubectl -n polaris create configmap mkcertrootca --from-file=mkcert-root-ca.pem="$(mkcert --CAROOT)/rootCA.pem" || true
kubectl -n polaris create secret tls polaris-tls --cert=./../../tls/polaris.k8s.edu.local.pem --key=./../../tls/polaris.k8s.edu.local-key.pem || true

helm upgrade --install polaris \
  --repo=https://charts.fairwinds.com/stable polaris \
  --namespace polaris --create-namespace \
  --values - <<EOF
dashboard:
  ingress:
    enabled: true
    hosts:
      - polaris.k8s.edu.local
    annotations:
      kubernetes.io/ingress.class: nginx
    tls:
      - secretName: polaris-tls
        hosts:
          - polaris.k8s.edu.local
---
EOF
