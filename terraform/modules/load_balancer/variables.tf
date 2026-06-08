variable "environment" {
  type = string
}

variable "region" {
  type = string
}

variable "frontend_domain" {
  type = string
}

variable "backend_domain" {
  type = string
}

variable "frontend_service_name" {
  type = string
}

variable "backend_service_name" {
  type = string
}

variable "rate_limit_requests_per_minute" {
  description = "Cloud Armor rate limit per client IP on the API backend service"
  type        = number
  default     = 100
}

variable "ai_domain" {
  type = string
}

variable "ai_service_name" {
  type = string
}
