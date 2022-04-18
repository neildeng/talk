#!/bin/bash +x
set -e

cd "$(dirname "$0")"

k3d cluster create --config cluster-talk.yaml