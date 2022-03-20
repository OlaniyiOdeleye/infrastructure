variable "project" {
  description = "Google project to create resources in"
  type        = string
}

variable "service_account_id" {
  description = "GCP service account name"
  type        = string
}

variable "datasource_name" {
  description = "The name of the datasource on Grafana"
  type        = string
}
