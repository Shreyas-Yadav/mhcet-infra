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
    bucket = "mhcet-tf-state"
    prefix = "prod"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

data "google_artifact_registry_repository" "mhcet" {
  location      = var.region
  repository_id = "mhcet"
}

module "secrets" {
  source = "../../modules/secrets"

  environment = var.environment
}

module "cloud_sql" {
  source = "../../modules/cloud_sql"

  environment                    = var.environment
  region                         = var.region
  tier                           = var.db_tier
  availability_type              = "ZONAL"
  point_in_time_recovery_enabled = true
  deletion_protection            = true
  database_password              = module.secrets.db_password
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
  backend_max_instances     = var.backend_max_instances
  frontend_max_instances    = var.frontend_max_instances

  depends_on = [module.cloud_sql, module.secrets]
}

module "load_balancer" {
  source = "../../modules/load_balancer"

  environment           = var.environment
  region                = var.region
  frontend_domain       = var.frontend_domain
  backend_domain        = var.backend_domain
  frontend_service_name = module.cloud_run.frontend_service_name
  backend_service_name  = module.cloud_run.backend_service_name

  depends_on = [module.cloud_run]
}
