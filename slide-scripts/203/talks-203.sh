#!/usr/bin/env bash

echo "========================================================="
echo "+                                                       +"
echo "+  Talks 203 - Grafana Big Tant: LGTM + Phlare          +"
echo "+                                                       +"
echo "========================================================="

set -o errexit
set -o pipefail
set -o nounset

WORKDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$WORKDIR"



echo "========================================================="
echo "答數 "
echo "========================================================="

echo "\nhostctl  版本"
echo "---------------------------------------------------------"
hostctl --version

echo "\ngit  版本"
echo "---------------------------------------------------------"
git --version

echo "\nhelm  版本"
echo "---------------------------------------------------------"
helm version

echo "\npodman  版本"
echo "---------------------------------------------------------"
podman version

echo "\nk3d  版本"
echo "---------------------------------------------------------"
k3d version

echo "\nkubectl  版本"
echo "---------------------------------------------------------"
kubectl version --client

echo "\n"

echo "========================================================="
echo "標記營地"
echo "========================================================="

HOST_IP=$(ifconfig | grep 'inet ' | awk '{print $2}' | grep -v '127.0.0.1')
sudo hostctl remove talks || true
sudo hostctl add talks -f - <<EOF
$HOST_IP grafana.homelab.test
$HOST_IP alertmanager.homelab.test
$HOST_IP prometheus.homelab.test
$HOST_IP mimir.homelab.test
$HOST_IP minio.homelab.test
EOF

echo "========================================================="
echo "先把地板掃乾淨"
echo "========================================================="

k3d cluster delete talk

echo "========================================================="
echo "順便拖一下地"
echo "========================================================="

podman rm -vf minio
podman run -it -d \
  --name minio \
  -p 9900:9900 \
  -p 9990:9990 \
  -v "minio:/data" \
  -e "MINIO_ROOT_USER=admin" \
  -e "MINIO_ROOT_PASSWORD=changeme" \
  quay.io/minio/minio server /data --console-address ":9990" --address ":9900"

echo "========================================================="
echo "搭帳篷"
echo "========================================================="

k3d cluster create --config - <<EOF
---
apiVersion: k3d.io/v1alpha4
kind: Simple
metadata:
  name: talk
servers: 1
agents: 1
ports:
  - port: 18080:80
    nodeFilters:
      - loadbalancer
  - port: 18443:443
    nodeFilters:
      - loadbalancer
EOF

echo "========================================================="
echo "撿木柴"
echo "========================================================="

git clone https://github.com/neildeng/lgtm-helm-chart.git

echo "========================================================="
echo "添加柴火"
echo "========================================================="

mc alias set s3 http://localhost:9900 admin changeme
(mc rb s3/tempo --force || true) && ( mc mb s3/tempo)
(mc rb s3/loki --force || true) && ( mc mb s3/loki)
(mc rb s3/phlare --force || true) && ( mc mb s3/phlare)
(mc rb s3/mimir-ruler --force || true) && ( mc mb s3/mimir-ruler)
(mc rb s3/mimir-tsdb --force || true) && ( mc mb s3/mimir-tsdb)

helm upgrade --install lgtm-aio ./lgtm-helm-chart/ \
  --namespace observability --create-namespace \
  --wait \
  -f ./lgtm-helm-chart/values-grafana.yaml \
  -f ./lgtm-helm-chart/values-loki.yaml \
  -f ./lgtm-helm-chart/values-tempo.yaml \
  -f ./lgtm-helm-chart/values-phlare.yaml \
  -f ./lgtm-helm-chart/values-mimir.yaml \
  -f ./lgtm-helm-chart/values-object-storages.yaml \
  -f - <<EOF
kubeprometheusstack:
  prometheus-node-exporter:
    hostRootFsMount:
      enabled: false
EOF

echo "========================================================="
echo "烹煮                                                      "
echo "========================================================="

helm upgrade --install lgtm-aio ./lgtm-helm-chart/ --namespace observability --reuse-values -f - <<EOF
kubeprometheusstack:
  alertmanager:
    ingress:
      enabled: true
      hosts:
        - alertmanager.homelab.test

  prometheus:
    ingress:
      enabled: true
      hosts:
        - prometheus.homelab.test

  grafana:
    ingress:
      enabled: true
      hosts:
        - grafana.homelab.test

mimir:
  nginx:
    ingress:
      enabled: true
      hosts:
        - host: mimir.homelab.test
          paths:
            - path: /
              pathType: Prefix
      tls: []
EOF
