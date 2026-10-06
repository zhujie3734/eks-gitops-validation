# 本机验证记录（2026-10-06）

目标目录：D:\Work\Other Projects\k8s_env。复用 windows-lab，原 test/nginx 保留。

已通过：
- PowerShell/Bash/Python 语法检查。
- kind、EKS Helm lint/template；kubeconform strict：12 valid / 0 invalid / 0 errors。
- 前后端 Docker 构建并推送 localhost:5001，节点从 registry 拉取镜像。
- Argo CD v3.5.3 从本地 Git 服务读取真实 Git 提交，Synced + Healthy。
- test-gitops：发布 test-20261006131803 → HTTP 验证版本 → 临时扩容 backend 为 3，自动修复为 1 → Git 提交回滚到 cffa51a5200b → HTTP 验证回滚。
- 3 个节点 Ready，所有 Pod Running/Ready；Metrics Server 返回节点指标。
- Windows HTTP 访问 /api/healthy，并向 PostgreSQL 写入/读取 gitops-validation-20261006 示例记录。

未执行：GitHub Actions 远端构建/PR，GHCR 权限，真实 EKS 引导/部署；待最终 GitHub 仓库地址、身份授权、EKS 仓库与输出参数。

本地默认数据库是临时数据。完整日志/缓存可保存在 .state；不要把 kubeconfig 或密码提交到 Git。
