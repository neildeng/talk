#!/bin/bash +x
set -e

cd "$(dirname "$0")"

 kubectl apply -f https://projectcalico.docs.tigera.io/manifests/calico.yaml