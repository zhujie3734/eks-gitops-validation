# GitHub CI/CD

1. 指定最终 GitHub 仓库，设置 origin 并推送 main。框架不会自行创建/推送远程仓库。
2. 启用 Actions read/write permissions 和 Allow GitHub Actions to create and approve pull requests（仅创建，不自动审批/合并）。
3. build workflow 构建 ghcr.io/OWNER/REPO/frontend:SOURCE_SHA 和 backend，创建 kind 镜像版本 PR。release 路径不触发镜像构建，避免循环。
4. GHCR 镜像设为 public，或在目标 namespace 创建 imagePullSecret，并配置 values.imagePullSecrets。不要把 token 写进 Git。
5. 合并镜像 PR 后，让本地 Argo CD 读取 GitHub：

```powershell
powershell -ExecutionPolicy Bypass -File .\lab.ps1 use-github https://github.com/OWNER/REPO.git
```

私有仓库需要 Argo CD repository credential。切换后用 GitHub PR 发布，不执行本地 release/up（up 会切回本地 Git 模式）。验证前 git pull，使本地 HEAD 与目标 main 对齐。Argo 默认轮询可能需要几分钟，可用 UI Refresh。

GitHub runner 不需要访问 Windows Kubernetes API；Argo CD 从集群主动拉取 Git。源码构建失败不改变 release，PR 未合并不更新环境。由 GITHUB_TOKEN 创建的 PR 通常不会触发其他 workflow；强制 PR 检查时用 GitHub App token 创建 PR，或单独安排验证。

EKS 晋级：把 kind 验证过的 GHCR 同一 tag 写入 environments/eks/release.yaml 并走 PR，不重新构建。当前 workflow 构建 linux/amd64；Graviton 节点需增加 QEMU/arm64 构建。
