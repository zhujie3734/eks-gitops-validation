#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
for script in scripts/*.sh; do bash -n "$script"; done
python3 -m py_compile scripts/set-release.py apps/backend/app.py
for environment in kind eks; do
  helm lint charts/example -f "environments/$environment/values.yaml" -f "environments/$environment/release.yaml"
  helm template example charts/example -n gitops-lab -f "environments/$environment/values.yaml" -f "environments/$environment/release.yaml" > "$STATE/rendered-$environment.yaml"
done
echo 'PASS: shell/Python syntax and Helm render for kind + EKS.'
