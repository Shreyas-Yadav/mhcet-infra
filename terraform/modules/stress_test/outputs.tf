output "job_name" {
  value = google_cloud_run_v2_job.stress_test.name
}

output "job_id" {
  value = google_cloud_run_v2_job.stress_test.id
}

output "total_requests" {
  value = var.task_count * var.requests_per_task
}

output "execute_command" {
  value = "gcloud run jobs execute ${google_cloud_run_v2_job.stress_test.name} --project ${var.project_id} --region ${var.region}"
}

output "service_account_email" {
  value = google_service_account.stress_test.email
}
