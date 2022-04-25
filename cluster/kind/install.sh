#!/usr/bin/env bash

# "---------------------------------------------------------"
# "-                                                       -"
# "-  Create a KIND Cluster                                -"
# "-                                                       -"
# "---------------------------------------------------------"

set -o errexit
set -o pipefail
set -o nounset

WORKDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$WORKDIR"

kind create cluster --config cluster-talk.yaml