#!/bin/bash +x
set -e

# remove release
helm uninstall openldap-stack-ha --namespace openldap --wait || true

# remove secret
kubectl -n openldap delete secret openldap-tld-secret

# remove pvc
kubectl -n openldap get pvc | awk '{print $1}' | grep -v NAME | while read -r pvc
do
  kubectl -n openldap delete pvc $pvc
done
