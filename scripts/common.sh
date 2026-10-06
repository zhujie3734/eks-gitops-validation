#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$ROOT"
STATE="$ROOT/.state"
mkdir -p "$STATE"
export KUBECONFIG="$STATE/kubeconfig"
export KIND_EXPERIMENTAL_PROVIDER=docker
CLUSTER=windows-lab
APP=example-kind
NAMESPACE=gitops-lab
gitlab() { git -c safe.directory="$ROOT" "$@"; }
local_context() {
  kind export kubeconfig --name "$CLUSTER" --kubeconfig "$KUBECONFIG" >/dev/null
  [[ $(kubectl config current-context) == "kind-$CLUSTER" ]] || { echo 'Wrong cluster'; exit 1; }
}
wait_app() {
  local revision=$1
  kubectl -n argocd annotate application "$APP" argocd.argoproj.io/refresh=hard --overwrite >/dev/null
  for attempt in {1..120}; do
    local status
    status=$(kubectl -n argocd get application "$APP" -o json)
    if python3 -c 'import json,sys; s=json.load(sys.stdin).get("status",{}); sys.exit(not (s.get("sync",{}).get("revision")==sys.argv[1] and s.get("sync",{}).get("status")=="Synced" and s.get("health",{}).get("status")=="Healthy"))' "$revision" <<< "$status"; then
      echo "Argo CD Synced/Healthy at $revision"; return
    fi
    sleep 5
  done
  kubectl -n argocd get application "$APP" -o yaml
  kubectl -n "$NAMESPACE" get pods
  echo 'Argo CD reconciliation timed out' >&2
  return 1
}
