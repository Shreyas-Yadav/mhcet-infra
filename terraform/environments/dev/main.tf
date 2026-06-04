terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  backend "gcs" {
    bucket = "mhcet-tf-state-498018"
    prefix = "dev"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

module "artifact_registry" {
  source = "../../modules/artifact_registry"

  region        = var.region
  repository_id = "mhcet"
}

module "secrets" {
  source = "../../modules/secrets"

  environment = var.environment
}

module "cloud_sql" {
  source = "../../modules/cloud_sql"

  environment         = var.environment
  region              = var.region
  tier                = var.db_tier
  deletion_protection = false
  database_password   = module.secrets.db_password
}

module "cloud_run" {
  source = "../../modules/cloud_run"

  project_id                = var.project_id
  environment               = var.environment
  region                    = var.region
  backend_image             = var.backend_image
  frontend_image            = var.frontend_image
  cloud_sql_connection_name = module.cloud_sql.connection_name
  database_name             = module.cloud_sql.database_name
  database_user             = module.cloud_sql.database_user
  db_password_secret_id     = module.secrets.db_password_secret_id
  cors_allowed_origins      = var.cors_allowed_origins
  backend_min_instances     = var.backend_min_instances
  frontend_min_instances    = var.frontend_min_instances

  depends_on = [module.cloud_sql, module.secrets]
}

module "load_balancer" {
  source = "../../modules/load_balancer"

  environment                      = var.environment
  region                           = var.region
  frontend_domain                  = var.frontend_domain
  backend_domain                   = var.backend_domain
  frontend_service_name            = module.cloud_run.frontend_service_name
  backend_service_name             = module.cloud_run.backend_service_name
  rate_limit_requests_per_minute   = var.rate_limit_requests_per_minute

  depends_on = [module.cloud_run]
}

module "stress_test" {
  count  = var.stress_test_enabled ? 1 : 0
  source = "../../modules/stress_test"

  project_id          = var.project_id
  environment         = var.environment
  region              = var.region
  image               = "${module.artifact_registry.repository_url}/stress-test:${var.stress_test_image_tag}"
  api_url             = "https://${var.backend_domain}${var.stress_test_api_path}"
  task_count          = var.stress_test_task_count
  parallelism         = var.stress_test_parallelism
  requests_per_task   = var.stress_test_requests_per_task
  concurrency         = var.stress_test_concurrency
  runner_members      = var.stress_test_runner_members

  depends_on = [module.artifact_registry]
}

module "monitoring" {
  source = "../../modules/monitoring"

  project_id         = var.project_id
  environment        = var.environment
  backend_health_url = var.backend_health_url
  alert_email        = var.alert_email
}
