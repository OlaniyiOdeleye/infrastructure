variable "id" {
  description = "(Required) This must be unique within the project."
}

variable "value" {
  description = "(Required) The secret data. Must be no larger than 64KiB. Note: This property is sensitive and will not be displayed in the plan."
}

variable "labels" {
  default     = {}
  description = " (Optional) The labels assigned to this Secret"
}
