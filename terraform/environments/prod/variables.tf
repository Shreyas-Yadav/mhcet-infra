variable "project_id" {
  type = string
}

variable "region" {
  type    = string
  default = "asia-south1"
}

variable "environment" {
  type    = string
  default = "prod"
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
  default = "db-custom-1-3840"
}

variable "backend_min_instances" {
  type    = number
  default = 1
}

variable "frontend_min_instances" {
  type    = number
  default = 0
}

variable "backend_max_instances" {
  type    = number
  default = 5
}

variable "frontend_max_instances" {
  type    = number
  default = 5
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

# Parent registrable domain shared by frontend/backend/ai subdomains, so the session cookie
# reaches the AI subdomain (e.g. "example.com").
variable "session_cookie_domain" {
  type    = string
  default = ""
}
