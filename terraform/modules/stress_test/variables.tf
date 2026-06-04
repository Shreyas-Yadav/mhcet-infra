variable "project_id" {
  type = string
}

variable "environment" {
  type = string
}

variable "region" {
  type = string
}

variable "image" {
  description = "Full Artifact Registry URI for the stress-test container"
  type        = string
}

variable "api_url" {
  description = "Target URL for each task (typically GET /predictions on dev API)"
  type        = string
}

variable "task_count" {
  description = "Number of parallel Cloud Run Job tasks (total requests = task_count × requests_per_task)"
  type        = number
  default     = 17
}

variable "parallelism" {
  description = "How many tasks run at once"
  type        = number
  default     = 17
}

variable "requests_per_task" {
  description = "HTTP requests fired by each task"
  type        = number
  default     = 300
}

variable "concurrency" {
  description = "In-flight curl requests per task"
  type        = number
  default     = 25
}

variable "task_timeout_seconds" {
  type    = number
  default = 1800
}

variable "runner_members" {
  description = "IAM members allowed to execute the job (e.g. user:you@example.com). Empty = project admins only."
  type        = list(string)
  default     = []
}
