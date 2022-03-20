variable "connection_id" {
  default = null
}

variable "location" {
  default = null
}

variable "friendly_name" {
  default = "BigQuery Connection"
}

variable "description" {
  default = ""
}

variable "instance_id" {
  type = string
}

variable "database_name" {
  type = string
}

variable "database_type" {
  type = string
}

variable "database_user" {
  type = string
}

variable "database_user_password" {
  type = string
}
