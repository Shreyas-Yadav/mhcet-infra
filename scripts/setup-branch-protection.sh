#!/usr/bin/env bash
# Configure branch protection and GitHub environments for both repos.
set -euo pipefail

GITHUB_ORG="${GITHUB_ORG:-Shreyas-Yadav}"
APP_REPO="${APP_REPO:-mhcet}"
INFRA_REPO="${INFRA_REPO:-mhcet-infra}"

create_environment() {
  local repo=$1
  local env=$2
  gh api "repos/${GITHUB_ORG}/${repo}/environments/${env}" -X PUT --input - <<EOF
{"wait_timer": 0}
EOF
  echo "Environment ${env} on ${repo}"
}

create_production_environment() {
  local repo=$1
  local env=$2
  gh api "repos/${GITHUB_ORG}/${repo}/environments/${env}" -X PUT --input - <<EOF
{
  "wait_timer": 0,
  "reviewers": [{"type": "User", "id": $(gh api user --jq .id)}]
}
EOF
  echo "Environment ${env} on ${repo} (with reviewer)"
}

protect_branch() {
  local repo=$1
  shift
  local checks_json=$1
  gh api "repos/${GITHUB_ORG}/${repo}/branches/main/protection" -X PUT --input - <<EOF
{
  "required_status_checks": {
    "strict": true,
    "checks": ${checks_json}
  },
  "enforce_admins": true,
  "required_pull_request_reviews": {
    "required_approving_review_count": 1
  },
  "restrictions": null
}
EOF
  echo "Protected ${repo}/main"
}

# Infra repo environments
create_environment "${INFRA_REPO}" "dev"
create_environment "${INFRA_REPO}" "dev-infra"
create_production_environment "${INFRA_REPO}" "production"
create_production_environment "${INFRA_REPO}" "production-infra"

# App repo environments (when using production deploy)
create_environment "${APP_REPO}" "dev" 2>/dev/null || true

if gh api "repos/${GITHUB_ORG}/${APP_REPO}/branches/main" >/dev/null 2>&1; then
  protect_branch "${APP_REPO}" '[{"context":"CI / backend-test"},{"context":"CI / frontend-check"},{"context":"Conventional Commits / commitlint"}]'
else
  echo "Skip ${APP_REPO}/main — branch does not exist yet. Create main from dev first."
fi

if gh api "repos/${GITHUB_ORG}/${INFRA_REPO}/branches/main" >/dev/null 2>&1; then
  protect_branch "${INFRA_REPO}" '[{"context":"Terraform Plan / plan"}]'
fi

echo "Done."
