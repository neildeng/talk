#!/usr/bin/env bash

# "---------------------------------------------------------"
# "-                                                       -"
# "-  Creates a K3D Cluster                                -"
# "-                                                       -"
# "---------------------------------------------------------"

set -o errexit
set -o pipefail
set -o nounset

WORKDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$WORKDIR"

k3d cluster create --config cluster-talk.yaml