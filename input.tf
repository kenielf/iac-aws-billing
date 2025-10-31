variable "project" {
  type = string
  nullable = false
}

variable "budgets" {
  type = map(object({
    amount = number
    noticees = list(string)
    tags = map(string)
    type = optional(string, null)
    unit = optional(string, null)
    time = optional(string, null)
  }))
  default = {}
  validation {
    condition = alltrue([
      for b in values(var.budgets) : length(b.tags) > 0
    ])
    error_message = "Each budget must have at least one tag (the 'tags' map cannot be empty)."
  }
}

variable "cost_type_default" {
  type = string
  default = "COST"
  nullable = false
}

variable "cost_unit_default" {
  type = string
  default = "USD"
  nullable = false
}

variable "cost_time_default" {
  type = string
  default = "MONTHLY"
  nullable = false
}

variable "notification_threshold_defaults" {
  type = list(object({ type = string, threshold = number }))
  default = [
    { type = "ACTUAL", threshold = 85 },
    { type = "ACTUAL", threshold = 100 },
    { type = "FORECASTED", threshold = 100 },
  ]
  nullable = false
}
