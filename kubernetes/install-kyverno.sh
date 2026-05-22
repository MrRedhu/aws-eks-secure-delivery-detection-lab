#!/bin/bash
set -euo pipefail

KYVERNO_VERSION="${KYVERNO_VERSION:-v1.17.1}"

echo "Installing Kyverno ${KYVERNO_VERSION} with server-side apply..."
kubectl apply --server-side --force-conflicts \
  -f "https://github.com/kyverno/kyverno/releases/download/${KYVERNO_VERSION}/install.yaml"

echo "Waiting for Kyverno deployments..."
kubectl -n kyverno wait --for=condition=available deployment --all --timeout=300s

echo "Applying custom Kyverno policies..."
kubectl apply -f ../policies/kyverno --recursive

echo "Kyverno installation complete."
