resource "google_artifact_registry_repository" "mhcet" {
  location      = var.region
  repository_id = var.repository_id
  description   = "Docker images for MHCET application"
  format        = "DOCKER"
}
