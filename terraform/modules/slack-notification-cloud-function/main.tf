
#The value of google_storage_bucket_object.archive.source of the module should be passed from the root module to avoid errors
resource "google_storage_bucket" "bucket" {
  name     = "gke-notification-slack-${var.environment}"
  location = var.region
}

resource "google_storage_bucket_object" "archive" {
  name   = "index.zip"
  bucket = google_storage_bucket.bucket.name
  source = var.index_source
}
resource "google_pubsub_topic" "slack_notifications" {
  name = "gke-slack-topic-${var.environment}"
}

resource "google_cloudfunctions_function" "function" {
  name        = "slackNotifier-${var.environment}"
  description = "Cloud function for deploying gke notifications into slack"
  runtime     = "nodejs10"

  available_memory_mb   = 128
  service_account_email = module.google_cloudfunctions_sa.email
  source_archive_bucket = google_storage_bucket.bucket.name
  source_archive_object = google_storage_bucket_object.archive.name
  entry_point           = "slackNotifier"
  environment_variables = {
    SLACK_WEBHOOK = var.slack_webhook
  }
  build_environment_variables = {
    SLACK_WEBHOOK = var.slack_webhook
  }
  event_trigger {
    event_type = "google.pubsub.topic.publish"
    resource   = google_pubsub_topic.slack_notifications.name
    failure_policy {
      retry = true
    }
  }
}

module "google_cloudfunctions_sa" {
  source       = "terraform-google-modules/service-accounts/google"
  version      = "~> 3.0.1"
  description  = "Service Account Used by Gitlab Runners (Managed By Terraform)"
  display_name = "Google Cloud functions Service Account"
  project_id   = var.project_id
  prefix       = var.project_name
  names        = ["cloudfunction"]
  project_roles = [
    "${var.project_id}=>roles/cloudfunctions.invoker"
  ]
}
