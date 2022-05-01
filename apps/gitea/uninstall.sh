#!/usr/bin/env bash

# "---------------------------------------------------------"
# "-                                                       -"
# "-  Uninstall gitea                                      -"
# "-                                                       -"
# "---------------------------------------------------------"

set -o errexit
set -o pipefail
set -o nounset

WORKDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$WORKDIR"

helm uninstall gitea --namespace git || true

kubectl -n git delete secret gitea-tls || true
kubectl -n git delete secret openid-connect-secret || true
kubectl -n git delete configmap mkcertrootca || true
kubectl -n git get pvc | awk '{print $1}' | grep -v NAME | while read -r pvc
do
  kubectl -n git delete pvc $pvc
done
