#!/bin/bash +x
set -e

cd "$(dirname "$0")"

kubectl create ns keycloak || true

kubectl -n keycloak create configmap mkcertrootca --from-file=mkcert-root-ca.pem="$(mkcert --CAROOT)/rootCA.pem" || true
kubectl -n keycloak create secret tls keycloak-tld-secret --cert=./../../tls/sso.k8s.edu.local+2.pem --key=./../../tls/sso.k8s.edu.local+2-key.pem || true

helm upgrade --install keycloak \
  --repo=https://codecentric.github.io/helm-charts keycloak \
  --namespace keycloak --create-namespace \
  --values - <<EOF
extraEnv: |
  - name: KEYCLOAK_LOGLEVEL
    value: DEBUG
  - name: KEYCLOAK_USER
    value: admin
  - name: KEYCLOAK_PASSWORD
    value: 1qaz@WSX
  - name: PROXY_ADDRESS_FORWARDING
    value: "true"

extraVolumes: |
  - configMap:
      defaultMode: 420
      name: mkcertrootca
    name: mkcertrootca
extraVolumeMounts: |
  - mountPath: /etc/ssl/certs/mkcert-root-ca.pem
    name: mkcertrootca
    readOnly: true
    subPath: mkcert-root-ca.pem

ingress:
  enabled: true
  annotations:
    kubernetes.io/ingress.class: nginx
  rules:
    - host: 'keycloak.k8s.edu.local'
      paths:
        - path: /
          pathType: Prefix
  tls:
    - hosts:
        - keycloak.k8s.edu.local
      secretName: "keycloak-tld-secret"
  console:
    enabled: true
    ingressClassName: ""
    annotations:
      kubernetes.io/ingress.class: nginx
    rules:
      - host: 'keycloak.k8s.edu.local'
        paths:
          - path: /auth/admin/
            pathType: Prefix
    tls:
      - hosts:
          - keycloak.k8s.edu.local
        secretName: "keycloak-tld-secret"

args:
  - -Dkeycloak.profile.feature.docker=enabled

postgresql:
  enabled: true
  postgresqlPassword: asdfaso97sadfjylfasdsf78
---
EOF

