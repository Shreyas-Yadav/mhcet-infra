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

variable "google_oauth_client_id" {
  type    = string
  default = ""
}

variable "google_oauth_client_secret" {
  type      = string
  sensitive = true
  default   = ""
}

# Parent registrable domain for the session cookie (e.g. "example.com") so it reaches the
# sibling AI subdomain. Must cover frontend_domain, backend_domain, and ai_domain.
variable "session_cookie_domain" {
  type    = string
  default = ""
}
