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

sudo hostctl remove talks

echo "========================================================="
echo "先把地板掃乾淨"
echo "========================================================="

k3d cluster delete talk

echo "========================================================="
echo "把火給熄滅"
echo "========================================================="

podman rm step-ca -f || true
podman volume rm step -f || true

echo "========================================================="
echo "柴火堆好"
echo "========================================================="

rm -f fingerprint
rm -f root_ca.crt
rm -f root_ca.b64
rm -f password
rm -rf /root/.step
rm -f step-ca.log
rm -f firststep.homelab.test.crt
rm -f firststep.homelab.test.key
