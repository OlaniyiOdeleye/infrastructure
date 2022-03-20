output "dns_id" {
  description = "The ID of the DNS Check"
  value       = grafana_synthetic_monitoring_check.dns.id
}

output "dns_tenant_id" {
  description = "The Tenant ID of the DNS Check"
  value       = grafana_synthetic_monitoring_check.dns.tenant_id
}

output "http_id" {
  description = "The ID of the HTTP Check"
  value       = grafana_synthetic_monitoring_check.http.id
}

output "http_tenant_id" {
  description = "The Tenant ID of the HTTP Check"
  value       = grafana_synthetic_monitoring_check.http.tenant_id
}