output "state_bucket_name" {
  value = google_storage_bucket.tf_state.name
}

output "app_build_service_account_email" {
  value = google_service_account.app_build.email
}

output "infra_deploy_service_account_email" {
  value = google_service_account.infra_deploy.email
}

output "workload_identity_provider" {
  description = "Use this value as GCP_WORKLOAD_IDENTITY_PROVIDER in GitHub Actions"
  value       = google_iam_workload_identity_pool_provider.github.name
}

output "github_actions_vars" {
  description = "Set these as GitHub repository variables"
  value = {
    GCP_PROJECT_ID                   = var.project_id
    GCP_REGION                       = var.region
    GCP_WORKLOAD_IDENTITY_PROVIDER   = google_iam_workload_identity_pool_provider.github.name
    GCP_APP_BUILD_SERVICE_ACCOUNT    = google_service_account.app_build.email
    GCP_INFRA_DEPLOY_SERVICE_ACCOUNT = google_service_account.infra_deploy.email
    ARTIFACT_REGISTRY                = "${var.region}-docker.pkg.dev/${var.project_id}/mhcet"
  }
}
