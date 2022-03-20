########################
# Required parameters
########################
variable "project_id" {
  type        = string
  description = "The Google Project ID"
}

variable "region" {
  type = string
}

variable "gke_cluster_name" {
  type = string
}

variable "domain_filters" {
  type        = list(string)
  description = "List of Domains to watch"
}

variable "exclude_domains" {
  type        = list(string)
  description = "List of sub domains to exclude"
}

variable "environment" {
  description = "Current project environment"
  type        = string
}

variable "proxied" {
  description = "Enable or Disable the proxy feature of CloudFlare"
  type        = bool
  default     = false
}

########################
# Optional Parameters
########################
variable "namespace" {
  type        = string
  description = "The namespace to deploy the external DNS kubernetes object"
  default     = "default"
}

variable "chart_version" {
  type        = string
  description = "The version of External DNS Helm Chart to use for installation."
  default     = "5.4.7"
}

variable "ksa_name" {
  type        = string
  description = "The name to give the Kubernetes Service Account (KSA)"
  default     = "internal-dns-gcp"
}

variable "gsa_name" {
  type        = string
  description = "The name to give the Google Service Account (GSA)"
  default     = "internal-dns-gcp"
}

variable "gsa_roles" {
  type    = list(string)
  default = ["roles/dns.admin"]
}
