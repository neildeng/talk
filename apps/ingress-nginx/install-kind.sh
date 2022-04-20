#!/bin/bash +x
set -e

cd "$(dirname "$0")"

INTERNAL_IP=$(kubectl get nodes -o wide | grep control-plane | awk '{print $6}')
kubectl -n ingress-nginx patch svc ingress-nginx-controller -p '{"spec":{"externalIPs":["'"$INTERNAL_IP"'"]}}'
