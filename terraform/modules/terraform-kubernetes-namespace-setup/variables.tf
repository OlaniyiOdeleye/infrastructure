variable "namespace" {
  description = "the name of the namespace to be created"
}

variable "create_namespace" {
  default     = true
  description = "Whether to create namespace or not"
}

variable "namespace_annotations" {
  description = "Annotations to be applied to the created namespace"
  default     = {}
}

variable "namespace_labels" {
  description = "Labels to be applied to the created namespace"
  default     = {}
}

variable "labels" {
  description = "Extra labels to be added to all created resources"
  default     = {}
}

variable "secret_name" {
  default     = null
  description = "The name of the secret to create and store variables as"
}


variable "secret_generate_name" {
  default     = null
  description = "Prefix, used by the server, to generate a unique name.This value will also be combined with a unique suffix. If provided, it'll override the name argument "
}

variable "secret_type" {
  default     = "Opaque"
  description = "The type of the secret to create. (default Opaque)"
}

variable "secret_data" {
  default     = {}
  description = "data to be populated into config secret created in namespace"
}

# These variables are used to create the Pull Secret to be used for pulling images
variable "pull_secret_name" {
  default     = null
  description = "The name of the pull secret"
}

variable "pull_secret" {
  default     = null
  description = "The base64 encoded credentials to be used as pull secret creds"
}

variable "pull_secret_registry" {
  default     = null
  description = "Registry server URL to be used"
}


variable "configmap_name" {
  default     = null
  description = "The name of the configmap to create and store variables as"
}

variable "configmap_generate_name" {
  default     = null
  description = "Prefix, used by the server, to generate a unique name.This value will also be combined with a unique suffix. If provided, it'll override the name argument "
}

variable "configmap_data" {
  default     = {}
  description = "data to be populated into configmap created in namespace"
}
