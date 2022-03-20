variable "config" {
  description = "The Workload config to enable Workload Identity For"
  type = list(map({
    name      = string
    namespace = string
    roles     = list(string)
  }))
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
}
