resource "google_bigquery_connection" "connection" {
  provider      = google-beta
  connection_id = var.connection_id
  location      = var.location
  friendly_name = var.friendly_name
  description   = var.description
  cloud_sql {
    instance_id = var.instance_id
    database    = var.database_name
    type        = var.database_type
    credential {
      username = var.database_user
      password = var.database_user_password
    }
  }
}
