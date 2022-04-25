#!/usr/bin/env bash

# "---------------------------------------------------------"
# "-                                                       -"
# "-  Delete a K3D Cluster                                 -"
# "-                                                       -"
# "---------------------------------------------------------"

set -o errexit
set -o pipefail
set -o nounset

WORKDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$WORKDIR"

k3d cluster delete talk
