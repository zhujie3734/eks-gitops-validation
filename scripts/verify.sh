#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
local_context
wait_app "$(gitlab rev-parse HEAD)"
kubectl -n "$NAMESPACE" rollout status deployment/backend --timeout=180s
kubectl -n "$NAMESPACE" rollout status deployment/frontend --timeout=180s
kubectl get nodes
kubectl get pods -A
kubectl top nodes
curl -fsS --retry 20 --retry-all-errors --retry-delay 2 -H 'Host: gitops.local' http://127.0.0.1:8080/ | grep -q 'GitOps Lab'
curl -fsS -H 'Host: gitops.local' http://127.0.0.1:8080/api/healthy
echo
curl -fsS -H 'Host: gitops.local' http://127.0.0.1:8080/api/fetch
echo
echo 'PASS: Git revision, Argo CD health, rollouts, frontend, backend, database, metrics.'
