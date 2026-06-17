# Cost discipline as code: tag everything + a budget that pages you, not your invoice.
provider "aws" {
  default_tags { tags = { owner = "netops", project = "lab", env = "nonprod" } }
}

resource "aws_budgets_budget" "monthly" {
  name         = "lab-monthly"
  budget_type  = "COST"
  limit_amount = "20"
  limit_unit   = "USD"
  time_unit    = "MONTHLY"
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = ["alerts@example.com"]
  }
}
