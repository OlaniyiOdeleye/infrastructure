terraform {
  required_version = "~> 0.14.0"

  required_providers {
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "1.14.0"
    }
  }
}


# Generate random passwords for the Postgres users
resource "random_password" "postgres_passwords" {
  for_each = var.user_details
  length   = 16
  special  = true
}

# Create a secret for each user in Google Secret Manager
resource "google_secret_manager_secret" "database_secrets" {
  for_each  = var.user_details
  secret_id = "${each.value.user_name}-db-details"

  replication {
    automatic = true
  }
}

# Create the secret data that will be stored in each secret, this will be the generated password
resource "google_secret_manager_secret_version" "database_secrets_version" {
  for_each    = var.user_details
  secret      = google_secret_manager_secret.database_secrets[each.key].id
  secret_data = random_password.postgres_passwords[each.key].result

  depends_on = [google_secret_manager_secret.database_secrets]
}

# Create a data source for each secret which will be used for adding the Postgres users
data "google_secret_manager_secret_version" "database_details_data" {
  for_each = var.user_details
  secret   = google_secret_manager_secret.database_secrets[each.key].secret_id

  depends_on = [google_secret_manager_secret_version.database_secrets_version]
}

# Create the Postgres role
resource "postgresql_role" "role" {
  name = var.role_name

  depends_on = [google_secret_manager_secret_version.database_secrets_version]
}

# Assign the required privileges to the Postgres role
resource "postgresql_grant" "database_role_grants" {
  database    = var.database_name
  role        = postgresql_role.role.name
  object_type = "database"
  privileges  = var.database_privileges

  depends_on = [postgresql_role.role]
}

resource "postgresql_grant" "table_role_grants" {
  database    = var.database_name
  role        = postgresql_role.role.name
  schema      = "public"
  object_type = "table"
  objects     = []
  privileges  = var.table_privileges

  depends_on = [postgresql_grant.database_role_grants]
}

# Create a Posgres user for each user required and assign them to the Postgres role
resource "postgresql_role" "role_user" {
  for_each = var.user_details
  name     = each.value.user_name
  password = data.google_secret_manager_secret_version.database_details_data[each.key].secret_data
  login    = true

  roles = [
    postgresql_role.role.name
  ]

  depends_on = [postgresql_grant.table_role_grants]
}