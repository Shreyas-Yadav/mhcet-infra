output "db_password_secret_id" {
  value = google_secret_manager_secret.db_password.secret_id
}

output "db_password" {
  value     = random_password.db_password.result
  sensitive = true
}

output "google_api_key_secret_id" {
  value = google_secret_manager_secret.google_api_key.secret_id
}

output "google_oauth_client_secret_secret_id" {
  value = google_secret_manager_secret.google_oauth_client_secret.secret_id
}

output "service_api_key_secret_id" {
  value = google_secret_manager_secret.service_api_key.secret_id
}
