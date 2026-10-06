#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
[[ -d "$STATE/git/repo.git" ]] || { echo 'Run up first'; exit 1; }
# Push committed content only. Argo CD reads the bare repo over HTTP.
gitlab push "$STATE/git/repo.git" HEAD:refs/heads/main
git --git-dir="$STATE/git/repo.git" update-server-info
echo "Published $(gitlab rev-parse HEAD) to the local Git remote."
