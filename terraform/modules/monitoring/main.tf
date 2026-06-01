locals {
  health_host = replace(replace(var.backend_health_url, "https://", ""), "/health", "")
  health_path = "/health"
}

resource "google_monitoring_uptime_check_config" "backend" {
  display_name = "${var.environment}-mhcet-backend-health"
  timeout      = "10s"
  period       = "300s"

  http_check {
    path         = local.health_path
    port         = 443
    use_ssl      = true
    validate_ssl = true
  }

  monitored_resource {
    type = "uptime_url"
    labels = {
      project_id = var.project_id
      host       = local.health_host
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_monitoring_notification_channel" "email" {
  count = var.alert_email != "" ? 1 : 0

  display_name = "${var.environment}-mhcet-alerts"
  type         = "email"
  labels = {
    email_address = var.alert_email
  }
}

resource "google_monitoring_alert_policy" "backend_down" {
  display_name = "${var.environment}-mhcet-backend-uptime"
  combiner     = "OR"

  conditions {
    display_name = "Backend uptime check failed"
    condition_threshold {
      filter          = "resource.type = \"uptime_url\" AND metric.type = \"monitoring.googleapis.com/uptime_check/check_passed\" AND metric.labels.check_id = \"${google_monitoring_uptime_check_config.backend.uptime_check_id}\""
      comparison      = "COMPARISON_LT"
      threshold_value = 1
      duration        = "300s"

      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_NEXT_OLDER"
      }

      trigger {
        count = 1
      }
    }
  }

  notification_channels = var.alert_email != "" ? [google_monitoring_notification_channel.email[0].name] : []

  alert_strategy {
    auto_close = "604800s"
  }
}
