#!/bin/bash +x
set -e

OIDC_SECRET=$1

if [[ -z "$OIDC_SECRET" ]]; then
   echo "錯誤未指定 OIDC_SECRET"
   exit 1
fi

cd "$(dirname "$0")"

kubectl create ns git || true
kubectl -n git create configmap mkcertrootca --from-file=mkcert-root-ca.pem="$(mkcert --CAROOT)/rootCA.pem" || true
kubectl -n git create secret tls gitea-tls --cert=./../../tls/git.k8s.edu.local+2.pem --key=./../../tls/git.k8s.edu.local+2-key.pem || true
kubectl -n git create secret generic openid-connect-secret --from-literal=key=gitea --from-literal=secret=$OIDC_SECRET || true

helm upgrade --install gitea \
  --repo=https://dl.gitea.io/charts/ gitea \
  --namespace git --create-namespace \
  --values - <<EOF
ingress:
  enabled: true
  annotations:
    kubernetes.io/ingress.class: nginx
  hosts:
    - host: git.k8s.edu.local
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: gitea-tls
      hosts:
        - git.k8s.edu.local
gitea:
  admin:
    username: giteaadmin
    password: 1qaz@WSX
    email: "gitea@k8s.edu.local"
  config:
    APP_NAME: "K8s Edu Local"
    server:
      DOMAIN: git.k8s.edu.local
      ROOT_URL: https://git.k8s.edu.local/
    webhook:
      ALLOWED_HOST_LIST: "*"
  oauth:
  - name: 'keycloak'
    provider: 'openidConnect'
    existingSecret: openid-connect-secret
    autoDiscoverUrl: 'https://keycloak.k8s.edu.local/auth/realms/master/.well-known/openid-configuration'
extraVolumes:
  - configMap:
      defaultMode: 420
      name: mkcertrootca
    name: mkcertrootca
extraVolumeMounts:
  - mountPath: /etc/ssl/certs/mkcert-root-ca.pem
    name: mkcertrootca
    readOnly: true
    subPath: mkcert-root-ca.pem
---
EOF

