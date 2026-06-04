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

variable "stress_test_enabled" {
  description = "Provision Cloud Run Job for distributed load tests (dev only)."
  type        = bool
  default     = false
}

variable "stress_test_image_tag" {
  type    = string
  default = "dev-latest"
}

variable "stress_test_task_count" {
  description = "Parallel job tasks; total requests = task_count × requests_per_task (default 17×300 ≈ 5100)."
  type        = number
  default     = 17
}

variable "stress_test_parallelism" {
  type    = number
  default = 17
}

variable "stress_test_requests_per_task" {
  type    = number
  default = 300
}

variable "stress_test_concurrency" {
  type    = number
  default = 25
}

variable "stress_test_api_path" {
  description = "Path + query for predict load test (host comes from backend_domain)."
  type        = string
  default     = "/predictions?percentile=90&category=OPEN&gender=MALE&page=0&size=25&includeMapOptions=false"
}

variable "stress_test_runner_members" {
  description = "IAM members who may execute the stress job (roles/run.jobsExecutor)."
  type        = list(string)
  default     = []
}
