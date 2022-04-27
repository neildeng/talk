#!/bin/bash +x
set -e

cd "$(dirname "$0")"

mkcert --install

mkcert k8s.edu.local localhost 172.17.0.2 127.0.0.1 ::1
mkcert rancher.k8s.edu.local
mkcert hello.k8s.edu.local
mkcert git.k8s.edu.local gitea.k8s.edu.local gitea.git.k8s.edu.local
mkcert ldap.k8s.edu.local ltb.k8s.edu.local phpldapadmin.k8s.edu.local
mkcert sso.k8s.edu.local keycloak.sso.k8s.edu.local keycloak.k8s.edu.local
mkcert argo.k8s.edu.local argocd.k8s.edu.local
mkcert harbor.k8s.edu.local core.harbor.k8s.edu.local notary.harbor.k8s.edu.local
mkcert polaris.k8s.edu.local
mkcert grafana.k8s.edu.local grafana.k8s.edu.local
mkcert dashboard.k8s.edu.local