#!/usr/bin/env bash

# "---------------------------------------------------------"
# "-                                                       -"
# "-  Uninstall kyverno                                    -"
# "-                                                       -"
# "---------------------------------------------------------"

set -o errexit
set -o pipefail
set -o nounset

WORKDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$WORKDIR"

helm uninstall kyverno --namespace kyverno
