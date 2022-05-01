#!/usr/bin/env bash

# "---------------------------------------------------------"
# "-                                                       -"
# "-  Release ingress-nginx                                -"
# "-                                                       -"
# "---------------------------------------------------------"

set -o errexit
set -o pipefail
set -o nounset

WORKDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$WORKDIR"

#kubectl delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/cloud/deploy.yaml

helm uninstall ingress-nginx --namespace ingress-nginx || true
