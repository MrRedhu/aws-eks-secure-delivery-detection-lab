#!/bin/bash
set -e

echo "Adding Kyverno Helm repository..."
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update

echo "Installing Kyverno..."
helm upgrade --install kyverno kyverno/kyverno \
  -n kyverno --create-namespace \
  --set admissionController.replicas=1

echo "Waiting for Kyverno to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=kyverno -n kyverno --timeout=120s

echo "Applying custom Kyverno policies..."
kubectl apply -f ../policies/

echo "Kyverno installation complete!"
