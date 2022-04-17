#!/bin/bash +x
set -e

cd "$(dirname "$0")"
k3d cluster delete --config cluster-talk.yaml
