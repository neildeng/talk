#!/bin/bash +x
set -e

helm uninstall cert-manager --namespace cert-manager
