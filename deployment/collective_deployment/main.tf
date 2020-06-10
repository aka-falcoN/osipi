locals {
  bucket_name = "terraform-remote-state-${var.project_id}"
  network = var.network == null ? element(google_compute_network.vpc.*.self_link, 0) : var.network
  subnet  = var.subnet == null ? element(google_compute_subnetwork.subnet.*.self_link, 0) : var.subnet

  network_name = split("/", local.network)[9]
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
# 	Google managed MS Active Directory
#  *****************************************/

# resource "null_resource" "create_active_directory" {
#   triggers = {
#     project_id = var.project_id
#   }
#   provisioner "local-exec" {
#     command = "gcloud active-directory domains create ${var.ad_fqdn} --reserved-ip-range='172.16.0.0/24' --region=${var.region} --authorized-networks=osipi-vpc --project=${var.project_id}"
#   }
# }

# resource "null_resource" "delete_active_directory" {
#   triggers = {
#     project_id = var.project_id
#   }
#   provisioner "local-exec" {
#     command = "gcloud active-directory domains create --project=${var.project_id} ${var.ad_fqdn} --reserved-ip-range='172.16.0.0/24' --region=${var.region} --authorized-networks=${local.network_name}"
#   }
# }

# /******************************************
# 	VPC configuration
#  *****************************************/
resource "google_compute_network" "vpc" {
  provider = google-beta

  count = var.network == null ? 1 : 0

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

  count = var.subnet == null ? 1 : 0

  name                     = "osipi-subnet"
  project                  = var.project_id
  network                  = local.network_name
  ip_cidr_range            = "10.0.1.0/24"
  private_ip_google_access = "true"
  region                   = var.region
}

module "osipi_server" {
  source = "../../modules/osipi/server"

  project_id        = var.project_id
  region            = var.region
  zone              = var.zone
  network_self_link = local.network
  subnet_self_link  = local.subnet
}

module "osipi_integrator" {
  source = "../../modules/osipi/integrator"

  project_id        = var.project_id
  region            = var.region
  zone              = var.zone
  network_self_link = local.network
  subnet_self_link  = local.subnet
}

# /******************************************
# 	Pub/Sub
#  *****************************************/

module "pubsub" {
  source     = "../../modules/terraform/pubsub"
  project_id = var.project_id
  name       = "osipi-topic"
  iam_roles = [
    "roles/pubsub.editor"
  ]
  iam_members = {
    "roles/pubsub.editor" = [module.osipi_integrator.service_account_iam_email]
  }
}

// Configure subscription to push the incoming data in BigQuery

# /******************************************
# 	Bigquery
#  *****************************************/

module "bigquery_dataset" {
  source     = "../../modules/terraform/bigquery_dataset"
  project_id = var.project_id
  id         = "osipi_dataset"
  access_roles = {
    owner    = { role = "OWNER", type = "user_by_email" }
    bq_users = { role = "special_group", type = "allAuthenticatedUsers" }
  }
  access_identities = {
    owner = module.osipi_integrator.service_account_email
  }

  options = {
    default_table_expiration_ms     = null
    default_partition_expiration_ms = null
    delete_contents_on_destroy      = false
  }
}