#!/usr/bin/env bash

# "---------------------------------------------------------"
# "-                                                       -"
# "-  Add k8s.edu records                                  -"
# "-                                                       -"
# "---------------------------------------------------------"

set -o errexit
set -o pipefail
set -o nounset

WORKDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$WORKDIR"

sudo hostctl add talk --from ./hosts 
