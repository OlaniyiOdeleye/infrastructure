resource "google_logging_metric" "logging_metric" {
  name   = "${var.metric_name}/metric"
  filter = var.metric_filter
  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
  }
}

resource "google_monitoring_alert_policy" "alert_policy" {
  display_name = "${var.metric_name}-${var.environment}-alert"
  combiner     = "OR"
  conditions {
    display_name = "${var.metric_name}-alert"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/${var.metric_name}/metric\" AND resource.type=\"global\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }

  documentation {
    content = "This alert is set for changes in the metric"
  }
  notification_channels = [var.notification_channels, ]
}
