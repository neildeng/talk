#!/bin/bash +x
set -e

cd "$(dirname "$0")"

kubectl delete -f https://projectcalico.docs.tigera.io/manifests/calico.yaml
