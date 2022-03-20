locals {
  depends_on = var.create_namespace != true ? [] : [kubernetes_namespace.apps]
}

resource "kubernetes_namespace" "apps" {
  count = var.create_namespace == true ? 1 : 0
  metadata {
    labels      = merge(var.labels, var.namespace_labels)
    annotations = var.namespace_annotations
    name        = var.namespace
  }
}

resource "kubernetes_config_map" "configmap" {
  count = var.configmap_name == null ? 0 : 1
  metadata {
    name          = var.configmap_name
    namespace     = var.namespace
    labels        = var.labels
    generate_name = var.configmap_generate_name
  }

  data       = var.configmap_data
  depends_on = [local.depends_on]
}

resource "kubernetes_secret" "configs" {
  count = var.secret_name != null || var.secret_generate_name != null ? 1 : 0
  metadata {
    name          = var.secret_generate_name == null ? var.secret_name : null
    namespace     = var.namespace
    labels        = var.labels
    generate_name = var.secret_generate_name
  }

  data = var.secret_data
  type = var.secret_type

  depends_on = [local.depends_on]
}

resource "kubernetes_secret" "pull_secret" {
  count = var.pull_secret_name == null ? 0 : 1
  metadata {
    name      = var.pull_secret_name
    namespace = var.namespace
    labels    = var.labels
  }

  data = {
    ".dockerconfigjson" = <<DOCKER
{
  "auths": {
    "${var.pull_secret_registry}": {
      "auth": "${base64encode("_json_key:${var.pull_secret}")}"
    }
  }
}
DOCKER
  }

  type       = "kubernetes.io/dockerconfigjson"
  depends_on = [local.depends_on]
}
