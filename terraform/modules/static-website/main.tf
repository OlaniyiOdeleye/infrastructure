locals {
  ssl_name = var.ssl_name == null ? "${var.website_domain_name}-ssl" : var.ssl_name
}
# SSL CERTIFICATE

resource "google_compute_managed_ssl_certificate" "this" {
  provider = google-beta
  name     = local.ssl_name
  managed {
    domains = [var.website_domain_name]
  }
}

# STATIC WEBSITE
module "static_website" {
  source                           = "../http-load-balancer-website"
  project                          = var.project_id
  website_domain_name              = var.website_domain_name
  website_location                 = var.location
  enable_ssl                       = var.enable_ssl
  enable_http                      = var.enable_http
  enable_https_redirect            = var.enable_https_redirect
  ssl_certificate                  = google_compute_managed_ssl_certificate.this.self_link
  force_destroy_website            = var.force_destroy
  force_destroy_access_logs_bucket = var.force_destroy
  create_dns_entry                 = true
  not_found_page                   = var.not_found_page
  custom_labels                    = var.labels
  base_domain                      = var.base_domain
  cloudflare_zone_id               = var.cloudflare_zone_id
  dns_record_ttl                   = var.dns_record_ttl
  proxied                          = var.proxied
}
