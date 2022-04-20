#!/bin/bash +x
set -e

cd "$(dirname "$0")"

kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.12.1/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.12.1/manifests/metallb.yaml
docker network inspect -f '{{.IPAM.Config}}' kind
kubectl apply -f metallb-configmap.yaml
kubectl apply -f https://kind.sigs.k8s.io/examples/loadbalancer/usage.yaml