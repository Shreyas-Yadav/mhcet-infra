variable "project_id" {
  type = string
}

variable "region" {
  type    = string
  default = "asia-south1"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "frontend_domain" {
  type = string
}

variable "backend_domain" {
  type = string
}

variable "cors_allowed_origins" {
  type = string
}

variable "db_tier" {
  type    = string
  default = "db-f1-micro"
}

variable "backend_min_instances" {
  type    = number
  default = 0
}

variable "frontend_min_instances" {
  type    = number
  default = 0
}

variable "backend_image" {
  type = string
}

variable "frontend_image" {
  type = string
}

variable "backend_health_url" {
  type = string
}

variable "alert_email" {
  type    = string
  default = ""
}

variable "rate_limit_requests_per_minute" {
  description = "Cloud Armor API rate limit per client IP. Raise temporarily (e.g. 5000) during dev load tests."
  type        = number
  default     = 100
}

variable "ai_image" {
  type = string
}

variable "ai_domain" {
  type = string
}

variable "google_api_key" {
  type      = string
  sensitive = true
  default   = ""
}
