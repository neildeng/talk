#!/usr/bin/env bash

# "---------------------------------------------------------"
# "-                                                       -"
# "-  Uninstall Calico                                     -"
# "-                                                       -"
# "---------------------------------------------------------"

set -o errexit
set -o pipefail
set -o nounset

WORKDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$WORKDIR"

kubectl delete -f https://projectcalico.docs.tigera.io/manifests/calico.yaml
