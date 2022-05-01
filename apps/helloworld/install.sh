#!/bin/bash +x
set -e

cd "$(dirname "$0")"

kubectl create secret tls hello-tls \
    --cert=./../../tls/hello.k8s.edu.local.pem \
    --key=./../../tls/hello.k8s.edu.local-key.pem

#kubectl apply -f - <<EOF
#apiVersion: cert-manager.io/v1alpha2
#kind: Certificate
#metadata:
#  name: hello-cert
#  namespace: default
#spec:
#  secretName: hello-tls
#  issuerRef:
#    name: ca-issuer
#    kind: ClusterIssuer
#  commonName: hello.k8s.edu.local
#  organization:
#    - k8s.edu.local
#  dnsNames:
#    - hello.k8s.edu.local
#EOF
#kubectl get certificate hello-cert
#kubectl describe secret hello-cert-tls
