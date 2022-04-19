#!/bin/bash +x
set -e

#kubectl delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/cloud/deploy.yaml

helm uninstall ingress-nginx --namespace ingress-nginx || true
