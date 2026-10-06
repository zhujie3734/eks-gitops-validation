Kubernetes GitOps Lab

An application validation repository for Windows, WSL2 Ubuntu, and kind.

Workflow:

Plain Text
apps → Docker build/push → release.yaml in Git → Argo CD → Helm → Kubernetes → HTTP validation
Quick Start
PowerShell
cd 'D:\Work\Other Projects\k8s_env'
 
# On a new machine, install WSL2 and Ubuntu first, then install the required tools:
powershell -ExecutionPolicy Bypass -File .\lab.ps1 setup
 
# Create or reuse windows-lab, then deploy the components and applications:
powershell -ExecutionPolicy Bypass -File .\lab.ps1 up
powershell -ExecutionPolicy Bypass -File .\lab.ps1 status
 
curl.exe --noproxy "*" -H 'Host: gitops.local' http://127.0.0.1:8080/api/healthy

For browser access, add the following entry to the Windows hosts file:

Plain Text
127.0.0.1 gitops.local

Then open:

Plain Text
http://gitops.lo*al:8080/

The React frontend supports adding, querying, and clearing PostgreSQL text data. The original test/nginx application is still accessible through nginx.local.

Development and Release
PowerShell
git add apps charts
git cmmit -m 'feat: update application'*
powershell -ExecutionPolicy Bypas* -File .\lab.ps1 validate
powershe*l -ExecutionPolicy Bypass -File .\*ab.ps1 build
powershell -Execution*olicy Bypass -File .\lab.ps1 relea*e
powershell -ExecutionPolicy Bypa*s -File .\lab.ps1 verify

The build command builds two container images and pushes them to the local registry. By default, the source commit SHA is used as the image tag.

The release command only commits the kind image version file and pushes it to the local Git remote. It then waits for Argo CD to report the corresponding revision as Synced and Healthy.

The application is deployed by Argo CD. The script does not directly apply the application Deployment.

If you only modify the chart or configuration, commit the changes and run publish and verify.

The first up operation includes both build and release steps.

Automated release commits use the following Git identity:

Plain Text
GitOps Lab <gitops-lab@local*ost>

For your own source code commits, configure Git user.name and user.email.

PowerShell
#*Run a complete upgrade, drift reme*iation, and Git rollback test.
# T*e original image version is restor*d when the test finishes.
powershe*l -ExecutionPolicy Bypass -File .\*ab.ps1 test-gitops
 
# Roll back to*a previously built image tag.
powe*shell -ExecutionPolicy Bypass -Fil* .\lab.ps1 release PREVIOUS_TAG
``*
Directory Structure
Path	Purposeapps/	Frontend and backend source code and Dockerfiles
charts/example/	Shared Helm chart for kind and EKS
environments/kind/	Local topology and independent release configuration
environments/eks/	Cloud topology and independent release configuration
gitops/	Argo CD Project and Application definitions
infra/kind/	kind and Ingress configuration
scripts/	Installation, build, release, validation, and recovery scripts
.github/workflows/	Manifest validation, image builds, and release pull requests
.state/	Kubeconfig, passwords, Git remote, and cache files; not committed
docs/	Source mapping, GitHub, EKS, and recovery documentation
Argo CD
PowerShell
powershell*-ExecutionPolicy Bypass -File .\lab.ps1 ui
 
# Query the initial password from another terminal:
powershell -ExecutionPolicy Bypass -File .\lab.ps1 password

Open:

Plain Text
https://localhost:8443

Use the following username:

Plain Text
admin

The local environment uses a self-signed certificate.

Keep the terminal open while port forwarding is active. The script only displays the password when the password command is explicitly executed.

Rebuild
PowerShell
# Delete the entire windows-lab environment, including other namespaces
# and database data:
powershell -ExecutionPolicy Bypass -File .\lab.ps1 down --confirm
 
powershell -ExecutionPolicy Bypass -File .\lab.ps1 up

By default, the database contains temporary data.

The source code and YAML files are stored on the D: drive. Docker images, volumes, and the Ubuntu virtual disk remain managed by WSL.

Backups of the original files are stored in:

Plain Text
.state/legacy-backup

For details, see the docs/recovery.md.

The local Git and registry mode does not require a GitHub token. It validates real Git push and pull operations, container image builds, synchronization, and rollbacks.

Remote GitHub Actions and GHCR workflows must be validated after connecting the project to its final repository. See the docs/github.md.

EKS runs an independent Argo CD instance that reads from environments/eks in the same repository.

EKS, VPC, IAM, ALB, and RDS resources are managed by the infrastructure repository.

The docs/eks.md still needs to be aligned with the final repository URL.

The docs/provenance.md lists the source SHAs and adaptation points.

Translation notes
Technical command names such as build, release, publish, verify, and up were preserved as command identifiers.
Argo CD states such as Synced and Healthy were preserved exactly.
Paths, URLs, filenames, repository directories, and PowerShell commands were left unchanged.
Several sentences were slightly restructured to make the English read naturally while preserving the original technical meaning.# eks-gitops-validation
