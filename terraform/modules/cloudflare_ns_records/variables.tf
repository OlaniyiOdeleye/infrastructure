variable "records" {
  description = "The values of all the NS servers"
  type        = set(string)
}

variable "zone_id" {
  description = "The Cloud Flare Zone ID"
  type        = string
}

variable "name" {
  description = "The name of the DNS record"
  type        = string
  default     = "@"
}

variable "ttl" {
  description = "TTL value for DNS record"
  type        = number
  default     = 1
}