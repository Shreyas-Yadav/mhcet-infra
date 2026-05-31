terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

locals {
  apis = [
    "run.googleapis.com",
    "sqladmin.googleapis.com",
    "artifactregistry.googleapis.com",
    "secretmanager.googleapis.com",
    "compute.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "servicenetworking.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "sts.googleapis.com",
  ]
}

resource "google_project_service" "apis" {
  for_each = toset(local.apis)

  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}

resource "google_storage_bucket" "tf_state" {
  name                        = var.state_bucket_name
  location                    = var.region
  force_destroy               = false
  uniform_bucket_level_access = true
  versioning {
    enabled = true
  }

  depends_on = [google_project_service.apis]
}

resource "google_service_account" "app_build" {
  account_id   = "github-app-build"
  display_name = "GitHub Actions - mhcet app build"
}

resource "google_service_account" "infra_deploy" {
  account_id   = "github-infra-deploy"
  display_name = "GitHub Actions - mhcet-infra deploy"
}

resource "google_project_iam_member" "app_build_artifact_writer" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.app_build.email}"
}

resource "google_project_iam_member" "infra_deploy_run_admin" {
  project = var.project_id
  role    = "roles/run.admin"
  member  = "serviceAccount:${google_service_account.infra_deploy.email}"
}

resource "google_project_iam_member" "infra_deploy_sa_user" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.infra_deploy.email}"
}

resource "google_project_iam_member" "infra_deploy_secret_accessor" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.infra_deploy.email}"
}

resource "google_project_iam_member" "infra_deploy_artifact_reader" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.infra_deploy.email}"
}

resource "google_storage_bucket_iam_member" "infra_deploy_state" {
  bucket = google_storage_bucket.tf_state.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.infra_deploy.email}"
}

resource "google_iam_workload_identity_pool" "github" {
  workload_identity_pool_id = var.wif_pool_id
  display_name              = "GitHub Actions"
  description               = "OIDC pool for GitHub Actions"

  depends_on = [google_project_service.apis]
}

resource "google_iam_workload_identity_pool_provider" "github" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = var.wif_provider_id
  display_name                       = "GitHub"
  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
  }
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

resource "google_service_account_iam_member" "app_build_wif" {
  service_account_id = google_service_account.app_build.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository/${var.github_org}/${var.app_repo}"
}

resource "google_service_account_iam_member" "infra_deploy_wif" {
  service_account_id = google_service_account.infra_deploy.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository/${var.github_org}/${var.infra_repo}"
}

# Infra deploy SA needs additional roles applied via environment stacks
resource "google_project_iam_member" "infra_deploy_editor" {
  project = var.project_id
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.infra_deploy.email}"
}
