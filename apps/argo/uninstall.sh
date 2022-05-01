#!/usr/bin/env bash

# "---------------------------------------------------------"
# "-                                                       -"
# "-  Uninstall Argo CD                                    -"
# "-                                                       -"
# "---------------------------------------------------------"

set -o errexit
set -o pipefail
set -o nounset

helm uninstall argo-cd --namespace argo-cd || true

kubectl -n argo-cd delete secret argocd-tls-secret || true
kubectl -n argo-cd delete configmap mkcertrootca || true

kubectl -n argo-cd get pvc | awk '{print $1}' | grep -v NAME | while read -r pvc
do
  kubectl -n argo-cd delete pvc $pvc
done

kubectl delete ns argo-cd || true
