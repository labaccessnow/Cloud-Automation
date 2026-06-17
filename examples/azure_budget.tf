# Azure: a subscription budget with an 80% alert — FinOps parity with the AWS example.
# Same idea everywhere: a ceiling that pages a human before the invoice does.
terraform {
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 4.0" }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_subscription" "current" {}

resource "azurerm_consumption_budget_subscription" "monthly" {
  name            = "lab-monthly"
  subscription_id = data.azurerm_subscription.current.id
  amount          = 20
  time_grain      = "Monthly"

  time_period {
    start_date = "2026-01-01T00:00:00Z"
  }

  notification {
    enabled        = true
    threshold      = 80
    operator       = "GreaterThan"
    threshold_type = "Actual"
    contact_emails = ["alerts@example.com"]
  }
}
