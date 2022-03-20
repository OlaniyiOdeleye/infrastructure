terraform {
  required_version = ">= 0.14.0"

  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "~> 1.17.0"
    }
  }
}

# Load list of Probes from Grafana Cloud
data "grafana_synthetic_monitoring_probes" "main" {}


# Create Synthetic Monitoring DNS Check
resource "grafana_synthetic_monitoring_check" "dns" {
  job                = "${var.name} - Check DNS"
  target             = var.target
  enabled            = var.enabled
  basic_metrics_only = var.basic_metrics_only
  frequency          = var.frequency
  timeout            = var.timeout
  alert_sensitivity  = var.alert_sensitivity
  probes = [
    data.grafana_synthetic_monitoring_probes.main.probes.Amsterdam,
  ]
  settings {
    dns {}
  }
}


# Create Synthetic Monitoring HTTP Check
resource "grafana_synthetic_monitoring_check" "http" {
  job                = "${var.name} - Check HTTP"
  target             = "https://${var.target}"
  enabled            = var.enabled
  basic_metrics_only = var.basic_metrics_only
  frequency          = var.frequency
  timeout            = var.timeout
  alert_sensitivity  = var.alert_sensitivity
  probes = [
    data.grafana_synthetic_monitoring_probes.main.probes.Amsterdam,
  ]
  settings {
    http {}
  }

  depends_on = [grafana_synthetic_monitoring_check.dns]
}