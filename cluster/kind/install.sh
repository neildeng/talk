#!/bin/bash +x
set -e

cd "$(dirname "$0")"

kind create cluster --config cluster-talk.yaml