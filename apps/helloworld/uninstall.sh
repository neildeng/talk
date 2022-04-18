#!/bin/bash +x
set -e

cd "$(dirname "$0")"

kubectl delete secret hello-tls
kubectl delete -f ./