terraform {
  # This module is now only being tested with Terraform 1.0.x. However, to make upgrading easier, we are setting
  # 0.12.26 as the minimum version, as that version added support for required_providers with source URLs, making it
  # forwards compatible with 1.0.x code.
  required_version = ">= 0.12.26"
}

# ---------------------------------------------------------------------------------------------------------------------
# Create the Network & corresponding Router to attach other resources to
# Networks that preserve the default route are automatically enabled for Private Google Access to GCP services
# provided subnetworks each opt-in; in general, Private Google Access should be the default.
# ---------------------------------------------------------------------------------------------------------------------

resource "google_compute_network" "vpc" {
  name    = "${var.name_prefix}-network"
  project = var.project

  # Always define custom subnetworks- one subnetwork per region isn't useful for an opinionated setup
  auto_create_subnetworks = "false"

  # A global routing mode can have an unexpected impact on load balancers; always use a regional mode
  routing_mode = "REGIONAL"
}

resource "google_compute_router" "vpc_router" {
  name = "${var.name_prefix}-router"

  project = var.project
  region  = var.region
  network = google_compute_network.vpc.self_link
}

# ---------------------------------------------------------------------------------------------------------------------
# Public Subnetwork Config
# Public internet access for instances with addresses is automatically configured by the default gateway for 0.0.0.0/0
# External access is configured with Cloud NAT, which subsumes egress traffic for instances without external addresses
# ---------------------------------------------------------------------------------------------------------------------
resource "google_compute_subnetwork" "vpc_subnetwork_public" {
  name = "${var.name_prefix}-subnetwork-public"

  project = var.project
  region  = var.region
  network = google_compute_network.vpc.self_link

  private_ip_google_access = true
  ip_cidr_range            = cidrsubnet(var.cidr_block, var.cidr_subnetwork_width_delta, 0)

  secondary_ip_range {
    range_name = "public-services"
    ip_cidr_range = cidrsubnet(
      var.secondary_cidr_block,
      var.secondary_cidr_subnetwork_width_delta,
      0
    )
  }

  dynamic "log_config" {
    for_each = var.log_config == null ? [] : list(var.log_config)

    content {
      aggregation_interval = var.log_config.aggregation_interval
      flow_sampling        = var.log_config.flow_sampling
      metadata             = var.log_config.metadata
    }
  }
}

resource "google_compute_address" "nat_address" {
  count   = 2
  name    = "nat-manual-ip-${count.index}"
  region  = var.region
  project = var.project
}


resource "google_compute_router_nat" "vpc_nat" {
  name = "${var.name_prefix}-nat"

  project = var.project
  region  = var.region
  router  = google_compute_router.vpc_router.name

  nat_ip_allocate_option = "MANUAL_ONLY"
  nat_ips                = google_compute_address.nat_address.*.self_link

  # "Manually" define the subnetworks for which the NAT is used, so that we can exclude the public subnetwork
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.vpc_subnetwork_private.self_link
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
  subnetwork {
    name                    = google_compute_subnetwork.vpc_subnetwork_private_persistence.self_link
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
  # nat_ip_allocate_option = "AUTO_ONLY"

  # # "Manually" define the subnetworks for which the NAT is used, so that we can exclude the public subnetwork
  # source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  # subnetwork {
  #   name                    = google_compute_subnetwork.vpc_subnetwork_public.self_link
  #   source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  # }
}

# ---------------------------------------------------------------------------------------------------------------------
# Private Subnetwork Config 1
# ---------------------------------------------------------------------------------------------------------------------

resource "google_compute_subnetwork" "vpc_subnetwork_private" {
  name = "${var.name_prefix}-subnetwork-private"

  project = var.project
  region  = var.region
  network = google_compute_network.vpc.self_link

  private_ip_google_access = true
  ip_cidr_range = cidrsubnet(
    var.cidr_block,
    var.cidr_subnetwork_width_delta,
    1 * (1 + var.cidr_subnetwork_spacing)
  )

  secondary_ip_range {
    range_name = "private-services"
    ip_cidr_range = var.private_services_secondary_cidr_block != null ? var.private_services_secondary_cidr_block : cidrsubnet(
      var.secondary_cidr_block,
      var.secondary_cidr_subnetwork_width_delta,
      1 * (1 + var.secondary_cidr_subnetwork_spacing)
    )
  }

  dynamic "log_config" {
    for_each = var.log_config == null ? [] : tolist([var.log_config])

    content {
      aggregation_interval = var.log_config.aggregation_interval
      flow_sampling        = var.log_config.flow_sampling
      metadata             = var.log_config.metadata
    }
  }
}
# ADDING THIS FOR AN EXTRA PRIVATE SUBNET
# ---------------------------------------------------------------------------------------------------------------------
# Private Subnetwork Config 2
# ---------------------------------------------------------------------------------------------------------------------

resource "google_compute_subnetwork" "vpc_subnetwork_private_persistence" {
  name = "${var.name_prefix}-subnetwork-private-persistence"

  project = var.project
  region  = var.region
  network = google_compute_network.vpc.self_link

  private_ip_google_access = true
  ip_cidr_range = cidrsubnet(
    var.cidr_block,
    var.cidr_subnetwork_width_delta,
    2 * (1 + var.cidr_subnetwork_spacing)
  )

  secondary_ip_range {
    range_name = "private-persistence-services"
    ip_cidr_range = var.persistence_services_secondary_cidr_block != null ? var.persistence_services_secondary_cidr_block : cidrsubnet(
      var.secondary_cidr_block,
      var.secondary_cidr_subnetwork_width_delta,
      1 * (1 + var.secondary_cidr_subnetwork_spacing)
    )
  }

  dynamic "log_config" {
    for_each = var.log_config == null ? [] : tolist([var.log_config])

    content {
      aggregation_interval = var.log_config.aggregation_interval
      flow_sampling        = var.log_config.flow_sampling
      metadata             = var.log_config.metadata
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Attach Firewall Rules to allow inbound traffic to tagged instances
# ---------------------------------------------------------------------------------------------------------------------

module "network_firewall" {
  source      = "../firewall-rules"
  name_prefix = var.name_prefix

  project                               = var.project
  network                               = google_compute_network.vpc.self_link
  allowed_public_restricted_subnetworks = var.allowed_public_restricted_subnetworks

  public_subnetwork  = google_compute_subnetwork.vpc_subnetwork_public.self_link
  private_subnetwork = google_compute_subnetwork.vpc_subnetwork_private.self_link
}

data "google_compute_subnetwork" "private_persistence_subnetwork" {
  self_link = google_compute_subnetwork.vpc_subnetwork_private_persistence.self_link
}

#add private persistence to inbound rule
resource "google_compute_firewall" "private_allow_all_network_inbound" {
  name = "${var.name_prefix}-private-persistence"

  project = var.project
  network = google_compute_network.vpc.self_link

  target_tags = ["private", "private-persistence"] #[local.private]
  direction   = "INGRESS"

  source_ranges = [
    data.google_compute_subnetwork.private_persistence_subnetwork.ip_cidr_range,
    data.google_compute_subnetwork.private_persistence_subnetwork.secondary_ip_range[0].ip_cidr_range,
  ]

  priority = "1000"

  allow {
    protocol = "all"
  }
}