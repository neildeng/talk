#!/usr/bin/env bash

echo "========================================================="
echo "+                                                       +"
echo "+  Talks 203 - Kube Prometheus Stack, LGTM, Phlare      +"
echo "+                                                       +"
echo "========================================================="

set -o errexit
set -o pipefail
set -o nounset

WORKDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$WORKDIR"

echo "========================================================="
echo "清除標記營地"
echo "========================================================="

sudo hostctl remove talks || true
sudo hostctl remove talks-204 || true

echo "========================================================="
echo "先把地板掃乾淨"
echo "========================================================="

k3d cluster delete talk

echo "========================================================="
echo "把火給熄滅"
echo "========================================================="

rm -rf ../203/lgtm-helm-chart

echo "========================================================="
echo "把垃圾撿乾淨"
echo "========================================================="

podman rm -vf minio || true
podman volume rm minio || true
