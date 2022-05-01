#!/usr/bin/env bash

# "---------------------------------------------------------"
# "-                                                       -"
# "-  Create CA、Secret, and ClusterIssuer                 -"
# "-                                                       -"
# "---------------------------------------------------------"

set -o errexit
set -o pipefail
set -o nounset

WORKDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$WORKDIR"

CAROOT=. mkcert -install

kubectl create secret tls ca-key-pair \
   --cert=rootCA.pem \
   --key=rootCA-key.pem \
   --namespace=cert-manager

kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: ca-issuer
spec:
  ca:
    secretName: ca-key-pair
EOF