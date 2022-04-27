#!/usr/bin/env bash

# "---------------------------------------------------------"
# "-                                                       -"
# "-  Release PLG stack                                    -"
# "-                                                       -"
# "---------------------------------------------------------"

set -o errexit
set -o pipefail
set -o nounset

WORKDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$WORKDIR"

kubectl create ns observability || true
kubectl -n observability create configmap mkcertrootca --from-file=mkcert-root-ca.pem="$(mkcert --CAROOT)/rootCA.pem" || true
kubectl -n observability create secret tls observability-tls --cert=./../../tls/grafana.k8s.edu.local+1.pem --key=./../../tls/grafana.k8s.edu.local+1-key.pem || true

helm upgrade --install plg-stack \
  --repo=https://grafana.github.io/helm-charts loki-stack \
  --namespace observability --create-namespace \
  --values - <<EOF

promtail:
  enabled: true
  config:
    lokiAddress: http://plg-stack-loki:3100/loki/api/v1/push
grafana:
  enabled: true
  adminUser: "admin"
  adminPassword: "1qaz@WSX"
  ingress:
    enabled: true
    annotations:
      kubernetes.io/ingress.class: nginx
    hosts:
      - grafana.k8s.edu.local
    tls:
      - secretName: observability-tls
        hosts:
          - grafana.k8s.edu.local
prometheus:
  enabled: true
  server:
    statefulSet:
      enabled: true
    ingress:
      enabled: true
      annotations:
        kubernetes.io/ingress.class: nginx
      hosts:
        - prometheus.k8s.edu.local
      tls:
        - secretName: observability-tls
          hosts:
            - prometheus.k8s.edu.local
---
EOF
