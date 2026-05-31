#!/usr/bin/env bash
# One-time GCP bootstrap for mhcet deployment.
# Prerequisites: gcloud auth login && gcloud auth application-default login
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BOOTSTRAP_DIR="${SCRIPT_DIR}/../terraform/bootstrap"

if ! command -v gcloud >/dev/null; then
  echo "Install gcloud: brew install --cask google-cloud-sdk"
  exit 1
fi

if [ ! -f "${BOOTSTRAP_DIR}/terraform.tfvars" ]; then
  cp "${BOOTSTRAP_DIR}/terraform.tfvars.example" "${BOOTSTRAP_DIR}/terraform.tfvars"
  echo "Created terraform.tfvars — edit project_id if needed, then re-run."
  exit 1
fi

PROJECT_ID="$(grep '^project_id' "${BOOTSTRAP_DIR}/terraform.tfvars" | cut -d= -f2 | tr -d ' "')"
gcloud config set project "${PROJECT_ID}"

cd "${BOOTSTRAP_DIR}"
terraform init
terraform apply

echo ""
echo "=== Set these GitHub variables (both repos) ==="
terraform output -json github_actions_vars | jq -r 'to_entries[] | "\(.key)=\(.value)"'
echo ""
echo "Run from repo root:"
echo "  gh variable set GCP_WORKLOAD_IDENTITY_PROVIDER --repo Shreyas-Yadav/mhcet --body \"\$(terraform -chdir=terraform/bootstrap output -raw workload_identity_provider)\""
echo "  gh variable set GCP_APP_BUILD_SERVICE_ACCOUNT --repo Shreyas-Yadav/mhcet --body \"\$(terraform -chdir=terraform/bootstrap output -json github_actions_vars | jq -r .GCP_APP_BUILD_SERVICE_ACCOUNT)\""
echo "  gh variable set GCP_WORKLOAD_IDENTITY_PROVIDER --repo Shreyas-Yadav/mhcet-infra --body \"\$(terraform -chdir=terraform/bootstrap output -raw workload_identity_provider)\""
echo "  gh variable set GCP_INFRA_DEPLOY_SERVICE_ACCOUNT --repo Shreyas-Yadav/mhcet-infra --body \"\$(terraform -chdir=terraform/bootstrap output -json github_actions_vars | jq -r .GCP_INFRA_DEPLOY_SERVICE_ACCOUNT)\""
