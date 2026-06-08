variable "environment" {
  type = string
}

variable "google_api_key" {
  type      = string
  sensitive = true
  default   = ""
}
