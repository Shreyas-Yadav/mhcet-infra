output "load_balancer_ip" {
  value = google_compute_global_address.lb_ip.address
}

output "dns_records" {
  value = {
    frontend = {
      type  = "A"
      name  = var.frontend_domain
      value = google_compute_global_address.lb_ip.address
    }
    backend = {
      type  = "A"
      name  = var.backend_domain
      value = google_compute_global_address.lb_ip.address
    }
    ai = {
      type  = "A"
      name  = var.ai_domain
      value = google_compute_global_address.lb_ip.address
    }
  }
}
