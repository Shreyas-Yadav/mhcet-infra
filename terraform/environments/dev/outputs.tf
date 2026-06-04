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
  value = module.artifact_registry.repository_url
}

output "cloud_run_backend_uri" {
  value = module.cloud_run.backend_uri
}

output "cloud_run_frontend_uri" {
  value = module.cloud_run.frontend_uri
}

output "stress_test_job_name" {
  value = var.stress_test_enabled ? module.stress_test[0].job_name : null
}

output "stress_test_total_requests" {
  value = var.stress_test_enabled ? module.stress_test[0].total_requests : null
}

output "stress_test_execute_command" {
  value = var.stress_test_enabled ? module.stress_test[0].execute_command : null
}
