#!/bin/bash +x
set -e

cd "$(dirname "$0")"

# helm repo add gitea-charts https://dl.gitea.io/charts/
# helm repo update

kubectl create ns git || true
kubectl -n git create configmap testgrca4 --from-file=testgrca4.crt=./../../tls/testGRCA4.crt 
kubectl -n git create secret tls git-tld-secret --cert=./../../tls/git.k8s.edu.local+2.pem --key=./../../tls/git.k8s.edu.local+2-key.pem

helm install gitea \
  --repo=https://dl.gitea.io/charts/ gitea \
  --namespace git --create-namespace \
  --values - <<EOF
ingress:
  enabled: true
  hosts:
    - host: git.k8s.edu.local
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: git-tld-secret
      hosts:
        - git.k8s.edu.local
gitea:
  admin:
    username: giteaadmin
    password: 1qaz@WSX
    email: "gitea@k8s.edu.local"
extraVolumes:
  - configMap:
      defaultMode: 420
      name: testgrca4
    name: testgrca4
extraVolumeMounts:
  - mountPath: /etc/ssl/certs/ca-certificates.crt
    name: testgrca4
    readOnly: true
    subPath: testgrca4.crt
---
EOF

