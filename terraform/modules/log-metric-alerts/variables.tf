variable "metric_name" {
  description = "name of logmetrics"
  type        = string
}

variable "metric_filter" {
  description = "metric filter for alert policy"
  type        = string
}

variable "notification_channels" {
  description = "notification_channels for sending alerts."
  type        = string
}

variable "environment" {
  description = "environment of the resources e.g qa, prod"
  type        = string
}
