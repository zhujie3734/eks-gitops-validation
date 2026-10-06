#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
local_context
wait_app "$(gitlab rev-parse HEAD)"
kubectl -n "$NAMESPACE" rollout status deployment/backend --timeout=180s
kubectl -n "$NAMESPACE" rollout status deployment/frontend --timeout=180s
kubectl get nodes
kubectl get pods -A
kubectl top nodes
http / | grep -q 'GitOps Lab'
http /api/healthy
echo
http /api/fetch
echo
echo 'PASS: Git revision, Argo CD health, rollouts, frontend, backend, database, metrics.'
