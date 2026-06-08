variable "project_id" {
  type = string
}

variable "environment" {
  type = string
}

variable "region" {
  type = string
}

variable "backend_image" {
  type = string
}

variable "frontend_image" {
  type = string
}

variable "cloud_sql_connection_name" {
  type = string
}

variable "database_name" {
  type = string
}

variable "database_user" {
  type = string
}

variable "db_password_secret_id" {
  type = string
}

variable "cors_allowed_origins" {
  type = string
}

variable "backend_min_instances" {
  type    = number
  default = 0
}

variable "backend_max_instances" {
  type    = number
  default = 3
}

variable "frontend_min_instances" {
  type    = number
  default = 0
}

variable "frontend_max_instances" {
  type    = number
  default = 3
}

# Backend loads the full prediction index in memory at startup; 512Mi OOMs on prod data.
variable "backend_memory" {
  type    = string
  default = "2Gi"
}

variable "frontend_memory" {
  type    = string
  default = "512Mi"
}

variable "ai_image" {
  type = string
}

variable "ai_domain" {
  type = string
}

variable "google_api_key_secret_id" {
  type = string
}

variable "ai_min_instances" {
  type    = number
  default = 0
}

variable "ai_max_instances" {
  type    = number
  default = 2
}
