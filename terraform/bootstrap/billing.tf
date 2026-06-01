variable "billing_account_id" {
  description = "GCP billing account ID (e.g. 0174B5-A8EC0A-69EEE4)"
  type        = string
}

variable "monthly_budget_usd" {
  description = "Monthly budget alert threshold in USD for this project"
  type        = number
  default     = 25
}

variable "budget_alert_email" {
  description = "Optional email for billing budget threshold alerts"
  type        = string
  default     = ""
}

resource "google_monitoring_notification_channel" "billing_email" {
  count = var.budget_alert_email != "" ? 1 : 0

  project      = var.project_id
  display_name = "Billing budget alerts"
  type         = "email"
  labels = {
    email_address = var.budget_alert_email
  }
}

resource "google_billing_budget" "project" {
  billing_account = "billingAccounts/${var.billing_account_id}"
  display_name    = "${var.project_id}-monthly-budget"

  budget_filter {
    projects = ["projects/${var.project_id}"]
  }

  amount {
    specified_amount {
      currency_code = "USD"
      units         = tostring(var.monthly_budget_usd)
    }
  }

  threshold_rules {
    threshold_percent = 0.5
    spend_basis       = "CURRENT_SPEND"
  }

  threshold_rules {
    threshold_percent = 0.9
    spend_basis       = "CURRENT_SPEND"
  }

  threshold_rules {
    threshold_percent = 1.0
    spend_basis       = "CURRENT_SPEND"
  }

  dynamic "all_updates_rule" {
    for_each = var.budget_alert_email != "" ? [1] : []
    content {
      monitoring_notification_channels = [
        google_monitoring_notification_channel.billing_email[0].name
      ]
    }
  }
}
