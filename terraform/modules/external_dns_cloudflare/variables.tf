########################
# Required parameters
########################
variable "api_token" {
  type        = string
  description = "When using the Cloudflare provider, CF_API_TOKEN to set (optional)"
  default     = null
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