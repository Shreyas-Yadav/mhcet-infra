variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "Default GCP region"
  type        = string
  default     = "asia-south1"
}

variable "state_bucket_name" {
  description = "GCS bucket name for Terraform remote state"
  type        = string
  default     = "mhcet-tf-state"
}

variable "github_org" {
  description = "GitHub organization or username"
  type        = string
}

variable "app_repo" {
  description = "Application repository name"
  type        = string
  default     = "mhcet"
}

variable "ai_repo" {
  description = "AI service repository name"
  type        = string
  default     = "mhcet-ai-service"
}

variable "infra_repo" {
  description = "Infrastructure repository name"
  type        = string
  default     = "mhcet-infra"
}

variable "wif_pool_id" {
  description = "Workload Identity Federation pool ID"
  type        = string
  default     = "github-pool"
}

variable "wif_provider_id" {
  description = "Workload Identity Federation provider ID"
  type        = string
  default     = "github-provider"
}
