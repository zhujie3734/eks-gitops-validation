#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
repo=${1:?Usage: use-github.sh https://github.com/OWNER/REPO.git}
[[ "$repo" =~ ^https://github\.com/[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+(\.git)?$ ]] || { echo 'Expected GitHub HTTPS URL'; exit 1; }
local_context
# Private repositories additionally need an Argo CD repository credential Secret.
kubectl -n argocd patch appproject lab --type=merge -p "{\"spec\":{\"sourceRepos\":[\"$repo\"]}}"
kubectl -n argocd patch application "$APP" --type=merge -p "{\"spec\":{\"source\":{\"repoURL\":\"$repo\"}}}"
echo 'Argo CD now watches GitHub main. Use GitHub PRs for releases; local release.sh publishes only to local Git.'
