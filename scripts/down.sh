#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
[[ ${1:-} == --confirm ]] || { echo 'This deletes windows-lab and ALL its workloads/data, including other namespaces. Run lab.ps1 down --confirm'; exit 1; }
kind delete cluster --name "$CLUSTER"
for container in gitops-lab-git gitops-lab-registry; do
  if docker container inspect "$container" >/dev/null 2>&1; then docker rm -f "$container"; fi
done
rm -f "$KUBECONFIG"
echo 'Cluster deleted; local Git history and registry volume retained.'
