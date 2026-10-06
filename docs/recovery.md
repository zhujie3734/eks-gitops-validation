# D 盘恢复

目录可整体复制，支持空格。进入目录执行 lab.ps1 setup / up。原文件备份位于 .state/legacy-backup。

lab.ps1 启动隐藏的 WSL 保活进程。Windows 重启后重新 up；若 kind 节点 IP 改变导致网络失效，备份数据后 down --confirm，再 up。down 删除整个 windows-lab（包括原 test namespace），保留 registry volume 和本地 Git 历史。

迁移项目目录后，如果 gitops-lab-git 仍挂载旧位置，先 `wsl -d Ubuntu -u root -- docker rm -f gitops-lab-git`，再 up。此操作只替换 Git 服务容器，历史在 .state/git 和 .git 中。

默认 PostgreSQL 为 emptyDir，Pod/集群重建会丢失数据。可启用 persistence，但 kind 的 local-path 存储仍会随节点删除；重要数据需 pg_dump 到 D 盘再单独备份。YAML 只恢复配置。

源码和 YAML 在 D 盘；Docker 镜像/volume、Ubuntu 虚拟磁盘仍由 WSL 管理。移动项目不等于迁移运行数据。不得提交 kubeconfig、密码、token、Terraform state；gitignore 已排除这些内容。
