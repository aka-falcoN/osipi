locals {
  bucket_name = "terraform-remote-state-${var.project_id}"
}

/******************************************
	Terraform remote state Bucket
 *****************************************/
module "remote_state_bucket" {
  source = "../../modules/terraform/gcs"

  project_id       = var.project_id
  prefix           = ""
  names            = [local.bucket_name]
  location         = var.region
  storage_class    = "REGIONAL"
  set_viewer_roles = false
  set_admin_roles  = false
  versioning       = { "${local.bucket_name}" = true }
}

# /******************************************
# 	VPC configuration
#  *****************************************/
resource "google_compute_network" "vpc" {
  provider = google-beta

  name                    = "osipi-vpc"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
  project                 = var.project_id
  description             = "OSIPI ecosystem VPC"
}

# /******************************************
# 	Subnet configuration
#  *****************************************/
resource "google_compute_subnetwork" "subnet" {
  provider = google-beta

  name                     = "osipi-subnet"
  project                  = var.project_id
  network                  = google_compute_network.vpc.name
  ip_cidr_range            = "10.0.1.0/24"
  private_ip_google_access = "true"
  region                   = var.region
}

module "osipi_server" {
  source = "../../modules/osipi/server"

  project_id        = var.project_id
  region            = var.region
  zone              = var.zone
  network_self_link = var.network == null ? google_compute_network.vpc.self_link : var.network
  subnet_self_link  = var.subnet == null ? google_compute_subnetwork.subnet.self_link : var.subnet
}
