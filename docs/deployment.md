# GCP Deployment Runbook

This document covers one-time setup and ongoing operations for the two-repo deployment:

| Repo | GitHub | Role |
|------|--------|------|
| App | `Shreyas-Yadav/mhcet` | Tests, builds Docker images, dispatches deploy |
| Infra | `Shreyas-Yadav/mhcet-infra` | Terraform, deploys to GCP |

## Architecture

- **Artifact Registry** — Docker image storage
- **Cloud Run** — backend (Spring Boot) + frontend (nginx)
- **Cloud SQL PostgreSQL 16** — one instance per environment
- **Secret Manager** — database passwords
- **HTTPS Load Balancer** — custom domain + managed SSL certs
- **Cloud Armor** — API rate limiting at the load balancer (default 100 req/min/IP; tune in `terraform/modules/load_balancer`)
- **Workload Identity Federation** — GitHub Actions → GCP (no JSON keys)

## 1. GCP project setup

1. Create a GCP project (e.g. `mhcet-app`) and link your billing account (credits apply at billing level).
2. Install [gcloud CLI](https://cloud.google.com/sdk/docs/install) and authenticate:

```bash
gcloud auth login
gcloud auth application-default login
gcloud config set project mhcet-app
```

3. Run bootstrap Terraform:

```bash
cd terraform/bootstrap
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your project_id and github_org

terraform init
terraform apply
```

Save the outputs — you need them for GitHub variables:

```bash
terraform output github_actions_vars
terraform output workload_identity_provider
```

## 2. DNS configuration

After the first `terraform apply` for each environment, note the load balancer IP:

```bash
cd terraform/environments/dev
terraform output load_balancer_ip
terraform output dns_records
```

Create **A records** at your domain registrar pointing both hostnames to the load balancer IP:

| Env | Hostname | Type | Value |
|-----|----------|------|-------|
| dev | `dev.yourdomain.com` | A | LB IP from dev output |
| dev | `api-dev.yourdomain.com` | A | same LB IP |
| prod | `yourdomain.com` or `app.yourdomain.com` | A | LB IP from prod output |
| prod | `api.yourdomain.com` | A | same LB IP |

Managed SSL certificates become `ACTIVE` after DNS propagates (can take up to 60 minutes).

Update `terraform/environments/dev/terraform.tfvars` and `prod/terraform.tfvars` with your real domains and `cors_allowed_origins`.

## 3. GitHub repository variables

### App repo (`mhcet`)

| Variable | Example |
|----------|---------|
| `GCP_PROJECT_ID` | `mhcet-app` |
| `GCP_REGION` | `asia-south1` |
| `GCP_WORKLOAD_IDENTITY_PROVIDER` | From bootstrap output |
| `GCP_APP_BUILD_SERVICE_ACCOUNT` | `github-app-build@mhcet-app.iam.gserviceaccount.com` |
| `ARTIFACT_REGISTRY` | `asia-south1-docker.pkg.dev/mhcet-app/mhcet` |
| `VITE_API_URL_DEV` | `https://api-dev.yourdomain.com` |
| `VITE_API_URL_PROD` | `https://api.yourdomain.com` |
| `CORS_ALLOWED_ORIGINS_DEV` | `https://dev.yourdomain.com` |
| `CORS_ALLOWED_ORIGINS_PROD` | `https://yourdomain.com` |
| `INFRA_REPO` | `Shreyas-Yadav/mhcet-infra` |

**Secret:**

| Secret | Purpose |
|--------|---------|
| `INFRA_REPO_DISPATCH_TOKEN` | GitHub PAT with `repo` scope to dispatch workflows in `mhcet-infra` |

Create a fine-grained PAT with **Actions: Read and write** on `mhcet-infra` only.

### Infra repo (`mhcet-infra`)

| Variable | Example |
|----------|---------|
| `GCP_PROJECT_ID` | `mhcet-app` |
| `GCP_REGION` | `asia-south1` |
| `GCP_WORKLOAD_IDENTITY_PROVIDER` | From bootstrap output |
| `GCP_INFRA_DEPLOY_SERVICE_ACCOUNT` | `github-infra-deploy@mhcet-app.iam.gserviceaccount.com` |
| `API_HEALTH_URL_DEV` | `https://api-dev.yourdomain.com/health` |
| `API_HEALTH_URL_PROD` | `https://api.yourdomain.com/health` |
| `PLAN_BACKEND_IMAGE` | `us-docker.pkg.dev/cloudrun/container/hello` |
| `PLAN_FRONTEND_IMAGE` | `us-docker.pkg.dev/cloudrun/container/hello` |
| `CURRENT_BACKEND_IMAGE_DEV` | Latest dev backend image URI (for infra-only deploys) |
| `CURRENT_FRONTEND_IMAGE_DEV` | Latest dev frontend image URI |
| `CURRENT_AI_IMAGE_DEV` | `asia-south1-docker.pkg.dev/mhcet-app-498018/mhcet/ai:dev-latest` |
| `AI_DOMAIN_DEV` | `ai-api-dev.shri.software` |
| `CURRENT_BACKEND_IMAGE_PROD` | Latest prod backend image URI (for infra-only deploys) |
| `CURRENT_FRONTEND_IMAGE_PROD` | Latest prod frontend image URI |
| `CURRENT_AI_IMAGE_PROD` | Latest prod AI image URI |
| `AI_DOMAIN_PROD` | `ai-api.shri.software` |

**GitHub Environments:**

- `dev` — auto-deploy on dispatch
- `production` — optional required reviewers before prod apply

## 4. Branch protection

Configure on **`main`** in both repos (Settings → Branches → Add rule):

- Require a pull request before merging
- Require status checks: `CI / backend-test`, `CI / frontend-check`, `Conventional Commits / commitlint` (app repo); `Terraform Plan / plan` (infra repo)
- Do not allow bypassing (recommended)
- Restrict direct pushes to `main`

### Using GitHub CLI

```bash
# App repo
gh api repos/Shreyas-Yadav/mhcet/branches/main/protection -X PUT \
  -f required_status_checks[strict]=true \
  -f required_status_checks[checks][][context]="CI / backend-test" \
  -f required_status_checks[checks][][context]="CI / frontend-check" \
  -f required_status_checks[checks][][context]="Conventional Commits / commitlint" \
  -f enforce_admins=true \
  -f required_pull_request_reviews[required_approving_review_count]=1 \
  -f restrictions=null

# Infra repo
gh api repos/Shreyas-Yadav/mhcet-infra/branches/main/protection -X PUT \
  -f required_status_checks[strict]=true \
  -f enforce_admins=true \
  -f required_pull_request_reviews[required_approving_review_count]=1 \
  -f restrictions=null
```

## 5. First deploy sequence

1. Apply dev infrastructure manually (first time only):

```bash
cd terraform/environments/dev
cp terraform.tfvars.example terraform.tfvars
# Edit domains and project_id

terraform init
terraform apply \
  -var="backend_image=us-docker.pkg.dev/cloudrun/container/hello" \
  -var="frontend_image=us-docker.pkg.dev/cloudrun/container/hello"
```

2. Configure DNS for dev hostnames.
3. Push app repo workflows; push to `dev` branch.
4. App CI runs tests → builds images → dispatches `deploy-dev` to infra repo.
5. Infra repo applies Terraform with real images.
6. Verify: `curl https://api-dev.yourdomain.com/health`
7. Repeat for prod after PR `dev` → `main` in infra repo, then PR `dev` → `main` in app repo.

## 6. Ongoing workflow

| Event | App repo | Infra repo |
|-------|----------|------------|
| PR → `dev` | CI tests | — |
| Push to `dev` | Build images + dispatch dev | Deploy dev |
| PR `dev` → `main` | CI tests | Plan (if TF changed) |
| PR merged → `main` (app) | Build prod images + dispatch | Deploy prod |
| PR merged → `main` (infra) | — | Apply prod TF changes |

## 7. Cloud SQL connection (backend)

The backend uses the Google Cloud SQL Socket Factory when `DB_URL` contains `socketFactory=com.google.cloud.sql.postgres.SocketFactory`.

Cloud Run sets:

```
DB_URL=jdbc:postgresql:///mhcet?cloudSqlInstance=PROJECT:REGION:INSTANCE&socketFactory=com.google.cloud.sql.postgres.SocketFactory
DB_USERNAME=mhcet
DB_PASSWORD=<from Secret Manager>
```

Local Docker Compose continues to use the standard JDBC URL (`jdbc:postgresql://db:5432/mhcet`).

## 8. Troubleshooting

| Issue | Fix |
|-------|-----|
| SSL cert stuck in PROVISIONING | Verify DNS A records point to LB IP |
| Cloud Run startup fails | Check logs: `gcloud run services logs read dev-mhcet-backend --region=asia-south1` |
| Dispatch fails | Verify `INFRA_REPO_DISPATCH_TOKEN` and `INFRA_REPO` variable |
| Testcontainers fails in CI | Docker is enabled in `ci.yml` via `services: docker` |
| Image built but deploy failed | Re-run infra `deploy-dev` workflow manually with image URIs |

## 9. Manual deploy fallback

In the infra repo, use **Actions → Deploy Dev / Deploy Prod → Run workflow** and pass the full image URIs from Artifact Registry.
