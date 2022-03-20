terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
    grafana = {
      source  = "grafana/grafana"
      version = "~> 1.17.0"

    }
  }
  required_version = "~> 0.14.0"
}

resource "google_service_account" "data_source" {
  account_id   = var.service_account_id
  display_name = "Grafana Service Account"
  description  = "Grafana Service Account"
  project      = var.project
}

resource "google_project_iam_member" "data_source" {
  project = var.project
  role    = "roles/monitoring.viewer"
  member  = "serviceAccount:${google_service_account.data_source.email}"
}


resource "google_service_account_key" "data_source" {
  service_account_id = google_service_account.data_source.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}

resource "grafana_data_source" "data_source" {
  type = "stackdriver"
  name = var.datasource_name

  json_data {
    token_uri           = "https://oauth2.googleapis.com/token"
    authentication_type = "jwt"
    default_project     = google_service_account.data_source.project
    client_email        = google_service_account.data_source.email
  }

  secure_json_data {
    private_key = jsondecode(base64decode(google_service_account_key.data_source.private_key))["private_key"]
  }

  depends_on = [google_project_iam_member.data_source]
}
