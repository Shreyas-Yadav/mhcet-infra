#!/usr/bin/env bash
# Push WIF outputs from bootstrap Terraform into GitHub repo variables.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BOOTSTRAP_DIR="${SCRIPT_DIR}/../terraform/bootstrap"
APP_REPO="${APP_REPO:-Shreyas-Yadav/mhcet}"
INFRA_REPO="${INFRA_REPO:-Shreyas-Yadav/mhcet-infra}"

cd "${BOOTSTRAP_DIR}"

WIF_PROVIDER="$(terraform output -raw workload_identity_provider)"
APP_SA="$(terraform output -json github_actions_vars | jq -r .GCP_APP_BUILD_SERVICE_ACCOUNT)"
INFRA_SA="$(terraform output -json github_actions_vars | jq -r .GCP_INFRA_DEPLOY_SERVICE_ACCOUNT)"

gh variable set GCP_WORKLOAD_IDENTITY_PROVIDER --repo "${APP_REPO}" --body "${WIF_PROVIDER}"
gh variable set GCP_APP_BUILD_SERVICE_ACCOUNT --repo "${APP_REPO}" --body "${APP_SA}"
gh variable set GCP_WORKLOAD_IDENTITY_PROVIDER --repo "${INFRA_REPO}" --body "${WIF_PROVIDER}"
gh variable set GCP_INFRA_DEPLOY_SERVICE_ACCOUNT --repo "${INFRA_REPO}" --body "${INFRA_SA}"

echo "GitHub WIF variables updated for ${APP_REPO} and ${INFRA_REPO}."
