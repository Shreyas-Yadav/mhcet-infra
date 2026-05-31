variable "environment" {
  type = string
}

variable "region" {
  type = string
}

variable "tier" {
  type    = string
  default = "db-f1-micro"
}

variable "availability_type" {
  type    = string
  default = "ZONAL"
}

variable "disk_size" {
  type    = number
  default = 10
}

variable "point_in_time_recovery_enabled" {
  type    = bool
  default = false
}

variable "deletion_protection" {
  type    = bool
  default = false
}

variable "database_name" {
  type    = string
  default = "mhcet"
}

variable "database_user" {
  type    = string
  default = "mhcet"
}

variable "database_password" {
  type      = string
  sensitive = true
}
