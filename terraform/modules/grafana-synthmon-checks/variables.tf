########################
# Required parameters
########################

variable "name" {
  description = "The Name of this Job"
  type        = string
}

variable "target" {
  description = "The URL to be checked"
  type        = string
}

########################
# Optional parameters
########################

variable "enabled" {
  description = "Should the Check be enabled"
  type        = bool
  default     = true
}

variable "basic_metrics_only" {
  description = "Should only Basic Metrics be logged"
  type        = bool
  default     = true
}

variable "frequency" {
  description = "How often should this check run in milliseconds"
  type        = number
  default     = 120000
}

variable "timeout" {
  description = "How long before the check times out"
  type        = number
  default     = 3000
}

variable "alert_sensitivity" {
  description = "The sensitivity of this alert"
  type        = string
  default     = "none"
}