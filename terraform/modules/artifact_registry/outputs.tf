output "repository_url" {
  value = "${var.region}-docker.pkg.dev/${google_artifact_registry_repository.mhcet.project}/${google_artifact_registry_repository.mhcet.repository_id}"
}

output "repository_id" {
  value = google_artifact_registry_repository.mhcet.repository_id
}
