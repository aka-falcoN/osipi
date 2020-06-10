locals {
    bucket_name = "terraform-remote-state-${var.project_id}"
}

/******************************************
	Terraform remote state Bucket
 *****************************************/
module "remote_state_bucket" {
  source = "../modules/terraform/gcs"

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

//Invoke OSI SERVER, Integrator, MSSQL MODULE and pass service account id to pubsub and bigquery


# /******************************************
# 	Pub/Sub
#  *****************************************/

module "pubsub" {
  source     = "../modules/terraform/pubsub"
  project_id = var.project_id
  name       = "osipi-topic"
  iam_roles = [
    "roles/pubsub.viewer",
    "roles/pubsub.subscriber"
  ]
  iam_members = {
    "roles/pubsub.viewer"     = ["group:foo@example.com"]
    "roles/pubsub.subscriber" = ["user:user1@example.com"]
  }
}

// Configure subscription to push the incoming data in BigQuery

# /******************************************
# 	Bigquery
#  *****************************************/

module "bigquery-dataset" {
  source     = "../modules/terraform/bigquery_dataset"
  project_id = var.project_id
  id          = "osipi-dataset"
  access_roles = {
    reader = { role = "READER", type = "group_by_email" }
    owner        = { role = "OWNER", type = "user_by_email" }
  }
  access_identities = {
    reader = "playground-test@ludomagno.net"
    owner  = "ludo@ludomagno.net"
  }

  options = {
    default_table_expiration_ms     = null
    default_partition_expiration_ms = null
    delete_contents_on_destroy      = false
  }
}