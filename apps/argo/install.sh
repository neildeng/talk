#!/bin/bash +x
set -e

cd "$(dirname "$0")"

OIDC_SECRET="w9hnnquzhtwYSaKGpwNUWZ8zzyj0B3WP"
ARGO_PWD="1qaz@WSX"
CLIENT_SECRET='$oidc.keycloak.clientSecret'
echo $CLIENT_SECRET
ARGO_ADMIN_PWD=$(htpasswd -nbBC 10 "" $ARGO_PWD | tr -d ':\n' | sed 's/$2y/$2a/')

kubectl create ns argo-cd || true
kubectl -n argo-cd create configmap mkcertrootca --from-file=mkcert-root-ca.pem="$(mkcert --CAROOT)/rootCA.pem" || true
kubectl -n argo-cd create secret tls argocd-tls-secret --cert=./../../tls/argo.k8s.edu.local+1.pem --key=./../../tls/argo.k8s.edu.local+1-key.pem || true

helm upgrade --install argo-cd \
  --repo=https://argoproj.github.io/argo-helm argo-cd \
  --namespace argo-cd --create-namespace \
  --values - <<EOF
nameOverride: argocd
configs:
  secret:
    argocdServerAdminPassword: "$ARGO_ADMIN_PWD"
    argocdServerAdminPasswordMtime: "$(date +%FT%T%Z)"
    extra:
      oidc.keycloak.clientSecret: "$OIDC_SECRET"
server:
  config:
    url: https://argocd.k8s.edu.local
    oidc.config: |
      name: Keycloak
      issuer: https://keycloak.k8s.edu.local/auth/realms/master
      clientID: argocd
      #cliClientID: argocdcli
      clientSecret: $CLIENT_SECRET
      #requestedIDTokenClaims: {"groups": {"essential": true}}
      requestedScopes: ["openid", "profile", "email", "groups"]
      rootCA: |
        -----BEGIN CERTIFICATE-----
        MIIEyTCCAzGgAwIBAgIQNSj4Ye7oSGsq9g136IkOrjANBgkqhkiG9w0BAQsFADB9
        MR4wHAYDVQQKExVta2NlcnQgZGV2ZWxvcG1lbnQgQ0ExKTAnBgNVBAsMIHNob25h
        QHNob25hLWRlLU1hY0Jvb2stUHJvLmxvY2FsMTAwLgYDVQQDDCdta2NlcnQgc2hv
        bmFAc2hvbmEtZGUtTWFjQm9vay1Qcm8ubG9jYWwwHhcNMjIwNDE5MDMwNDU4WhcN
        MzIwNDE5MDMwNDU4WjB9MR4wHAYDVQQKExVta2NlcnQgZGV2ZWxvcG1lbnQgQ0Ex
        KTAnBgNVBAsMIHNob25hQHNob25hLWRlLU1hY0Jvb2stUHJvLmxvY2FsMTAwLgYD
        VQQDDCdta2NlcnQgc2hvbmFAc2hvbmEtZGUtTWFjQm9vay1Qcm8ubG9jYWwwggGi
        MA0GCSqGSIb3DQEBAQUAA4IBjwAwggGKAoIBgQDEwZVOqtzLdFJ2HZSOIA3GMBBh
        WdYxZ7eGtJ5Ig6d7SslltA1CesOtmthLv8QGQZtiggyyruNbDoCoQeJmMw+KNRY8
        8tJ41LVmUHN2t/TjAJlAxES5Lxww7zl6Pjb4dxejxwxPv5h6FS0v5gegXXYI3ZAz
        JLBsRzT38fSdX94qIhq+6i6u/1FRa8PBMNpK9PBCh+Z1FKpW20DPlF7QPYU6aMdw
        Nt0c0Ebz7QwYb5Hvq91Fnnqa5nJNHQykX2YCzk0RgBqLq2VpnkKpO3MQjwYwlV9W
        7sEjc2eo5pMwz4X3Cds+J+bJN+65dKuljMwXsd0b/1vH3B3Wiz2mB/6mBGBwVTFM
        7vdF/5/FsVdkaAOH5SIjaO26vRXGQbh93EJd08jJgLlolQoZ7JrA9F046UTIHlRJ
        NHSb1LPRXJADvmzOGxBuOv8PLZc2MarwPamXpXL7XWnrciQEA72DVEYcnWXhrDER
        7EzHeRVdyosKC/HrnkedGq9Ee7cgliIE47j5H6MCAwEAAaNFMEMwDgYDVR0PAQH/
        BAQDAgIEMBIGA1UdEwEB/wQIMAYBAf8CAQAwHQYDVR0OBBYEFOCVi7J9rxZGcvrh
        v1+8s/JPmf/CMA0GCSqGSIb3DQEBCwUAA4IBgQBzsTR7xGUjs6NZXVa0jAtt4/+W
        /aN2ta/kjldXexClC17oFe2uofcvM2gdepZUAiRFuiG8tqqUgTjNZYozvoAVAiFy
        NRlD83gu2mhnN8wNYOsWkpp1NtULhaGDmq9jzlX+2itUW28ufyWHyhHci6fY+dgG
        SIF5YDygH+BSd/3kdSsehepWwsyO7LkkPD+OzpZd+yJa4vxdKQppw2oF4HhP2ck4
        +7GOVlQq1OJ9a7nd3HNTVTkA4Y8MCvJwMP3CBwwiqR1F0mWQR2xZxXxgAKdpkkRR
        P5mBNZ1uWeR2ALk7bVEmoIIblDUJ52MbPvQCts0SVuP9t3l8bz0dTEHCHijahwPu
        VlV8M80ji6uSmZ9kpqeKPulUHQwLadR2JveOQm4Ev8QeVDoymFs0odSmTOdNIA4c
        sGsmD6hNkAWlYIlCpaIN861DFbpIoCKMYgBaxuy9eD8CEK3nHIL3XzvpIF4mL9eD
        97BShMKH41smmuqSS6ZKwJWNEh8JZHlqV04rbJQ=
        -----END CERTIFICATE-----
  rbacConfig:
    policy.default: role:readonly
    policy.csv: |
      g, ArgoCDAdmins, role:admin

  ingress:
    enabled: true
    annotations:
      kubernetes.io/ingress.class: nginx
      nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
      nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
    hosts:
      - argocd.k8s.edu.local
    paths:
      - /
    pathType: Prefix
    tls:
      - secretName: argocd-tls-secret
        hosts:
          - argocd.k8s.edu.local
    https: true
notifications:
  enabled: false
---
EOF


#kubectl -n argo-cd patch secret argocd-secret -p '{"stringData": {
#    "admin.password": "$2a$10$E.Vhm72opV71iIl5jVu6S.4kuotI/EA36deHVR5MHjSLUkwkAM2FW",
#    "admin.passwordMtime": "'$(date +%FT%T%Z)'"
#  }}'