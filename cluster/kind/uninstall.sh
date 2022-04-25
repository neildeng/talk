#!/usr/bin/env bash

# "---------------------------------------------------------"
# "-                                                       -"
# "-  Delete a KIND Cluster                                -"
# "-                                                       -"
# "---------------------------------------------------------"

set -o errexit
set -o pipefail
set -o nounset

WORKDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$WORKDIR"

kind delete cluster --name talk