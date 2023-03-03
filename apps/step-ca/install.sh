#!/usr/bin/env bash

echo "---------------------------------------------------------"
echo "-                                                       -"
echo "-  Install Step-CA Container                            -"
echo "-                                                       -"
echo "---------------------------------------------------------"

set -o errexit
set -o pipefail
set -o nounset

WORKDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$WORKDIR"

rm -f fingerprint
rm -f root_ca.crt
rm -f root_ca.b64
rm -f password
rm -rf /root/.step
rm -rf step-ca.log
rm -rf *.homelab.test

podman rm step-ca -f || true
podman volume rm step -f || true

## Quickstart
podman run -d -v step:/home/step \
    --name step-ca \
    -p 9000:9000 \
    -e "TZ=Asia/Taipei" \
    -e "DOCKER_STEPCA_INIT_NAME=Homelab" \
    -e "DOCKER_STEPCA_INIT_DNS_NAMES=localhost,127.0.0.1,step-ca,ca.homelab.test" \
    -e "DOCKER_STEPCA_INIT_SSH=true" \
    -e "DOCKER_STEPCA_INIT_ACME=false" \
    -e "DOCKER_STEPCA_INIT_REMOTE_MANAGEMENT=true" \
    smallstep/step-ca:0.23.2

sleep 10

podman logs step-ca > step-ca.log
cat step-ca.log | grep password | cut -d ":" -f2 | tr -d ' ' > password
rm -f step-ca.log

podman exec -it step-ca cat config/defaults.json | jq -r ".fingerprint" > fingerprint

step ca bootstrap --ca-url https://localhost:9000 --fingerprint "$(cat fingerprint)" --install -f
step ca root > root_ca.crt
step ca root | step base64 > root_ca.b64
step ca provisioner update admin \
  --x509-min-dur 1h \
  --x509-default-dur 24h \
  --x509-max-dur 87660h  \
  --ssh-user-min-dur 15m \
  --ssh-host-default-dur 24h \
  --admin-name=step \
  --admin-password-file=password \
  --admin-provisioner=admin