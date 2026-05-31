output "load_balancer_ip" {
  value = module.load_balancer.load_balancer_ip
}

output "dns_records" {
  value = module.load_balancer.dns_records
}

output "backend_url" {
  value = "https://${var.backend_domain}"
}

output "frontend_url" {
  value = "https://${var.frontend_domain}"
}

output "artifact_registry_url" {
  value = "${var.region}-docker.pkg.dev/${var.project_id}/${data.google_artifact_registry_repository.mhcet.repository_id}"
}

output "cloud_run_backend_uri" {
  value = module.cloud_run.backend_uri
}

output "cloud_run_frontend_uri" {
  value = module.cloud_run.frontend_uri
}
