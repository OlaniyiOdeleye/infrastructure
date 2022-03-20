# we use workload identity to avoid having to manage API keys.
# create a GSA, a KSA and link them using workload-identities
# @see https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity
module "external_dns_workload_identity" {
  source                          = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"
  version                         = "17.0.0"
  project_id                      = var.project_id
  cluster_name                    = var.gke_cluster_name
  location                        = var.region
  name                            = var.gsa_name
  k8s_sa_name                     = var.ksa_name
  namespace                       = var.namespace
  roles                           = var.gsa_roles
  use_existing_k8s_sa             = false # we create the KSA so that we can bind it to the GSA
  use_existing_gcp_sa             = false # we create the GSA so that we can bind it to the KSA
  automount_service_account_token = true
}

# The config needed for invoking the external-dns helm chart
locals {
  provider = var.dns_provider
  values = {
    domainFilters = var.domain_filters
    provider      = local.provider
    txtOwnerId    = "my-identifier"
    policy        = "sync"
    google = {
      project = var.project_id
    }
    cloudflare = {
      apiToken = var.cloudflare_api_token
      proxied  = var.cloudflare_proxied
    }
    serviceAccount = {
      name   = var.ksa_name
      create = false # workload identity will create the KSA and bind it to a GSA
    }
  }
}

# install external_dns via helm chart.
resource "helm_release" "external_dns" {
  name             = "external-dns"
  repository       = "https://charts.bitnami.com/bitnami"
  chart            = "external-dns"
  version          = var.chart_version
  namespace        = var.namespace
  create_namespace = true
  values           = [yamlencode(local.values)]

  # force the helm release to wait for the KSA and workload-identity to be configured
  depends_on = [module.external_dns_workload_identity]
}
