#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
local_context
mkdir -p "$STATE/git"
if [[ ! -d "$STATE/git/repo.git" ]]; then
  git init --bare --initial-branch=main "$STATE/git/repo.git"
fi
if ! docker container inspect gitops-lab-git >/dev/null 2>&1; then
  docker build -t gitops-lab/git-server:local infra/local-git
  docker run -d --restart=unless-stopped --name gitops-lab-git \
    --label project=gitops-lab --network kind \
    -v "$STATE/git:/git:ro" gitops-lab/git-server:local
else
  actual=$(docker inspect -f '{{range .Mounts}}{{if eq .Destination "/git"}}{{.Source}}{{end}}{{end}}' gitops-lab-git)
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
    - name: git
      port: 9418
      targetPort: 9418
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
  - name: git
    protocol: TCP
    port: 9418
endpoints:
  - addresses: ["$address"]
    conditions:
      ready: true
EOF
