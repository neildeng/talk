#!/usr/bin/env bash

# "---------------------------------------------------------"
# "-                                                       -"
# "-  Release Argo CD                                      -"
# "-                                                       -"
# "---------------------------------------------------------"

set -o errexit
set -o pipefail
set -o nounset

OIDC_SECRET=$1

if [[ -z "$OIDC_SECRET" ]]; then
   echo "錯誤未指定 OIDC_SECRET"
   exit 1
fi

WORKDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$WORKDIR"

ARGO_PWD="1qaz@WSX"
CLIENT_SECRET='$oidc.keycloak.clientSecret'
echo $CLIENT_SECRET
ARGO_ADMIN_PWD=$(htpasswd -nbBC 10 "" $ARGO_PWD | tr -d ':\n' | sed 's/$2y/$2a/')

kubectl create ns argo-cd || true
kubectl -n argo-cd create configmap mkcertrootca --from-file=mkcert-root-ca.pem="$(mkcert --CAROOT)/rootCA.pem" || true
kubectl -n argo-cd create secret tls argocd-tls-secret --cert=./../../tls/argo.k8s.edu.local+1.pem --key=./../../tls/argo.k8s.edu.local+1-key.pem || true
kubectl -n argo-cd create secret tls argocd-repo-server-tls --cert=./../../tls/argo.k8s.edu.local+1.pem --key=./../../tls/argo.k8s.edu.local+1-key.pem || true

helm upgrade --install argo-cd \
  --repo=https://argoproj.github.io/argo-helm argo-cd \
  --namespace argo-cd --create-namespace \
  --values - <<EOF
nameOverride: argocd
configs:
  styles: |
    .nav-bar {
      background: linear-gradient(to bottom, #999, #777, #333, #222, #111);
    }
  secret:
    argocdServerAdminPassword: "$ARGO_ADMIN_PWD"
    argocdServerAdminPasswordMtime: "$(date +%FT%T%Z)"
    extra:
      oidc.keycloak.clientSecret: "$OIDC_SECRET"
  tlsCerts:
    data:
      git.k8s.edu.local: |
        -----BEGIN CERTIFICATE-----
        MIIEcTCCAtmgAwIBAgIQQvWZCqR0UK0FW8WnaRuMUjANBgkqhkiG9w0BAQsFADB9
        MR4wHAYDVQQKExVta2NlcnQgZGV2ZWxvcG1lbnQgQ0ExKTAnBgNVBAsMIHNob25h
        QHNob25hLWRlLU1hY0Jvb2stUHJvLmxvY2FsMTAwLgYDVQQDDCdta2NlcnQgc2hv
        bmFAc2hvbmEtZGUtTWFjQm9vay1Qcm8ubG9jYWwwHhcNMjIwNDI4MDIzOTA4WhcN
        MjQwNzI4MDIzOTA4WjBUMScwJQYDVQQKEx5ta2NlcnQgZGV2ZWxvcG1lbnQgY2Vy
        dGlmaWNhdGUxKTAnBgNVBAsMIHNob25hQHNob25hLWRlLU1hY0Jvb2stUHJvLmxv
        Y2FsMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA2DFFAtMRlhneHKkf
        3YokP+7fYqONNLYzYkRZhiPGoq9lperZyCyQZ6h/vyYWlLa3eSFxOqWMM9TgseAD
        QV0BbgSV+MrtqSSUiOWnhb/VIZqjA+e0vA7RxeYOU5LedPwvbeQYGWZWCh3btD9W
        mOk57SHsT0aCDmSPkq5FkQIAVPRBu2rxXeP//0fyF5mcrcqxzAx6HRZsGvM1+OKb
        yD3JTmrnLm1d+zpkPVXM1Cx+k457pvFhWVrYaO2tES86EzxPmUAbzHAf39pz1ttz
        W2Clel6dE15WLlsZtTMLYB6ziD2nBqSf/WeDdOEVEt90gR9CB9hWCbXotHeAnwc8
        6STMgwIDAQABo4GVMIGSMA4GA1UdDwEB/wQEAwIFoDATBgNVHSUEDDAKBggrBgEF
        BQcDATAfBgNVHSMEGDAWgBTglYuyfa8WRnL64b9fvLPyT5n/wjBKBgNVHREEQzBB
        ghFnaXQuazhzLmVkdS5sb2NhbIITZ2l0ZWEuazhzLmVkdS5sb2NhbIIXZ2l0ZWEu
        Z2l0Lms4cy5lZHUubG9jYWwwDQYJKoZIhvcNAQELBQADggGBADxekV+iyk47kw99
        H/d5oV7YSg+3O+Pebqocjclx4IzDi08YtoQ8xlHIz70S6zAzYYlh3NMyT8a41Ob1
        8n1wk/VN0JuSyhHs6MD2zDb0n4BD5WoOxSqsUhRVfNmNeu2xj0J4FZ+wDpS4tGka
        rQOzDbu2kFcOF7+RSiJWvG8sblpL8z0vCFFEoBuRe0GyKypnlIwE/vBJrO2KTtMU
        gJp2aiMuxJwZWDzCfqtNRvUpzbBZ8/NZ9xIRURQrBv7S+tqlOg04sidpxh9so7dd
        jxxstJytDP26A+rCWzmxmfyffED9c2/75al/Xk3DvUxF/dpbmGZ6BYecGYqScChB
        2f3njS5vyvGcCYs0NKrs70gVf6UNld2v8mT37XRLghdO0GuUwQgPXRVk5GiYyBb6
        urBFNbOG47qtCkoEa25lDMq/KxytkN9htI4Bmfva/bnRaIgU+tyn3OJFc+04B+GX
        5f4Sg2mFcGB3QShVN92XcfW7eD6ax29V1woslh0uvRJ6m2z4Vw==
        -----END CERTIFICATE-----
  repositories:
    private-repo:
      url: https://git.k8s.edu.local/neildeng/oxox

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

#argocd cert add-tls git.k8s.edu.local --from ./git.k8s.edu.local+2.pem
#argocd repo add https://git.k8s.edu.local/neildeng/oxox