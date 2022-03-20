terraform {
  required_version = "~> 0.14.0"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 2.0"
    }
  }
}

# Caveat! This module can be used to point sub-domains from cloudflare to a domain registrar of choice - but not the root domain itself.
resource "cloudflare_record" "cloudflare_ns_records" {
  for_each = var.records
  zone_id  = var.zone_id
  name     = var.name
  value    = each.value
  type     = "NS"
  ttl      = var.ttl
}
