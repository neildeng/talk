#!/usr/bin/env bash

# "---------------------------------------------------------"
# "-                                                       -"
# "-  Release cert-manager                                 -"
# "-                                                       -"
# "---------------------------------------------------------"

set -o errexit
set -o pipefail
set -o nounset

WORKDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$WORKDIR"

helm upgrade --install cert-manager \
  --repo https://charts.jetstack.io cert-manager \
  --namespace cert-manager --create-namespace \
  --version v1.5.1 \
  --set installCRDs=true