#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
action=${1:-status}; shift || true
case "$action" in
  setup|up|build|release|publish|down|test-gitops|use-github)
    exec 9>"$STATE/operation.lock"
    flock -n 9 || { echo 'Another lab operation is running.'; exit 1; } ;;
esac
case "$action" in
  setup) bash scripts/setup-tools.sh; apt-get install -y git python3 ;;
  up|build|release|publish|verify|down|validate|test-gitops|use-github) bash "scripts/$action.sh" "$@" ;;
  status) local_context; kubectl get nodes; kubectl -n argocd get applications; kubectl -n "$NAMESPACE" get pods ;;
  ui) local_context; kubectl -n argocd port-forward service/argocd-server 8443:443 ;;
  password) local_context; kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d; echo ;;
  *) echo "Unknown action: $action"; exit 1 ;;
esac
