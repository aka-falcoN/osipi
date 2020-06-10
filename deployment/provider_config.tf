/******************************************
  Required terraform version
 *****************************************/
terraform {
  required_version = "~> 0.12.26"
}

/******************************************
  Provider credential configuration
 *****************************************/
provider "google" {
  version      = ">= 3.23.0"
}

provider "google-beta" {
  version      = ">= 3.23.0"
}