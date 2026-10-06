# 选择性迁入记录

按能力和文件选择性迁入并适配，不是把两个不相关仓库的全部历史直接 cherry-pick。

| 来源 | 固定 revision | 迁入内容 |
|---|---|---|
| https://github.com/zhujie3734/kubernetes-example | 6bf9b8411eb5a174a181343f4082de2c7edff896 | backend 文本增删查接口、React 前端交互及样式、双镜像构建、Helm frontend/backend/database/Ingress 拆分 |
| https://github.com/zhujie3734/gitops | fd684d1277517050938ebeaa533054f4d3318f47 | gitops-workflow/23/application.yaml 的 Argo CD + Helm + Git 写回思路；环境分离模式 |

旧代码引用 lyzhang1999 的仓库/镜像，gitops 也显示 fork 来源；保留来源说明。

更新 Python 3.8/Node 16 为 Python 3.12/Node 22；React 开发服务器改为 Vite + nginx；修复 SQLAlchemy 重复初始化；密码通过 Secret；前端代理 /api 避免不同 Ingress rewrite 注解差异；未迁入弃用的 HPA API、重复 CD 工具和无关示例。

镜像更新采用 Git release 提交/PR，替代旧 Image Updater 的 latest 注解。kind/EKS 独立 release，防止本地 registry 地址进入 EKS。

参考：https://kind.sigs.k8s.io/docs/user/local-registry/ 、https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/ 、https://docs.github.com/en/actions/tutorials/publish-packages/publish-docker-images
