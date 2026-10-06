#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
local_context
original=$(python3 -c 'import re; print(re.search(r"tag:\s*[\"\x27]?([^\s\"\x27]+)",open("environments/kind/release.yaml").read()).group(1))')
tag="test-$(date -u +%Y%m%d%H%M%S)"
bash scripts/build.sh "$tag"
bash scripts/release.sh "$tag"
curl -fsS -H 'Host: gitops.local' http://127.0.0.1:8080/api/healthy | python3 -c 'import json,sys; assert json.load(sys.stdin)["version"]==sys.argv[1]' "$tag"
# Demonstrate drift correction without applying desired application manifests.
kubectl -n "$NAMESPACE" scale deployment backend --replicas=3
kubectl -n argocd annotate application "$APP" argocd.argoproj.io/refresh=hard --overwrite >/dev/null
for attempt in {1..60}; do
  [[ $(kubectl -n "$NAMESPACE" get deployment backend -o jsonpath='{.spec.replicas}') == 1 ]] && break
  [[ $attempt -lt 60 ]] || { echo 'Self-heal failed'; exit 1; }
  sleep 3
done
# Rollback is another Git commit pointing at the previously built tag.
bash scripts/release.sh "$original"
curl -fsS -H 'Host: gitops.local' http://127.0.0.1:8080/api/healthy | python3 -c 'import json,sys; assert json.load(sys.stdin)["version"]==sys.argv[1]' "$original"
bash scripts/verify.sh
echo 'PASS: image build/push, Git promotion, auto-sync, drift self-heal, Git rollback.'
