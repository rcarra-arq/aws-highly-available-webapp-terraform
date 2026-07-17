# =========================
# Cost guardrail - AWS Budget
# =========================
# Account-wide (not filtered by tag) on purpose: the scenario this
# protects against is "I forgot something running", and a forgotten
# resource may be exactly the one that missed a tag. Plain cost
# budgets with email notifications are free of charge.
resource "aws_budgets_budget" "monthly" {
  name         = "${var.project_name}-monthly-budget"
  budget_type  = "COST"
  limit_amount = var.monthly_budget_limit
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  # 80% of the limit actually spent - something is probably running
  # longer than a lab session should.
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.alert_email]
  }

  # Forecasted to blow past the limit by month end - early warning
  # before the money is actually spent.
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = [var.alert_email]
  }
}
