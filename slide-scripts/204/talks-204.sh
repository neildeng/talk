#!/usr/bin/env bash

echo "========================================================="
echo "+                                                       +"
echo "+  Talks 204 - Blackbox                                 +"
echo "+                                                       +"
echo "========================================================="

set -o errexit
set -o pipefail
set -o nounset

WORKDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$WORKDIR"

echo "========================================================="
echo "標記營地"
echo "========================================================="

HOST_IP=$(ifconfig | grep 'inet ' | awk '{print $2}' | grep -v '127.0.0.1')
sudo hostctl remove talks-204 || true
sudo hostctl add talks-204 -f - <<EOF
$HOST_IP blackbox.exporter.homelab.test
EOF


sh ../203/talks-203.sh

echo "
config:
  modules:
    http_2xx:
      prober: http
      timeout: 3s
      http:
        valid_http_versions: [\"HTTP/1.1\", \"HTTP/2.0\"]
        follow_redirects: true
        preferred_ip_protocol: \"ip4\"
        tls_config:
          insecure_skip_verify: true
    tcp_connect:
      prober: tcp
      timeout: 3s
      tcp:
        ip_protocol_fallback: false
        preferred_ip_protocol: ip4
        tls: true
        tls_config:
          insecure_skip_verify: true
serviceMonitor:
  enabled: true
  defaults:
    labels:
      release: lgtm-aio
  targets:
    - name: https-exporter-google
      url: https://google.com
      module: http_2xx
    - name: tcp-exporter-line
      url: line.me:443
      module: tcp_connect
" |
  helm upgrade --install blackbox-exporter \
    --namespace observability --create-namespace \
    --repo https://prometheus-community.github.io/helm-charts prometheus-blackbox-exporter \
    --version 7.5.0 --wait \
    --values -
