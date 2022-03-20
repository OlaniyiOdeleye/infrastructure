variable "website_domain_name" {
  description = "The domain name for merchant portal website"
  default     = ""
}
variable "project_id" {
  description = "The GCP project ID"
  type        = string
  default     = null
}

variable "enable_ssl" {
  type    = bool
  default = true
}

variable "enable_http" {
  type    = bool
  default = true
}

variable "enable_https_redirect" {
  type    = bool
  default = true
}

variable "ssl_name" {
  type    = string
  default = null
}

variable "location" {
  type = string
}

variable "force_destroy" {
  type    = string
  default = true
}

variable "not_found_page" {
  type    = string
  default = "404.html"
}

variable "labels" {
  default = {}
}

variable "base_domain" {
  description = "The name of the base domain for CloudFlare DNS records"
  type        = string
}

variable "cloudflare_zone_id" {
  description = "The CloudFlare zone ID that needs to be used for the DNS records."
  type        = string
  default     = ""
}

variable "proxied" {
  description = "This will enable or disable the proxied option in the CloudFlare DNS records"
  type        = bool
  default     = false
}

variable "dns_record_ttl" {
  description = "The time-to-live for the site A records (seconds)"
  # Must be 1 if proxied is equals to true in CloudFlare
  type    = string
  default = "1"
}