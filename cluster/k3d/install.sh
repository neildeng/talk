#!/bin/bash +x
set -e

cd "$(dirname "$0")"
k3d cluster create --config cluster-talk.yaml

host_k3d_internal_ip=$(kubectl -n kube-system describe cm coredns | grep host.k3d.internal | awk '{print $1}')
cat ../../hosts/hosts | grep -v '#' | grep -v '^$' | sed "s/127.0.0.1/    $host_k3d_internal_ip/g" | while read -r host
do
  kubectl -n kube-system get cm coredns -o yaml | sed "s/NodeHosts: |/NodeHosts: |\n    $host/" | kubectl -n kube-system apply -f -
done