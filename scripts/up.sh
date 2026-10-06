#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
for tool in kind kubectl helm docker git python3 curl; do command -v "$tool" >/dev/null || { echo "Missing $tool; run lab.ps1 setup"; exit 1; }; done
docker info >/dev/null
if ! kind get clusters | grep -Fxq "$CLUSTER"; then
  kind create cluster --name "$CLUSTER" --image kindest/node:v1.35.0 --config infra/kind/kind.yaml --kubeconfig "$KUBECONFIG" --wait 5m
fi
local_context
kubectl wait --for=condition=Ready nodes --all --timeout=300s
helm upgrade --install nginx-ingress oci://ghcr.io/nginx/charts/nginx-ingress --version 2.7.3 -n nginx-ingress --create-namespace -f infra/kind/nginx-values.yaml --wait --timeout 5m
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/ --force-update
helm repo update metrics-server
helm upgrade --install metrics-server metrics-server/metrics-server --version 3.14.0 -n kube-system --set 'args[0]=--kubelet-insecure-tls' --wait --timeout 5m
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
curl -fsSL --retry 3 https://raw.githubusercontent.com/argoproj/argo-cd/v3.5.3/manifests/install.yaml -o "$STATE/argocd-install.yaml"
kubectl apply --server-side -n argocd -f "$STATE/argocd-install.yaml"
kubectl -n argocd rollout status deployment/argocd-repo-server --timeout=300s
kubectl -n argocd rollout status statefulset/argocd-application-controller --timeout=300s
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -
if ! kubectl -n "$NAMESPACE" get secret example-database >/dev/null 2>&1; then
  python3 -c 'import secrets; print(secrets.token_urlsafe(32),end="")' > "$STATE/database-password"
  chmod 600 "$STATE/database-password"
  kubectl -n "$NAMESPACE" create secret generic example-database --from-file=password="$STATE/database-password"
fi
bash scripts/registry.sh
bash scripts/local-git.sh
kubectl apply -f gitops/kind/project.yaml -f gitops/kind/application.yaml
bash scripts/build.sh
bash scripts/release.sh
wait_app "$(gitlab rev-parse HEAD)"
bash scripts/verify.sh
