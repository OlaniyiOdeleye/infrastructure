variable "namespace" {
  description = "The K8's namespace to deploy the Persistent Storage Disk"
  type        = string
}

variable "disk_name" {
  description = "The name of the Persistent Storage Disk"
  type        = string
}

variable "disk_size_gb" {
  description = "The size in (Gi) for the Persistent Storage Disk"
  type        = string
}

variable "disk_zone" {
  type        = string
  description = "The zone to host the cluster in (optional if regional cluster / required if zonal)"
  default     = null
}

variable "environment" {
  default     = null
  type        = string
  description = "Current project environment"
}