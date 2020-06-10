/******************************************
	OSIPI MSSQL VM
 *****************************************/

module "osipi_mssql_vm" {
  source     = "../../terraform/compute_engine"
  project_id = var.project_id
  region     = var.region
  zone       = var.zone
  name       = "osipi-mssql"
  network_interfaces = [{
    network    = var.network_self_link,
    subnetwork = var.subnet_self_link,
    nat        = false,
    addresses  = null
  }]
  service_account = var.service_account
  instance_count = 1

  boot_disk = {
    image        = "projects/windows-sql-cloud/global/images/sql-2012-standard-windows-2012-r2-dc-v20200512"
    type         = "pd-ssd"
    size         = 200  //should change according to the topology
  }
}