# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# DEPLOY A HTTP LOAD BALANCER
# This module deploys a HTTP(S) Cloud Load Balancer
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

terraform {
  # This module is now only being tested with Terraform 1.0.x. However, to make upgrading easier, we are setting
  # 0.12.26 as the minimum version, as that version added support for required_providers with source URLs, making it
  # forwards compatible with 1.0.x code.
  required_version = ">= 0.12.26"
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 2.0"
    }
  }
}

# ------------------------------------------------------------------------------
# CREATE A PUBLIC IP ADDRESS
# ------------------------------------------------------------------------------

resource "google_compute_global_address" "default" {
  project      = var.project
  name         = "${var.name}-address"
  ip_version   = "IPV4"
  address_type = "EXTERNAL"
}

# ------------------------------------------------------------------------------
# IF PLAIN HTTP ENABLED, CREATE FORWARDING RULE AND PROXY
# ------------------------------------------------------------------------------

resource "google_compute_target_http_proxy" "http" {
  count   = var.enable_http ? 1 : 0
  project = var.project
  name    = "${var.name}-http-proxy"
  url_map = var.url_map
}

resource "google_compute_global_forwarding_rule" "http" {
  provider   = google-beta
  count      = var.enable_http ? 1 : 0
  project    = var.project
  name       = "${var.name}-http-rule"
  target     = google_compute_target_http_proxy.http[0].self_link
  ip_address = google_compute_global_address.default.address
  port_range = "80"

  depends_on = [google_compute_global_address.default]

  labels = var.custom_labels
}

# ------------------------------------------------------------------------------
# FOR HTTPS REDIRECT, CREATE FORWARDING RULE AND PROXY
# ------------------------------------------------------------------------------

resource "google_compute_url_map" "https-redirect" {
  name  = "${var.name}-https-redirect"
  count = var.enable_https_redirect ? 1 : 0
  default_url_redirect {
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT" // 301 redirect
    strip_query            = false
    https_redirect         = true // this is the magic
  }
}

resource "google_compute_target_http_proxy" "https-redirect" {
  count   = var.enable_https_redirect ? 1 : 0
  project = var.project
  name    = "${var.name}-https-redirect"
  url_map = google_compute_url_map.https-redirect[0].self_link
}

resource "google_compute_global_forwarding_rule" "https-redirect" {
  count      = var.enable_https_redirect ? 1 : 0
  name       = "${var.name}-https-redirect"
  target     = google_compute_target_http_proxy.https-redirect[0].self_link
  ip_address = google_compute_global_address.default.address
  port_range = "80"
}

# ------------------------------------------------------------------------------
# IF SSL ENABLED, CREATE FORWARDING RULE AND PROXY
# ------------------------------------------------------------------------------

resource "google_compute_global_forwarding_rule" "https" {
  provider   = google-beta
  project    = var.project
  count      = var.enable_ssl ? 1 : 0
  name       = "${var.name}-https-rule"
  target     = google_compute_target_https_proxy.default[0].self_link
  ip_address = google_compute_global_address.default.address
  port_range = "443"
  depends_on = [google_compute_global_address.default]

  labels = var.custom_labels
}

resource "google_compute_ssl_policy" "static_website_ssl_policy" {
  name            = "${var.name}-ssl-policy"
  profile         = "RESTRICTED"
  min_tls_version = "TLS_1_2"
}

resource "google_compute_target_https_proxy" "default" {
  project = var.project
  count   = var.enable_ssl ? 1 : 0
  name    = "${var.name}-https-proxy"
  url_map = var.url_map

  ssl_certificates = var.ssl_certificates
  ssl_policy       = google_compute_ssl_policy.static_website_ssl_policy.self_link
}

# DNS RECORDS TO ADD TO CLOUDFLARE FOR THE STATIC WEBSITES
# ------------------------------------------------------------------------------

resource "cloudflare_record" "static_websites" {
  zone_id = var.cloudflare_zone_id
  count   = var.create_dns_entries ? length(var.custom_domain_names) : 0
  name    = trimsuffix(element(var.custom_domain_names, count.index), ".${var.base_domain}")
  value   = google_compute_global_address.default.address
  type    = "A"
  ttl     = var.dns_record_ttl
  proxied = var.proxied
}