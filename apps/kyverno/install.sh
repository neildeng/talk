#!/usr/bin/env bash

# "---------------------------------------------------------"
# "-                                                       -"
# "-  Release kyverno                                      -"
# "-                                                       -"
# "---------------------------------------------------------"

set -o errexit
set -o pipefail
set -o nounset

WORKDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$WORKDIR"

helm upgrade --install kyverno \
  --repo=https://kyverno.github.io/kyverno/ kyverno \
  --namespace kyverno --create-namespace \
  --version 2.3.3 \
  --values - <<EOF
EOF