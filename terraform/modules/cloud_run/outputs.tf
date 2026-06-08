output "backend_service_name" {
  value = google_cloud_run_v2_service.backend.name
}

output "frontend_service_name" {
  value = google_cloud_run_v2_service.frontend.name
}

output "backend_uri" {
  value = google_cloud_run_v2_service.backend.uri
}

output "frontend_uri" {
  value = google_cloud_run_v2_service.frontend.uri
}

output "cloud_run_service_account_email" {
  value = google_service_account.cloud_run.email
}

output "ai_service_name" {
  value = google_cloud_run_v2_service.ai.name
}

output "ai_uri" {
  value = google_cloud_run_v2_service.ai.uri
}
