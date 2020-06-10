output "service_account_iam_email" {
  description = "service account iam email"
  value       = module.osi_server_service_account.iam_email
}

output "service_account_email" {
  description = "service account email"
  value       = module.osi_server_service_account.email
}