#!/usr/bin/env bash
# Install cert-manager (Helm) and apply ClusterIssuers from this directory.
# Prerequisites: kubectl configured, NGINX Ingress with ingressClassName nginx.
# Idempotent: safe to re-run.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CERT_MANAGER_CHART_VERSION="${CERT_MANAGER_CHART_VERSION:-v1.16.2}"
NAMESPACE="${CERT_MANAGER_NAMESPACE:-cert-manager}"

if ! command -v helm >/dev/null 2>&1; then
  echo "error: helm not found. Install from https://helm.sh/docs/intro/install/" >&2
  exit 1
fi
if ! command -v kubectl >/dev/null 2>&1; then
  echo "error: kubectl not found" >&2
  exit 1
fi

helm repo add jetstack https://charts.jetstack.io 2>/dev/null || true
helm repo update jetstack

# Reduced requests for small DOKS nodes; omit SMALL_NODE=0 to use chart defaults.
HELM_SET_ARGS=()
if [ "${SMALL_NODE:-1}" != "0" ]; then
  HELM_SET_ARGS+=(
    --set "resources.requests.memory=64Mi"
    --set "resources.requests.cpu=50m"
    --set "resources.limits.memory=128Mi"
    --set "webhook.resources.requests.memory=64Mi"
    --set "webhook.resources.requests.cpu=50m"
    --set "webhook.resources.limits.memory=128Mi"
    --set "cainjector.resources.requests.memory=64Mi"
    --set "cainjector.resources.requests.cpu=50m"
    --set "cainjector.resources.limits.memory=128Mi"
  )
fi

echo "Installing cert-manager chart ${CERT_MANAGER_CHART_VERSION} into namespace ${NAMESPACE}..."
helm upgrade --install cert-manager jetstack/cert-manager \
  --namespace "${NAMESPACE}" \
  --create-namespace \
  --version "${CERT_MANAGER_CHART_VERSION}" \
  --set crds.enabled=true \
  --set startupapicheck.enabled=true \
  "${HELM_SET_ARGS[@]}"

echo "Waiting for cert-manager deployments..."
kubectl wait --for=condition=Available deployment/cert-manager -n "${NAMESPACE}" --timeout=300s
kubectl wait --for=condition=Available deployment/cert-manager-webhook -n "${NAMESPACE}" --timeout=300s
kubectl wait --for=condition=Available deployment/cert-manager-cainjector -n "${NAMESPACE}" --timeout=300s

echo "Applying ClusterIssuers (letsencrypt-staging, letsencrypt-prod)..."
kubectl apply -k "${SCRIPT_DIR}"

echo "ClusterIssuers:"
kubectl get clusterissuer

echo "Done. Deploy the staging overlay, then watch:"
echo "  kubectl get certificate -n coffeeshop-staging"
echo "  kubectl describe certificate coffeeshop-tls -n coffeeshop-staging"
