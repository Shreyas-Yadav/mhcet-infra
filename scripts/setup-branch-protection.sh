#!/usr/bin/env bash
# Configure branch protection on main for both mhcet and mhcet-infra repos.
# Requires: gh CLI authenticated with admin access.
set -euo pipefail

GITHUB_ORG="${GITHUB_ORG:-Shreyas-Yadav}"
APP_REPO="${APP_REPO:-mhcet}"
INFRA_REPO="${INFRA_REPO:-mhcet-infra}"

protect_app_repo() {
  gh api "repos/${GITHUB_ORG}/${APP_REPO}/branches/main/protection" -X PUT \
    --input - <<EOF
{
  "required_status_checks": {
    "strict": true,
    "checks": [
      {"context": "CI / backend-test"},
      {"context": "CI / frontend-check"},
      {"context": "Conventional Commits / commitlint"}
    ]
  },
  "enforce_admins": true,
  "required_pull_request_reviews": {
    "required_approving_review_count": 1
  },
  "restrictions": null
}
EOF
  echo "Protected ${APP_REPO}/main"
}

protect_infra_repo() {
  gh api "repos/${GITHUB_ORG}/${INFRA_REPO}/branches/main/protection" -X PUT \
    --input - <<EOF
{
  "required_status_checks": {
    "strict": true,
    "checks": [
      {"context": "Terraform Plan / plan"}
    ]
  },
  "enforce_admins": true,
  "required_pull_request_reviews": {
    "required_approving_review_count": 1
  },
  "restrictions": null
}
EOF
  echo "Protected ${INFRA_REPO}/main"
}

protect_app_repo
protect_infra_repo

echo "Done. Verify in GitHub Settings → Branches."
