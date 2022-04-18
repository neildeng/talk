#!/bin/bash +x
set -e

cd "$(dirname "$0")"

./gtestcert k8s.edu.local rancher.k8s.edu.local
./gtestcert hello.k8s.edu.local
./gtestcert git.k8s.edu.local gitea.k8s.edu.local gitea.git.k8s.edu.local
./gtestcert ldap.k8s.edu.local ltb.k8s.edu.local phpldapadmin.k8s.edu.local
./gtestcert sso.k8s.edu.local keycloak.sso.k8s.edu.local keycloak.k8s.edu.local
