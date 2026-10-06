#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
[[ -z $(gitlab status --porcelain -- apps) ]] || { echo 'Commit application changes before building a release.'; exit 1; }
tag=${1:-$(gitlab rev-parse --short=12 HEAD)}
[[ "$tag" =~ ^[a-zA-Z0-9_][a-zA-Z0-9_.-]{0,127}$ ]] || { echo 'Invalid image tag'; exit 1; }
for app in backend frontend; do
  docker build --build-arg "VERSION=$tag" -t "localhost:5001/gitops-lab/$app:$tag" "$ROOT/apps/$app"
  docker push "localhost:5001/gitops-lab/$app:$tag"
done
printf '%s\n' "$tag" > "$STATE/last-build"
