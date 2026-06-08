resource "random_password" "db_password" {
  length  = 32
  special = false
}

resource "google_secret_manager_secret" "db_password" {
  secret_id = "${var.environment}-db-password"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "db_password" {
  secret      = google_secret_manager_secret.db_password.id
  secret_data = random_password.db_password.result
}

resource "google_secret_manager_secret" "google_api_key" {
  secret_id = "${var.environment}-google-api-key"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "google_api_key" {
  count       = var.google_api_key != "" ? 1 : 0
  secret      = google_secret_manager_secret.google_api_key.id
  secret_data = var.google_api_key
}
