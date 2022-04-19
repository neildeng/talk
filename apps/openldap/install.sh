#!/bin/bash +x
set -e

cd "$(dirname "$0")"

kubectl create ns openldap || true

kubectl -n openldap create secret tls openldap-tld-secret --cert=./../../tls/ldap.k8s.edu.local+2.pem --key=././../../tls/ldap.k8s.edu.local+2-key.pem || true

helm upgrade --install openldap-stack-ha \
  --repo=https://jp-gouin.github.io/helm-openldap/ openldap-stack-ha \
  --namespace openldap --create-namespace \
  --version 2.1.6 \
  --values - <<EOF
adminPassword: 1qaz@WSX
configPassword: 4rfv5tgb6yhn4567rtyufghjvbnm
customFileSets:
  - name: fileset1
    targetPath: /container/service/slapd/assets/config/bootstrap/ldif
    files:
    - filename: 03-memberOf.ldif
      content: |
        dn: cn=module{0},cn=config
        changetype: modify
        add: olcModuleLoad
        olcModuleLoad: memberof
customLdifFiles:
  initial-ous.ldif: |-
    version: 1

    #
    dn: ou=People,dc=k8s,dc=edu,dc=local
    objectClass: organizationalUnit
    ou: People

    #
    dn: ou=Groups,dc=k8s,dc=edu,dc=local
    objectClass: organizationalUnit
    ou: Groups

    #
    dn: cn=common,ou=Groups,dc=k8s,dc=edu,dc=local
    cn: common
    gidnumber: 500
    memberuid: neildeng
    memberuid: amigo
    memberuid: wings
    objectclass: posixGroup
    objectclass: top

    #
    dn: cn=dev,ou=Groups,dc=k8s,dc=edu,dc=local
    cn: dev
    gidnumber: 501
    memberuid: amigo
    memberuid: wings
    objectclass: posixGroup
    objectclass: top

    #
    dn: cn=ops,ou=Groups,dc=k8s,dc=edu,dc=local
    cn: ops
    memberuid: neildeng
    gidnumber: 502
    objectclass: posixGroup
    objectclass: top

    #
    dn: cn=neildeng,ou=People,dc=k8s,dc=edu,dc=local
    cn: neildeng
    gidnumber: 500
    homedirectory: /home/users/neildeng
    mail: neildeng@k8s.edu.local
    objectclass: inetOrgPerson
    objectclass: posixAccount
    objectclass: top
    sn: neildeng
    uid: neildeng
    uidnumber: 1000
    userpassword: 1qaz@WSX

    #
    dn: cn=amigo,ou=People,dc=k8s,dc=edu,dc=local
    cn: amigo
    gidnumber: 500
    homedirectory: /home/users/amigo
    mail: amigo@k8s.edu.local
    objectclass: inetOrgPerson
    objectclass: posixAccount
    objectclass: top
    sn: amigo
    uid: amigo
    uidnumber: 1001
    userpassword: 1qaz@WSX

    #
    dn: cn=wings,ou=People,dc=k8s,dc=edu,dc=local
    cn: wings
    gidnumber: 500
    homedirectory: /home/users/wings
    mail: wings@k8s.edu.local
    objectclass: inetOrgPerson
    objectclass: posixAccount
    objectclass: top
    sn: wings
    uid: wings
    uidnumber: 1002
    userpassword: 1qaz@WSX

env:
  LDAP_ORGANISATION: "K8s talking"
  LDAP_TLS: "true"
  LDAP_TLS_ENFORCE: "false"
  LDAP_REMOVE_CONFIG_AFTER_SETUP: "true"
  LDAP_READONLY_USER: "true"
  LDAP_READONLY_USER_USERNAME: "readonly"
  LDAP_READONLY_USER_PASSWORD: "readonly"
  LDAP_DOMAIN: "k8s.edu.local"
ltb-passwd:
  enabled : false
  ingress:
    enabled: true
    annotations:
      kubernetes.io/ingress.class: nginx
    hosts:
    - "ltb.k8s.edu.local"
  ldap:
    server: ldap://openldap-stack-ha.openldap
    # existingSecret: openldaptest
    bindDN: cn=admin,dc=k8s,dc=edu,dc=local
    bindPWKey: LDAP_ADMIN_PASSWORD
phpldapadmin:
  enabled: true
  ingress:
    enabled: true
    annotations:
      kubernetes.io/ingress.class: nginx
    hosts:
      - phpldapadmin.k8s.edu.local
    tls:
      - hosts:
          - phpldapadmin.k8s.edu.local
        secretName: "openldap-tld-secret"
  env:
    PHPLDAPADMIN_LDAP_HOSTS: "openldap-stack-ha.openldap"
---
EOF

