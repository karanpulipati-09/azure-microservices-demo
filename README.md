## azure-microservices-demo

Azure infrastructure portfolio project built by **[Karan Pulipati](https://www.linkedin.com/in/karan-pulipati)**.
Demonstrates Terraform, AKS, Helm, and GitOps-based CI/CD from code push to live deployment — the Azure counterpart to [aws-microservices-demo](https://github.com/karanpulipati-09/aws-microservices-demo), aligned on the same image build → push → deploy pattern.

## Architecture

```
GitHub (main branch)
    │
    │ apps/** push
    ▼
CI — Build and Push  ──────────────────────────┐
  build frontend + api (matrix)                │
  trivy scan                                    │
  az acr login (OIDC) → push to ACR            │
    │ tagged with short git SHA                 │
    ▼                                            │
CD — Update Image Tag                           │
  bumps helm/*/values.yaml                       │
  commits back to main  ─────────────────────────┘
    │
    ▼
ArgoCD (in-cluster, installed via Terraform)
  watches main branch — auto-sync + self-heal
    │
    ▼
AKS Cluster (1 node pool, Standard_D2s_v7, Azure CNI)
    ├── frontend pod  ← nginx-unprivileged (ACR image, ClusterIP :80→8080)
    │     └── proxies /api/* to the api service
    └── api pod       ← Node.js REST API (ACR image, ClusterIP :8080)

ACR (Azure Container Registry)
    ├── frontend  ← nginx-unprivileged:alpine image
    └── api       ← node:20-alpine image

No public ingress — both services are ClusterIP only, accessed via
`kubectl port-forward` (see DEPLOYMENT_STEPS.md).
```

## Infrastructure

| Resource | Purpose |
|---|---|
| Resource Group (`rg-aks-staging`) | Contains all app infra — freely destroyable |
| AKS Cluster | Single node pool (3x `Standard_D2s_v7`), Azure CNI, OIDC issuer enabled |
| ACR | Private container registry — `frontend` + `api` repos, admin user disabled (OIDC/RBAC-only access) |
| Log Analytics Workspace | Backing store for AKS diagnostics |
| ArgoCD (`helm_release`) | Installed via Terraform into the `argocd` namespace — GitOps controller |
| Terraform remote state | Separate resource group (`rg-terraform-state`) + Storage Account, bootstrapped once via CLI, outside Terraform's own management — survives every `terraform destroy` |

## Security

- No long-lived Azure credentials in GitHub — **OIDC** federated identity (`github-actions-aks` app registration) for both Terraform and image pushes
- ACR has `admin_enabled = false` — pushes authenticate via `az acr login` under the OIDC identity, not shared registry credentials
- Least-privilege RBAC on the GitHub Actions identity: `Contributor` (subscription), `User Access Administrator` (subscription, scoped by condition to exclude Owner/UAA/RBAC Administrator — needed only so Terraform can create the AKS→ACR `AcrPull` role assignment), `AcrPush` (scoped to the registry only)
- `frontend`/`api` namespaces enforce the **`restricted`** Pod Security Standard — containers must run non-root, drop all Linux capabilities, and disable privilege escalation
- Default-deny `NetworkPolicy` in the `api` namespace, with an explicit allow rule for `frontend` → `api` traffic only
- Trivy scans every image (CRITICAL/HIGH) on every CI build
- Dedicated `frontend-sa` / `api-sa` service accounts per app, `automountServiceAccountToken: false`

## Kubernetes + Helm

Charts in `helm/`:

| Chart | Service | Container Port | Base Image |
|---|---|---|---|
| `helm/frontend` | ClusterIP :80 → 8080 | 8080 | `nginxinc/nginx-unprivileged:alpine` (non-root by default) |
| `helm/api` | ClusterIP :8080 | 8080 | `node:20-alpine`, `USER 1000` |

No HPA/autoscaling or ingress controller in this demo — fixed replica counts, `kubectl port-forward` for local access.

**GitOps bootstrap** (one-time per fresh cluster — see `DEPLOYMENT_STEPS.md` Step 9 for full detail):
```bash
kubectl apply -f k8s/namespaces-podsecurity.yaml
kubectl apply -f k8s/serviceaccounts-rbac.yaml
kubectl apply -f k8s/networkpolicy-default-deny.yaml
kubectl apply -n argocd -f argocd/frontend.yaml
kubectl apply -n argocd -f argocd/api.yaml
```
After that, ArgoCD handles every deploy automatically — no more manual `helm install`/`helm upgrade`.

## Applications

| App | Source | ACR Repo | Port |
|---|---|---|---|
| frontend | `apps/frontend/` | `frontend` | 8080 (proxies `/api/*` to the api service) |
| api | `apps/api/` | `api` | 8080 |

The API exposes `/health` (and `/api/health`) → `{ status: "ok", env: "staging", version: "1.0.0", sha: <image-tag>, deployedBy: "ArgoCD" }`.

Images are tagged with the short git SHA (7 chars). No `latest` tag.

## CI/CD

| Workflow | Trigger | What it does |
|---|---|---|
| `build-push.yml` (CI) | Push to `main` — `apps/**`, or manual | Builds frontend + api in parallel, Trivy scan, OIDC push to ACR |
| `deploy.yml` (CD) | `workflow_run` on CI success, or manual | Bumps `image.tag` in `helm/*/values.yaml`, commits back to `main` — ArgoCD picks it up |
| `terraform-plan.yml` | Pull request to `main` — `terraform/**` | Runs `terraform plan` |
| `terraform-apply.yml` | Push to `main` — `terraform/**`, or manual | Runs `terraform apply` automatically |
| `terraform-destroy.yml` | Manual (`workflow_dispatch`) | Destroys all app infra — used between sessions to avoid idle cost |

**Authentication**: OIDC throughout — no Azure client secrets or ACR admin credentials stored in GitHub.

## Getting started

See **[DEPLOYMENT_STEPS.md](DEPLOYMENT_STEPS.md)** for the full walkthrough — OIDC app registration, IAM roles, Terraform apply, GitOps bootstrap, and troubleshooting. `docs/` has quick-reference notes on the AWS↔Azure resource mapping.
