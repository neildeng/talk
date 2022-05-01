#!/usr/bin/env bash

# "---------------------------------------------------------"
# "-                                                       -"
# "-  Uninstall cilium                                     -"
# "-                                                       -"
# "---------------------------------------------------------"

set -o errexit
set -o pipefail
set -o nounset

WORKDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$WORKDIR"

helm uninstall cilium --namespace kube-system
