#!/usr/bin/env bash

echo "========================================================="
echo "+                                                       +"
echo "+  Talks 202 - CA, Certificate, Issuer, Ingress         +"
echo "+                                                       +"
echo "========================================================="

set -o errexit
set -o pipefail
set -o nounset

WORKDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$WORKDIR"



echo "========================================================="
echo "答數 "
echo "========================================================="

echo "\nhostctl  版本"
echo "---------------------------------------------------------"
hostctl --version

echo "\npodman  版本"
echo "---------------------------------------------------------"
podman version

echo "\nk3d  版本"
echo "---------------------------------------------------------"
k3d version

echo "\nkubectl  版本"
echo "---------------------------------------------------------"
kubectl version --client

echo "\nstep  版本"
echo "---------------------------------------------------------"
step version

echo "\nk9s  版本"
echo "---------------------------------------------------------"
k9s version

echo "\n"

echo "========================================================="
echo "標記營地"
echo "========================================================="

HOST_IP=$(ifconfig | grep 'inet ' | awk '{print $2}' | grep -v '127.0.0.1')
sudo hostctl remove talks || true
sudo hostctl add talks -f - <<EOF
$HOST_IP firststep.homelab.test
$HOST_IP ca.homelab.test
EOF

echo "========================================================="
echo "先把地板掃乾淨"
echo "========================================================="

k3d cluster delete talk

echo "========================================================="
echo "搭帳篷"
echo "========================================================="

k3d cluster create --config - <<EOF
---
apiVersion: k3d.io/v1alpha4
kind: Simple
metadata:
  name: talk
servers: 1
agents: 1
ports:
  - port: 18080:80
    nodeFilters:
      - loadbalancer
  - port: 18443:443
    nodeFilters:
      - loadbalancer
EOF

echo "========================================================="
echo "撿木柴"
echo "========================================================="

kubectl create deploy firststep --image nginx --port 80
kubectl create svc clusterip firststep --tcp=80:80
kubectl create ingress firststep --rule="firststep.homelab.test/=firststep:80,tls=firststep-homelab-test-tls"

echo "========================================================="
echo "生火...                                                   "
echo "========================================================="

podman run -d -v step:/home/step \
    --name step-ca \
    -p 9000:9000 \
    -e "TZ=Asia/Taipei" \
    -e "DOCKER_STEPCA_INIT_NAME=Homelab" \
    -e "DOCKER_STEPCA_INIT_DNS_NAMES=localhost,127.0.0.1,ca.homelab.test" \
    -e "DOCKER_STEPCA_INIT_SSH=true" \
    -e "DOCKER_STEPCA_INIT_ACME=false" \
    -e "DOCKER_STEPCA_INIT_REMOTE_MANAGEMENT=true" \
    smallstep/step-ca:0.23.2

echo "========================================================="
echo "添加柴火...                                                "
echo "========================================================="

podman logs step-ca > step-ca.log
cat step-ca.log | grep password | cut -d ":" -f2 | tr -d ' ' > password
rm -f step-ca.log

podman exec -it step-ca cat config/defaults.json | jq -r ".fingerprint" > fingerprint

step ca bootstrap --ca-url https://localhost:9000 --fingerprint "$(cat fingerprint)" --install -f
step ca root > root_ca.crt
step ca root | step base64 > root_ca.b64
step ca provisioner update admin \
  --x509-min-dur 1h \
  --x509-default-dur 24h \
  --x509-max-dur 87660h  \
  --ssh-user-min-dur 15m \
  --ssh-host-default-dur 24h \
  --admin-name=step \
  --admin-password-file=password \
  --admin-provisioner=admin

echo "========================================================="
echo "準備食材...                                                "
echo "========================================================="

helm upgrade --install cert-manager \
  --namespace cert-manager --create-namespace \
  --repo https://charts.jetstack.io cert-manager \
  --wait \
  --set installCRDs=true

helm upgrade --install step-issuer \
    --namespace step-issuer --create-namespace \
    --repo https://smallstep.github.io/helm-charts step-issuer \
    --wait

echo "========================================================="
echo "烹煮                                                      "
echo "========================================================="

kubectl apply -f - <<-EOF
---
apiVersion: v1
kind: Secret
metadata:
  name: step-issuer-provisioner-password
type: Opaque
data:
  password: $(cat password | tr -d '\r\n' | base64)
---
apiVersion: certmanager.step.sm/v1beta1
kind: StepIssuer
metadata:
  name: step-issuer
spec:
  url: "https://ca.homelab.test:9000"
  caBundle: $(step ca root | step base64)
  provisioner:
    name: admin
    kid: $(step ca provisioner list | jq -r '.[] | select(.name=="admin").key.kid')
    passwordRef:
      name: step-issuer-provisioner-password
      key: password
EOF


echo "========================================================="
echo "呈盤                                                      "
echo "========================================================="

kubectl apply -f - <<-EOF
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: firststep-homelab-test
spec:
  # The secret name to store the signed certificate
  secretName: firststep-homelab-test-tls
  # Common Name
  commonName: firststep.homelab.test
  # DNS SAN
  dnsNames:
    - localhost
    - firststep.homelab.test
  # IP Address SAN
  ipAddresses:
    - "127.0.0.1"
  # Duration of the certificate
  duration: 24h
  # Renew 8 hours before the certificate expiration
  renewBefore: 8h
  # The reference to the step issuer
  issuerRef:
    group: certmanager.step.sm
    kind: StepIssuer
    name: step-issuer
EOF