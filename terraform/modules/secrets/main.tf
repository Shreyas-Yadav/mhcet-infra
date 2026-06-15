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

# Google OAuth client secret (whole-app login gate). Value is supplied out-of-band; the
# secret container is always created so Cloud Run can reference it, but a version is only
# written when a value is provided (mirrors google_api_key).
resource "google_secret_manager_secret" "google_oauth_client_secret" {
  secret_id = "${var.environment}-google-oauth-client-secret"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "google_oauth_client_secret" {
  count       = var.google_oauth_client_secret != "" ? 1 : 0
  secret      = google_secret_manager_secret.google_oauth_client_secret.id
  secret_data = var.google_oauth_client_secret
}

# Shared service-to-service key: the backend trusts AI tool calls bearing this (X-Service-Key),
# and both services receive it from the same secret. Auto-generated so it needs no manual entry.
resource "random_password" "service_api_key" {
  length  = 48
  special = false
}

resource "google_secret_manager_secret" "service_api_key" {
  secret_id = "${var.environment}-service-api-key"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "service_api_key" {
  secret      = google_secret_manager_secret.service_api_key.id
  secret_data = random_password.service_api_key.result
}
