locals {
    bucket_name = "osi-integrator-staging-gcs-${var.project_id}"
}
# /******************************************
# 	IAM & Service Account
#  *****************************************/

module "osi_integrator_service_account" {
  source        = "../../terraform/iam_service_accounts"
  project_id    = var.project_id
  names         = ["osi-integrator-service-account"]
  generate_keys = false
  iam_members   = {}
}

/******************************************
	OSIPI Integrator staging bucket
 *****************************************/
module "integrator_staging_bucket" {
  source = "../../terraform/gcs"

  project_id       = var.project_id
  prefix           = ""
  names            = [local.bucket_name]
  location         = var.region
  storage_class    = "REGIONAL"
  set_viewer_roles = true
  set_admin_roles  = false

  bucket_viewers   = { "${local.bucket_name}" = module.osi_integrator_service_account.iam_email }
}

/******************************************
	OSIPI Integrator VM
 *****************************************/

module "osipi-integrator-vm" {
  source     = "../../terraform/compute_engine"
  project_id = var.project_id
  region     = var.region
  zone       = var.zone
  name       = "osipi-integrator"
  network_interfaces = [{
    network    = var.network_self_link,
    subnetwork = var.subnet_self_link,
    nat        = false,
    addresses  = null
  }]
  service_account = module.osi_integrator_service_account.email
  instance_count = 1

  boot_disk = {
    image        = "projects/windows-cloud/global/images/windows-server-2012-r2-dc-v20200512"
    type         = "pd-ssd"
    size         = 200
  }
}