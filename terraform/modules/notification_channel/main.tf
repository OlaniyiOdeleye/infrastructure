resource "google_monitoring_notification_channel" "channel" {
  project      = var.project_id
  display_name = var.display_name
  type         = "slack"
  labels = {
    channel_name = var.channel_name
  }
  sensitive_labels {
    auth_token = data.google_secret_manager_secret_version.secret.secret_data
  }
}

data "google_secret_manager_secret_version" "secret" {
  project = var.project_id
  secret  = var.channel_secret
}
