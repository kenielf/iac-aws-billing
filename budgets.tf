locals {
  budget_tag_filter = toset(flatten([
    for budget, params in var.budgets: [
      for tag, _ in lookup(params, "tags", {}): tag
    ]
  ]))
}

resource "aws_ce_cost_allocation_tag" "budget_tags" {
  for_each = local.budget_tag_filter

  tag_key = each.value
  status  = "Active"
}

resource "aws_budgets_budget" "budgets" {
  for_each = var.budgets

  name         = "${title(var.project)} - ${title(each.key)} Budget"
  budget_type  = coalesce(each.value.type, var.cost_type_default)
  limit_amount = each.value.amount
  limit_unit   = coalesce(each.value.unit, var.cost_unit_default)
  time_unit    = coalesce(each.value.time, var.cost_time_default)

  cost_types {
    include_credit = false
    include_refund = false
  }

  cost_filter {
    name = "TagKeyValue"
    values = [ for k, v in each.value.tags: format("user:%s$%s", k, v) ]
  }

  dynamic "notification" {
    for_each = toset(var.notification_threshold_defaults)
    content {
      comparison_operator = "GREATER_THAN"
      threshold = notification.value.threshold
      threshold_type = "PERCENTAGE"
      notification_type = notification.value.type
      subscriber_email_addresses = each.value.noticees
    }
  }
}

