resource "google_compute_security_policy" "backend" {
  name = "${var.environment}-mhcet-backend-armor"

  rule {
    action      = "throttle"
    priority    = 1000
    description = "Rate limit API traffic by client IP"

    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }

    rate_limit_options {
      conform_action = "allow"
      exceed_action  = "deny(429)"
      enforce_on_key = "IP"

      rate_limit_threshold {
        count        = var.rate_limit_requests_per_minute
        interval_sec = 60
      }
    }
  }

  rule {
    action      = "allow"
    priority    = 2147483647
    description = "Default allow"

    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
  }
}

resource "google_compute_global_address" "lb_ip" {
  name = "${var.environment}-mhcet-lb-ip"
}

resource "google_compute_managed_ssl_certificate" "main" {
  name = "${var.environment}-mhcet-cert"

  managed {
    domains = [var.frontend_domain, var.backend_domain]
  }
}

resource "google_compute_region_network_endpoint_group" "frontend" {
  name                  = "${var.environment}-frontend-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.region

  cloud_run {
    service = var.frontend_service_name
  }
}

resource "google_compute_region_network_endpoint_group" "backend" {
  name                  = "${var.environment}-backend-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.region

  cloud_run {
    service = var.backend_service_name
  }
}

resource "google_compute_backend_service" "frontend" {
  name                  = "${var.environment}-frontend-backend"
  protocol              = "HTTP"
  port_name             = "http"
  timeout_sec           = 30
  load_balancing_scheme = "EXTERNAL_MANAGED"

  backend {
    group = google_compute_region_network_endpoint_group.frontend.id
  }
}

resource "google_compute_backend_service" "backend" {
  name                  = "${var.environment}-backend-backend"
  protocol              = "HTTP"
  port_name             = "http"
  timeout_sec           = 30
  load_balancing_scheme = "EXTERNAL_MANAGED"
  security_policy       = google_compute_security_policy.backend.id

  backend {
    group = google_compute_region_network_endpoint_group.backend.id
  }
}

resource "google_compute_url_map" "main" {
  name            = "${var.environment}-mhcet-url-map"
  default_service = google_compute_backend_service.frontend.id

  host_rule {
    hosts        = [var.frontend_domain]
    path_matcher = "frontend"
  }

  host_rule {
    hosts        = [var.backend_domain]
    path_matcher = "backend"
  }

  path_matcher {
    name            = "frontend"
    default_service = google_compute_backend_service.frontend.id
  }

  path_matcher {
    name            = "backend"
    default_service = google_compute_backend_service.backend.id
  }
}

resource "google_compute_target_https_proxy" "main" {
  name             = "${var.environment}-mhcet-https-proxy"
  url_map          = google_compute_url_map.main.id
  ssl_certificates = [google_compute_managed_ssl_certificate.main.id]
}

resource "google_compute_global_forwarding_rule" "https" {
  name                  = "${var.environment}-mhcet-https-rule"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = "443"
  target                = google_compute_target_https_proxy.main.id
  ip_address            = google_compute_global_address.lb_ip.id
}

resource "google_compute_global_forwarding_rule" "http_redirect" {
  name                  = "${var.environment}-mhcet-http-rule"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = "80"
  target                = google_compute_target_http_proxy.redirect.id
  ip_address            = google_compute_global_address.lb_ip.id
}

resource "google_compute_url_map" "redirect" {
  name = "${var.environment}-mhcet-http-redirect"

  default_url_redirect {
    https_redirect         = true
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
    strip_query            = false
  }
}

resource "google_compute_target_http_proxy" "redirect" {
  name    = "${var.environment}-mhcet-http-proxy"
  url_map = google_compute_url_map.redirect.id
}
