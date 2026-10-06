#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
tag=${1:-$(cat "$STATE/last-build")}
for app in frontend backend; do
  curl -fsS -H 'Accept: application/vnd.docker.distribution.manifest.v2+json' \
    "http://localhost:5001/v2/gitops-lab/$app/manifests/$tag" >/dev/null
done
python3 scripts/set-release.py kind localhost:5001/gitops-lab "$tag"
gitlab add environments/kind/release.yaml
if ! gitlab diff --cached --quiet -- environments/kind/release.yaml; then
  gitlab -c user.name='GitOps Lab' -c user.email='gitops-lab@localhost' commit -m "deploy(kind): release $tag" --only environments/kind/release.yaml
fi
bash scripts/publish.sh
local_context
if kubectl -n argocd get application "$APP" >/dev/null 2>&1; then
  wait_app "$(gitlab rev-parse HEAD)"
fi
