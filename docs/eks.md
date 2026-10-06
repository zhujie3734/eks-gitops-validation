# EKS 基础设施接口

应用仓库接收 cluster_name、aws_region、AWS profile/assume-role、Git repo URL，不耦合 Terraform module 内部结构。

EKS 仓库应提供：
- API endpoint 可达、EKS access entry/RBAC。
- argocd namespace 中的 Argo CD。
- AWS Load Balancer Controller、IngressClass alb、子网标签与 IAM。
- RDS PostgreSQL endpoint、网络连通、数据库和用户。
- gitops-example namespace、example-database Secret（password 键），可由 External Secrets 从 Secrets Manager 同步。
- 域名、DNS、ACM TLS 配置；当前示例没有默认 HTTPS。
- 集群能拉取的 GHCR/ECR 镜像与版本。

推荐 EKS 内运行自己的 Argo CD，不依赖 Windows 长期开机。基础设施仓库在部署完成后调用引导脚本，或声明同样的 AppProject/Application。

替换 environments/eks 下全部 REPLACE_WITH 字段并提交。按需设置 ALB certificate-arn、listen-ports、ssl-redirect 注解。在已登录 AWS CLI 的 Linux/WSL 执行：

```bash
bash scripts/bootstrap-eks.sh MY_CLUSTER eu-west-2 https://github.com/OWNER/REPO.git MY_PROFILE
```

使用独立 .state/eks-kubeconfig，检查 EKS context、Argo CD、数据库 Secret，然后引导应用。不会执行 Terraform 或创建收费基础设施。私有 Git/镜像要提前提供凭据。

尚待 EKS 仓库地址，以对齐真实 outputs、Argo CD/ALB 安装方式和 IAM。当前是渲染校验的接口模板，未在真实 EKS 上执行。
