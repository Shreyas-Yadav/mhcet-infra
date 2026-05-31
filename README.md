# mhcet-infra

Terraform and GitHub Actions workflows for deploying the [mhcet](https://github.com/Shreyas-Yadav/mhcet) application to GCP.

## Layout

```
terraform/
  bootstrap/          # One-time GCP setup (state bucket, WIF, service accounts)
  modules/            # Reusable modules
  environments/
    dev/              # Dev stack
    prod/             # Prod stack
.github/workflows/    # plan, deploy-dev, deploy-prod
docs/deployment.md    # Full runbook
```

## Quick start

1. Copy `terraform/bootstrap/terraform.tfvars.example` to `terraform.tfvars` and fill in your GCP project ID.
2. Run bootstrap (see [docs/deployment.md](docs/deployment.md)).
3. Copy environment tfvars examples and configure domains.
4. Configure GitHub repository variables and environments.
5. Push to `dev` in the app repo to trigger the first dev deploy.

## Branching

| Branch | Purpose |
|--------|---------|
| `dev` | Dev infrastructure changes; Terraform plan on PR |
| `main` | Prod infrastructure; changes only via PR from `dev` |

App deployments are triggered by `repository_dispatch` events from the `mhcet` app repo.
