#!/usr/bin/env bash

# "---------------------------------------------------------"
# "-                                                       -"
# "-  Kubernetes Dashboard                                 -"
# "-                                                       -"
# "---------------------------------------------------------"

set -o errexit
set -o pipefail
set -o nounset

WORKDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$WORKDIR"

kubectl create ns kubernetes-dashboard || true

kubectl -n kubernetes-dashboard create secret tls kubernetes-dashboard-tls --cert=./../../tls/dashboard.k8s.edu.local.pem --key=./../../tls/dashboard.k8s.edu.local-key.pem || true
kubectl -n kubernetes-dashboard create secret generic tls-ca --from-file=cacerts.pem="$(mkcert --CAROOT)/rootCA.pem" || true

kubectl -n kubernetes-dashboard apply -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
EOF

kubectl -n kubernetes-dashboard apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
EOF

helm upgrade --install kubernetes-dashboard \
  --repo=https://kubernetes.github.io/dashboard/ kubernetes-dashboard \
  --namespace kubernetes-dashboard --create-namespace \
  --version 5.4.1 \
  --values - <<EOF
ingress:
  enabled: true
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
  paths:
    - /
  hosts:
    - dashboard.k8s.edu.local
  tls:
    - secretName: kubernetes-dashboard-tls
      hosts:
        - dashboard.k8s.edu.local
EOF

echo "Kubernetes Dashboard Token:"
kubectl -n kubernetes-dashboard get secret $(kubectl -n kubernetes-dashboard get sa/admin-user -o jsonpath="{.secrets[0].name}") -o go-template="{{.data.token | base64decode}}"
