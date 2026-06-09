resource "google_service_account" "cloud_run" {
  account_id   = "${var.environment}-cloud-run"
  display_name = "Cloud Run runtime - ${var.environment}"
}

resource "google_cloud_run_v2_service" "backend" {
  name     = "${var.environment}-mhcet-backend"
  location = var.region
  ingress  = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"

  template {
    service_account = google_service_account.cloud_run.email

    scaling {
      min_instance_count = var.backend_min_instances
      max_instance_count = var.backend_max_instances
    }

    volumes {
      name = "cloudsql"
      cloud_sql_instance {
        instances = [var.cloud_sql_connection_name]
      }
    }

    containers {
      name  = "backend"
      image = var.backend_image

      ports {
        container_port = 8080
      }

      env {
        name  = "DB_USERNAME"
        value = var.database_user
      }

      env {
        name = "DB_PASSWORD"
        value_source {
          secret_key_ref {
            secret  = var.db_password_secret_id
            version = "latest"
          }
        }
      }

      env {
        name  = "DB_URL"
        value = "jdbc:postgresql:///${var.database_name}?cloudSqlInstance=${var.cloud_sql_connection_name}&socketFactory=com.google.cloud.sql.postgres.SocketFactory"
      }

      env {
        name  = "CORS_ALLOWED_ORIGINS"
        value = var.cors_allowed_origins
      }

      env {
        name  = "INGEST_ENABLED"
        value = "false"
      }

      env {
        name  = "AI_SERVICE_URL"
        value = "https://${var.ai_domain}"
      }

      volume_mounts {
        name       = "cloudsql"
        mount_path = "/cloudsql"
      }

      resources {
        limits = {
          cpu    = "1"
          memory = var.backend_memory
        }
      }

      startup_probe {
        http_get {
          path = "/health"
          port = 8080
        }
        initial_delay_seconds = 10
        timeout_seconds       = 3
        period_seconds        = 10
        failure_threshold     = 6
      }

      liveness_probe {
        http_get {
          path = "/health"
          port = 8080
        }
        period_seconds = 30
      }
    }
  }

  lifecycle {
    ignore_changes = [
      client,
      client_version,
      template[0].containers[0].image,
    ]
  }
}

resource "google_cloud_run_v2_service" "frontend" {
  name     = "${var.environment}-mhcet-frontend"
  location = var.region
  ingress  = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"

  template {
    service_account = google_service_account.cloud_run.email

    scaling {
      min_instance_count = var.frontend_min_instances
      max_instance_count = var.frontend_max_instances
    }

    containers {
      name  = "frontend"
      image = var.frontend_image

      ports {
        container_port = 80
      }

      resources {
        limits = {
          cpu    = "1"
          memory = var.frontend_memory
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [
      client,
      client_version,
      template[0].containers[0].image,
    ]
  }
}

resource "google_cloud_run_v2_service_iam_member" "backend_public" {
  name     = google_cloud_run_v2_service.backend.name
  location = var.region
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_cloud_run_v2_service_iam_member" "frontend_public" {
  name     = google_cloud_run_v2_service.frontend.name
  location = var.region
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_project_iam_member" "cloud_run_sql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.cloud_run.email}"
}

resource "google_secret_manager_secret_iam_member" "cloud_run_db_password" {
  secret_id = var.db_password_secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.cloud_run.email}"
}

# AI service — separate service account (no DB access needed)
resource "google_service_account" "ai_run" {
  account_id   = "${var.environment}-ai-run"
  display_name = "Cloud Run AI runtime - ${var.environment}"
}

resource "google_cloud_run_v2_service" "ai" {
  name     = "${var.environment}-mhcet-ai"
  location = var.region
  ingress  = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"

  template {
    service_account = google_service_account.ai_run.email

    scaling {
      min_instance_count = var.ai_min_instances
      max_instance_count = var.ai_max_instances
    }

    containers {
      name  = "ai"
      image = var.ai_image

      ports {
        container_port = 8081
      }

      env {
        name = "GOOGLE_API_KEY"
        value_source {
          secret_key_ref {
            secret  = var.google_api_key_secret_id
            version = "latest"
          }
        }
      }

      env {
        name  = "GOOGLE_GENAI_USE_VERTEXAI"
        value = "FALSE"
      }

      # The AI service's function tools call the backend API (get_predictions,
      # get_college_cutoffs, etc.). On Cloud Run it reaches the backend via the
      # public LB domain; without this it falls back to localhost and tool calls fail.
      env {
        name  = "BACKEND_URL"
        value = "https://${var.backend_domain}"
      }

      resources {
        limits = {
          cpu    = "1"
          memory = "1Gi"
        }
      }

      startup_probe {
        http_get {
          path = "/health"
          port = 8081
        }
        initial_delay_seconds = 10
        timeout_seconds       = 3
        period_seconds        = 10
        failure_threshold     = 6
      }

      liveness_probe {
        http_get {
          path = "/health"
          port = 8081
        }
        period_seconds = 30
      }
    }
  }

  lifecycle {
    ignore_changes = [
      client,
      client_version,
      template[0].containers[0].image,
    ]
  }
}

resource "google_cloud_run_v2_service_iam_member" "ai_public" {
  name     = google_cloud_run_v2_service.ai.name
  location = var.region
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_secret_manager_secret_iam_member" "ai_run_google_api_key" {
  secret_id = var.google_api_key_secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.ai_run.email}"
}
