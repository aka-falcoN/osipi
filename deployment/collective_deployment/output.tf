output "network_name" {
  description = "VPC network name"
  value       = google_compute_network.vpc.name
}

output "network_self_link" {
  description = "VPC Self Link"
  value       = google_compute_network.vpc.self_link
}

output "subnet_name" {
  description = "Subnet description"
  value       = google_compute_subnetwork.subnet
}

output "subnet_self_link" {
  description = "Subnet Self Link"
  value       = google_compute_subnetwork.subnet.self_link
}