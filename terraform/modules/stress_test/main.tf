resource "google_service_account" "stress_test" {
  account_id   = "${var.environment}-stress-test"
  display_name = "Cloud Run stress test job (${var.environment})"
  project      = var.project_id
}

resource "google_cloud_run_v2_job" "stress_test" {
  name     = "${var.environment}-mhcet-stress-test"
  location = var.region
  project  = var.project_id

  template {
    task_count  = var.task_count
    parallelism = var.parallelism

    template {
      service_account = google_service_account.stress_test.email
      timeout         = "${var.task_timeout_seconds}s"
      max_retries     = 0

      containers {
        name  = "stress"
        image = var.image

        env {
          name  = "COUNT"
          value = tostring(var.requests_per_task)
        }

        env {
          name  = "CONCURRENCY"
          value = tostring(var.concurrency)
        }

        env {
          name  = "API_URL"
          value = var.api_url
        }

        resources {
          limits = {
            cpu    = "1"
            memory = "512Mi"
          }
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [
      client,
      client_version,
      template[0].template[0].containers[0].image,
    ]
  }
}

resource "google_cloud_run_v2_job_iam_member" "runner" {
  for_each = toset(var.runner_members)

  project  = var.project_id
  location = var.region
  name     = google_cloud_run_v2_job.stress_test.name
  role     = "roles/run.jobsExecutor"
  member   = each.value
}
