variable "project_id" {
  description = "Project id."
  type        = string
}

variable "region" {
  description = "Location of the resources in project."
  type        = string
}

variable "zone" {
  description = "Location of the resources in project."
  type        = string
}

variable "network" {
  description = "Existing network to deploy resources."
  type        = string
  default     = null
}

variable "subnet" {
  description = "Existing subnet to deploy resources."
  type        = string
  default     = null
}

variable "ad_fqdn" {
  description = "Active Director Fully Qualified Domain name"
  type        = string
}