#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
local_context
mkdir -p "$STATE/git"
if [[ ! -d "$STATE/git/repo.git" ]]; then
  git init --bare --initial-branch=main "$STATE/git/repo.git"
fi
if ! docker container inspect gitops-lab-git >/dev/null 2>&1; then
  docker run -d --restart=unless-stopped --name gitops-lab-git \
    --label project=gitops-lab --network kind \
    -v "$STATE/git:/usr/share/nginx/html:ro" nginx:1.28.0-alpine
else
  actual=$(docker inspect -f '{{range .Mounts}}{{if eq .Destination "/usr/share/nginx/html"}}{{.Source}}{{end}}{{end}}' gitops-lab-git)
  [[ "$actual" == "$STATE/git" ]] || { echo "Git server belongs to $actual; stop/remove gitops-lab-git before relocating the repo."; exit 1; }
  docker start gitops-lab-git >/dev/null
fi
address=$(docker inspect -f '{{.NetworkSettings.Networks.kind.IPAddress}}' gitops-lab-git)
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: lab-git
  namespace: argocd
spec:
  ports:
    - name: http
      port: 80
      targetPort: 80
---
apiVersion: discovery.k8s.io/v1
kind: EndpointSlice
metadata:
  name: lab-git
  namespace: argocd
  labels:
    kubernetes.io/service-name: lab-git
addressType: IPv4
ports:
  - name: http
    protocol: TCP
    port: 80
endpoints:
  - addresses: ["$address"]
    conditions:
      ready: true
EOF
