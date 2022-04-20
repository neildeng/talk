#!/bin/bash +x
set -e

cd "$(dirname "$0")"

kubectl -n ingress-nginx patch svc ingress-nginx-controller -p '{"spec":{"externalIPs":["172.21.0.2","172.21.0.3","172.21.0.4"]}}'
