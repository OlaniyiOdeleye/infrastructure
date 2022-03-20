# The config needed for invoking the external-dns helm chart
locals {
  values = {
    domainFilters  = var.domain_filters
    excludeDomains = var.exclude_domains
    txtOwnerId     = var.environment
    provider       = "cloudflare"
    policy         = "upsert-only" # Change to Upsert to prevent accidental deletes. Safety first!
    cloudflare = {
      # Note: The way we set this up is to allow access to ALL zones. We do not filter on a "zone ID".
      apiToken = var.api_token
      proxied  = var.proxied
    }
  }
}

# install external_dns via helm chart.
resource "helm_release" "external_dns_cloudflare" {
  name             = "external-dns-cloudflare"
  repository       = "https://charts.bitnami.com/bitnami"
  chart            = "external-dns"
  version          = var.chart_version
  namespace        = var.namespace
  create_namespace = true
  values           = [yamlencode(local.values)]
}