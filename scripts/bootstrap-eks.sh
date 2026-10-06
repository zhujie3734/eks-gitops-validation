#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT"
cluster=${1:?Usage: bootstrap-eks.sh CLUSTER REGION REPO_URL [AWS_PROFILE]}
region=${2:?AWS region required}
repo=${3:?Git repository URL required}
profile=${4:-default}
[[ "$cluster" =~ ^[A-Za-z0-9][A-Za-z0-9_-]*$ ]] || exit 1
[[ "$region" =~ ^[a-z0-9-]+$ && "$repo" =~ ^https://github\.com/[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+(\.git)?$ ]] || exit 1
if grep -Rq 'REPLACE_WITH_' environments/eks; then echo 'Configure environments/eks first.'; exit 1; fi
mkdir -p .state
export KUBECONFIG="$ROOT/.state/eks-kubeconfig"
aws eks update-kubeconfig --name "$cluster" --region "$region" --profile "$profile" --alias "eks-$cluster"
[[ $(kubectl config current-context) == "eks-$cluster" ]] || exit 1
kubectl -n argocd get deployment argocd-server >/dev/null || { echo 'Install Argo CD through the EKS infrastructure repository first.'; exit 1; }
kubectl -n gitops-example get secret example-database >/dev/null || { echo 'Provision gitops-example namespace and example-database Secret first.'; exit 1; }
cat <<EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: applications
  namespace: argocd
spec:
  sourceRepos: ["$repo"]
  destinations:
    - namespace: gitops-example
      server: https://kubernetes.default.svc
  clusterResourceWhitelist: []
  namespaceResourceWhitelist:
    - group: '*'
      kind: '*'
EOF
sed "s|REPLACE_WITH_GITHUB_REPO_URL|$repo|" gitops/eks/application.template.yaml | kubectl apply -f -
echo 'Argo CD on EKS now tracks environments/eks. Verify its Synced/Healthy status.'
