variable "slack_webhook" {
  type        = string
  description = "Webhook URL of the slack channel to deploy the notification"
  default     = null
}

variable "region" {
  description = "The GCP Project Region"
  default     = null
}

variable "project_id" {
  type        = string
  description = "name of the google project"
}

variable "project_name" {
  type        = string
  description = "name of the google project"
}

variable "index_source" {
  type        = string
  description = "path to index.zip file"
}

variable "environment" {
  type        = string
  description = "Environment where the notification would be deployed"
  default     = null
}