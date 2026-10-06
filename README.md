# Kubernetes GitOps Lab

Windows + WSL2 Ubuntu + kind 应用验证仓库。

流程：apps → Docker build/push → Git 中的 release.yaml → Argo CD → Helm → Kubernetes → HTTP 验证。

## 快速开始

```powershell
cd 'D:\Work\Other Projects\k8s_env'
# 新机器先安装 WSL2 + Ubuntu，然后安装工具：
powershell -ExecutionPolicy Bypass -File .\lab.ps1 setup
# 创建/复用 windows-lab，部署组件和应用：
powershell -ExecutionPolicy Bypass -File .\lab.ps1 up
powershell -ExecutionPolicy Bypass -File .\lab.ps1 status
curl.exe --noproxy "*" -H 'Host: gitops.local' http://127.0.0.1:8080/api/healthy
```

浏览器访问：Windows hosts 添加 `127.0.0.1 gitops.local` 后打开 http://gitops.local:8080/ 。React 前端可添加/查询/清空 PostgreSQL 文本数据。原 test/nginx 应用仍匹配 nginx.local。

## 开发与发布

```powershell
git add apps charts
git commit -m 'feat: update application'
powershell -ExecutionPolicy Bypass -File .\lab.ps1 validate
powershell -ExecutionPolicy Bypass -File .\lab.ps1 build
powershell -ExecutionPolicy Bypass -File .\lab.ps1 release
powershell -ExecutionPolicy Bypass -File .\lab.ps1 verify
```

build 构建双镜像并推送本地 registry，默认标签是源码提交 SHA。release 只提交 kind 镜像版本文件并 push 到本地 Git remote，等待 Argo CD 在该 revision 达到 Synced/Healthy。应用由 Argo CD 部署；脚本不会直接 apply 应用 Deployment。只修改 chart/config 时，提交后执行 publish 和 verify 即可。

首次 up 包含构建和发布。自动 release 提交使用 GitOps Lab <gitops-lab@localhost>；自己的源码提交请配置 Git user.name/user.email。

```powershell
# 完整升级、漂移修复、Git 回滚测试，结束恢复原镜像版本
powershell -ExecutionPolicy Bypass -File .\lab.ps1 test-gitops
# 回滚到已构建过的标签
powershell -ExecutionPolicy Bypass -File .\lab.ps1 release PREVIOUS_TAG
```

## 目录

| 路径 | 用途 |
|---|---|
| apps/ | 前后端源码、Dockerfile |
| charts/example/ | kind/EKS 共用 Helm chart |
| environments/kind/ | 本地拓扑与独立 release |
| environments/eks/ | 云端拓扑与独立 release |
| gitops/ | Argo CD Project/Application |
| infra/kind/ | kind/Ingress 配置 |
| scripts/ | 安装、构建、发布、验证、恢复 |
| .github/workflows/ | manifest 检查、镜像构建、发布 PR |
| .state/ | kubeconfig、密码、Git remote、缓存；不提交 |
| docs/ | 来源映射、GitHub、EKS、恢复说明 |

## Argo CD

```powershell
powershell -ExecutionPolicy Bypass -File .\lab.ps1 ui
# 在另一个终端查询初始密码：
powershell -ExecutionPolicy Bypass -File .\lab.ps1 password
```

访问 https://localhost:8443 ，用户名 admin，本地自签名证书。端口转发期间保持终端开启。脚本只在主动执行 password 时输出密码。

## 重建

```powershell
# 删除整个 windows-lab，包括其他 namespace 和数据库数据：
powershell -ExecutionPolicy Bypass -File .\lab.ps1 down --confirm
powershell -ExecutionPolicy Bypass -File .\lab.ps1 up
```

默认数据库是临时数据。源码/YAML 在 D 盘，Docker 镜像/volume、Ubuntu 虚拟磁盘仍由 WSL 管理。原文件备份位于 .state/legacy-backup。详情见 [恢复说明](docs/recovery.md)。

本地 Git/registry 模式无需 GitHub token，验证真实 Git push/pull、镜像构建、同步和回滚。远端 Actions/GHCR 需接入最终仓库后验证：[GitHub 流程](docs/github.md)。

EKS 内运行独立 Argo CD，读取同仓库 environments/eks；EKS/VPC/IAM/ALB/RDS 由基础设施仓库管理。[EKS 接口](docs/eks.md) 尚待真实仓库地址对齐。[选择性迁入记录](docs/provenance.md)列出来源 SHA 和适配点。
