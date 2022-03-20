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

variable "service_account" {
  type        = string
  description = "The service Account to user"
  default     = "external-dns"
}

variable "ksa_name" {
  type        = string
  description = "The name to give the Kubernetes Service Account (KSA)"
  default     = "external-dns"
}

variable "gsa_name" {
  type        = string
  description = "The name to give the Google Service Account (GSA)"
  default     = "external-dns"
}

variable "dns_provider" {
  type        = string
  description = "DNS provider where the DNS records will be created (Default: google)"
  default     = "google"
}

variable "gsa_roles" {
  type    = list(string)
  default = ["roles/dns.admin"]
}

# These parameters are required when using the cloudflare dns provider
variable "cloudflare_api_token" {
  type        = string
  description = "When using the Cloudflare provider, CF_API_TOKEN to set (optional)"
  default     = null
}

variable "cloudflare_proxied" {
  type        = string
  description = "When using the Cloudflare provider, enable the proxy feature (DDOS protection, CDN...) (optional)"
  default     = false
}