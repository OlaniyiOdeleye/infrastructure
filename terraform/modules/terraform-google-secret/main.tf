resource "google_secret_manager_secret" "secret" {
  secret_id = var.id

  labels = var.labels

  replication {
    automatic = true
  }
}


resource "google_secret_manager_secret_version" "secret-version-basic" {
  secret = google_secret_manager_secret.secret.id

  secret_data = var.value
}
