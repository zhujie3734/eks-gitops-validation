#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
local_context
if ! docker container inspect gitops-lab-registry >/dev/null 2>&1; then
  docker run -d --restart=unless-stopped --name gitops-lab-registry \
    --label project=gitops-lab --network kind -p 127.0.0.1:5001:5000 \
    -v gitops-lab-registry:/var/lib/registry registry:3
else
  docker start gitops-lab-registry >/dev/null
fi
for node in $(kind get nodes --name "$CLUSTER"); do
  docker exec "$node" mkdir -p /etc/containerd/certs.d/localhost:5001
  printf '[host."http://gitops-lab-registry:5000"]\n' |
    docker exec -i "$node" sh -c 'cat > /etc/containerd/certs.d/localhost:5001/hosts.toml'
done
