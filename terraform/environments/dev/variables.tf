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
