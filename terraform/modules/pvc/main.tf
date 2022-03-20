#This Module creates persistent_volume_claim in specified zone
#Persistent Volume Claims are attached to Persistent Volumes backed by pre-defined GCP disks on specific zones

resource "google_compute_disk" "pd" {
  name = var.disk_name
  type = "pd-standard"
  zone = var.disk_zone
  size = var.disk_size_gb
  labels = {
    environment     = var.environment
    goog-gke-volume = ""
  }
}

resource "kubernetes_persistent_volume" "pv" {
  metadata {
    name = var.disk_name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    capacity = {
      storage = "${var.disk_size_gb}Gi"
    }
    persistent_volume_source {
      gce_persistent_disk {
        pd_name = google_compute_disk.pd.name
        fs_type = "ext4"
      }
    }
    storage_class_name = "standard"
  }
}

resource "kubernetes_persistent_volume_claim" "pvc" {
  metadata {
    name      = var.disk_name
    namespace = var.namespace
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "${var.disk_size_gb}Gi"
      }
    }
    volume_name        = kubernetes_persistent_volume.pv.metadata.0.name
    storage_class_name = "standard"
  }
}
