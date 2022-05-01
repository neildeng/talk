#!/usr/bin/env bash

# "---------------------------------------------------------"
# "-                                                       -"
# "-  Release Drone                                        -"
# "-                                                       -"
# "---------------------------------------------------------"

set -o errexit
set -o pipefail
set -o nounset

GITEA_CLIENT_ID=$1
GITEA_CLIENT_SECRET=$2

if [[ -z "$GITEA_CLIENT_ID" ]]; then
   echo "錯誤未指定 GITEA_CLIENT_ID"
   exit 1
fi

if [[ -z "$GITEA_CLIENT_SECRET" ]]; then
   echo "錯誤未指定 GITEA_CLIENT_SECRET"
   exit 1
fi

WORKDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$WORKDIR"

kubectl create ns drone || true
kubectl -n drone create configmap mkcertrootca --from-file=mkcert-root-ca.pem="$(mkcert --CAROOT)/rootCA.pem" || true
kubectl -n drone create secret tls drone-tls --cert=./../../tls/drone.k8s.edu.local+1.pem --key=./../../tls/drone.k8s.edu.local+1-key.pem || true

kubectl -n drone apply -f - <<EOF
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  namespace: drone
  name: drone
rules:
- apiGroups:
  - ""
  resources:
  - secrets
  verbs:
  - create
  - delete
- apiGroups:
  - ""
  resources:
  - pods
  - pods/log
  verbs:
  - get
  - create
  - delete
  - list
  - watch
  - update

---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: drone
  namespace: drone
subjects:
- kind: ServiceAccount
  name: drone
  namespace: drone
roleRef:
  kind: Role
  name: drone
  apiGroup: rbac.authorization.k8s.io
EOF

kubectl -n drone apply -f - <<EOF
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  namespace: drone
  name: drone-runner-drone-runner-kube
rules:
- apiGroups:
  - ""
  resources:
  - secrets
  verbs:
  - create
  - delete
- apiGroups:
  - ""
  resources:
  - pods
  - pods/log
  verbs:
  - get
  - create
  - delete
  - list
  - watch
  - update

---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: drone-runner-drone-runner-kube
  namespace: drone
subjects:
- kind: ServiceAccount
  name: drone-runner-drone-runner-kube
  namespace: drone
roleRef:
  kind: Role
  name: drone-runner-drone-runner-kube
  apiGroup: rbac.authorization.k8s.io
EOF


DRONE_RPC_SECRET=$(openssl rand -hex 16)

helm upgrade --install drone  \
  --repo=https://charts.drone.io drone \
  --namespace drone --create-namespace \
  --values - <<EOF
extraVolumes:
  - configMap:
      defaultMode: 420
      name: mkcertrootca
    name: mkcertrootca
extraVolumeMounts:
  - mountPath: /etc/ssl/certs/mkcert-root-ca.crt
    name: mkcertrootca
    readOnly: true
    subPath: mkcert-root-ca.pem
env:
  DRONE_SERVER_HOST: drone.k8s.edu.local
  DRONE_SERVER_PROTO: https
  DRONE_RPC_SECRET: $DRONE_RPC_SECRET
  DRONE_GITEA_SERVER: https://git.k8s.edu.local
  DRONE_GITEA_CLIENT_ID: $GITEA_CLIENT_ID
  DRONE_GITEA_CLIENT_SECRET: $GITEA_CLIENT_SECRET
ingress:
  enabled: false
  annotations:
    kubernetes.io/ingress.class: nginx
  hosts:
    - host: drone.k8s.edu.local
      paths:
        - "/"
  tls:
    - secretName: drone-tls
      hosts:
        - drone-tls
---
EOF

helm upgrade --install drone-runner  \
  --repo=https://charts.drone.io drone-runner-kube \
  --namespace drone --create-namespace \
  --values - <<EOF
extraVolumes:
  - configMap:
      defaultMode: 420
      name: mkcertrootca
    name: mkcertrootca
extraVolumeMounts:
  - mountPath: /etc/ssl/certs/mkcert-root-ca.crt
    name: mkcertrootca
    readOnly: true
    subPath: mkcert-root-ca.pem
env:
  DRONE_RPC_HOST: drone.k8s.edu.local
  DRONE_RPC_SECRET: $DRONE_RPC_SECRET
  DRONE_RPC_PROTO: https
  DRONE_NAMESPACE_DEFAULT: drone
---
EOF

kubectl -n drone apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: drone
  annotations:
    kubernetes.io/ingress.class: nginx
spec:
  tls:
    - hosts:
        - "drone.k8s.edu.local"
      secretName: drone-tls
  rules:
    - host: "drone.k8s.edu.local"
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: drone
                port:
                  number: 80
EOF

kubectl -n drone apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: drone-runner
  annotations:
    kubernetes.io/ingress.class: nginx
spec:
  tls:
    - hosts:
        - "drone-runner.k8s.edu.local"
      secretName: drone-tls
  rules:
    - host: "drone-runner.k8s.edu.local"
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: drone-runner-drone-runner-kube
                port:
                  number: 3000
EOF
