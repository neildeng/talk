#!/bin/bash +x
set -e

cd "$(dirname "$0")"

kind delete cluster --name talk