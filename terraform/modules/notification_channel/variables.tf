variable "project_id" {
  type        = string
  description = "Project ID"
}

variable "channel_name" {
  description = "Slack Channel for sending alerts."
  type        = string
}

variable "display_name" {
  description = "This is dispaly name for Notification Channel on GCP."
  type        = string
}

variable "channel_secret" {
  description = "this is the secret manager name storing slack api key. Actual secret will be retrieved as secret data"
  type        = string
}
