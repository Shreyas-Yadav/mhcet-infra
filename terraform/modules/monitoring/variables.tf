variable "project_id" {
  type = string
}

variable "environment" {
  type = string
}

variable "backend_health_url" {
  description = "Full HTTPS URL for backend health check (e.g. https://host/health)"
  type        = string
}

variable "alert_email" {
  description = "Optional email for uptime alert notifications"
  type        = string
  default     = ""
}
