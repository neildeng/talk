#!/bin/bash +x
set -e

# OIDC Endpoint://keycloak.k8s.edu.local/auth/realms/master
# OIDC Scope: openid,profile,email,offline_access
# redirect uri: https://harbor.k8s.edu.local/c/oidc/callback

cd "$(dirname "$0")"

kubectl create ns harbor || true
kubectl -n harbor create configmap mkcertrootca --from-file=mkcert-root-ca.pem="$(mkcert --CAROOT)/rootCA.pem" || true
kubectl -n harbor create secret tls harbor-tls --cert=./../../tls/harbor.k8s.edu.local+2.pem --key=./../../tls/harbor.k8s.edu.local+2-key.pem || true
kubectl -n harbor create secret generic mkcertrootca-ca-tls --from-file=ca.crt="$(mkcert --CAROOT)/rootCA.pem" || true

helm upgrade --install harbor \
  --repo=https://helm.goharbor.io harbor \
  --namespace harbor --create-namespace \
  --values - <<EOF
harborAdminPassword: "1qaz@WSX"
externalURL: https://harbor.k8s.edu.local
caBundleSecretName: "mkcertrootca-ca-tls"
caSecretName: "mkcertrootca-ca-tls"
expose:
  tls:
    enabled: "true"
    certSource: "secret"
    secret:
      secretName: "harbor-tls"
      notarySecretName: "harbor-tls"
  ingress:
    hosts:
      core: harbor.k8s.edu.local
      notary: notary.k8s.edu.local
    annotations:
      kubernetes.io/ingress.class: nginx
      ingress.kubernetes.io/ssl-redirect: "true"
      ingress.kubernetes.io/proxy-body-size: "0"
      nginx.ingress.kubernetes.io/ssl-redirect: "true"
      nginx.ingress.kubernetes.io/proxy-body-size: "0"
    notary:
      annotations:
        kubernetes.io/ingress.class: nginx
    harbor:
      annotations:
        kubernetes.io/ingress.class: nginx
---
EOF
