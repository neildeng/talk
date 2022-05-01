#!/bin/bash +x
set -e

cd "$(dirname "$0")"

kubectl delete Certificate hello-cert || true
kubectl delete secret hello-tls || true
kubectl delete -f ./ || true