variable "role_name" {
  description = "The name of the Postgres role to create"
  type        = string
}

variable "database_name" {
  description = "The name of the Postgres database that will be part of the role"
  type        = string
}

variable "database_privileges" {
  description = "The privileges that need to be assigned to the Postgres database"
  type        = list(string)
}

variable "table_privileges" {
  description = "The privileges that need to be assigned to the Postgres database tables"
  type        = list(string)
}
variable "user_details" {
  description = "A map of the users that will be added to the Postgres role"
  type = map(
    object({
      user_name = string
  }))
}