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

variable "network_self_link" {
  description = "Subnet self link"
  type        = string
}

variable "subnet_self_link" {
  description = "Subnet self link"
  type        = string
}