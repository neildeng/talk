#!/bin/bash +x
set -e

cd "$(dirname "$0")"

kubectl create secret tls hello-tls --cert=./../../tls/hello.k8s.edu.local.pem --key=./../../tls/hello.k8s.edu.local-key.pem
