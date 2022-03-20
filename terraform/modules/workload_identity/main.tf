#------------------------------
# WORKLOAD IDENTITY
#------------------------------
module "workload_identity" {
  count      = len(var.config)
  source     = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"
  version    = "~>12.1.0"
  name       = var.config[count.index]["name"]
  namespace  = var.config[count.index]["namespace"]
  project_id = var.project_id
  roles      = var.config[count.index]["roles"]
}
