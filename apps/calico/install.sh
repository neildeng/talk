#!/usr/bin/env bash

# "---------------------------------------------------------"
# "-                                                       -"
# "-  Apply CNI: calico                                    -"
# "-                                                       -"
# "---------------------------------------------------------"

set -o errexit
set -o pipefail
set -o nounset

WORKDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$WORKDIR"

kubectl apply -f https://projectcalico.docs.tigera.io/manifests/calico.yaml