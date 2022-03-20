resource "google_dns_policy" "dns_policy" {
  name           = var.name
  enable_logging = true
  networks {
    network_url = var.network_url
  }
}