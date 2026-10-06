#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -eq 0 ]] || { echo 'Run setup as root (sudo bash setup-ubuntu.sh).'; exit 1; }
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y docker.io curl ca-certificates tar
if [[ $(ps -p 1 -o comm=) == systemd ]]; then
  systemctl enable --now docker
else
  service docker start
fi
docker info >/dev/null
arch=$(dpkg --print-architecture)
case "$arch" in amd64|arm64) ;; *) echo "Unsupported architecture: $arch"; exit 1;; esac
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
curl -fL --retry 3 "https://kind.sigs.k8s.io/dl/v0.33.0/kind-linux-$arch" -o "$tmp/kind"
install -m 0755 "$tmp/kind" /usr/local/bin/kind
curl -fL --retry 3 "https://dl.k8s.io/release/v1.35.0/bin/linux/$arch/kubectl" -o "$tmp/kubectl"
curl -fL --retry 3 "https://dl.k8s.io/release/v1.35.0/bin/linux/$arch/kubectl.sha256" -o "$tmp/kubectl.sha256"
(cd "$tmp"; echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check)
install -m 0755 "$tmp/kubectl" /usr/local/bin/kubectl
curl -fL --retry 3 "https://get.helm.sh/helm-v3.19.0-linux-$arch.tar.gz" -o "$tmp/helm.tar.gz"
curl -fL --retry 3 "https://get.helm.sh/helm-v3.19.0-linux-$arch.tar.gz.sha256sum" -o "$tmp/helm.sha256"
(cd "$tmp"; sed "s/helm-v3.19.0-linux-$arch.tar.gz/helm.tar.gz/" helm.sha256 | sha256sum --check)
tar -xzf "$tmp/helm.tar.gz" -C "$tmp"
install -m 0755 "$tmp/linux-$arch/helm" /usr/local/bin/helm
kind version
kubectl version --client
helm version
