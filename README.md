# mhcet-infra

Terraform and GitHub Actions for deploying [mhcet](https://github.com/Shreyas-Yadav/mhcet) to GCP.

## Pipeline architecture

| Workflow | Trigger | What it does |
|----------|---------|--------------|
| `plan.yml` | PR to `dev`/`main` | Terraform plan (infra changes only) |
| `deploy-app-dev.yml` | `repository_dispatch` from app repo | `gcloud run update` with SHA image tags |
| `deploy-app-prod.yml` | `repository_dispatch` on prod merge | Cloud Run prod deploy (requires `production` approval) |
| `deploy-infra-dev.yml` | Push to `dev` (terraform/**) | Plan + apply infra (`dev-infra` environment) |
| `build-stress-test-dev.yml` | Push to `dev` (stress-test/**) or manual | Build `stress-test` Docker image to Artifact Registry |
| `execute-stress-test-dev.yml` | Manual | Run `dev-mhcet-stress-test` Cloud Run Job |
| `deploy-infra-prod.yml` | PR merge to `main` (terraform/**) | Plan + apply prod infra (`production-infra` approval) |

**App deploys** update Cloud Run images only. **Infra deploys** run Terraform for Cloud SQL, LB, secrets, monitoring, etc. Terraform ignores container image tags after initial create.

## Layout

```
terraform/
  bootstrap/       # WIF, state bucket, least-privilege IAM
  modules/         # artifact_registry, cloud_sql, cloud_run, load_balancer, secrets, monitoring, stress_test
  environments/
    dev/
    prod/
.github/workflows/
docs/
  deployment.md
  github-app-setup.md
scripts/
  bootstrap-gcp.sh
  migrate-local-db-to-cloudsql.sh
  setup-branch-protection.sh
  sync-github-vars.sh
```

## Quick start

See [docs/deployment.md](docs/deployment.md). Dev load testing: [docs/stress-test.md](docs/stress-test.md).

## Security notes

- GCP auth via Workload Identity Federation (no JSON keys)
- Infra deploy SA uses scoped roles (not `roles/editor`)
- API rate limiting via Cloud Armor on the load balancer (not in the Spring Boot app)
- Cross-repo dispatch: prefer GitHub App ([docs/github-app-setup.md](docs/github-app-setup.md)) over PAT
