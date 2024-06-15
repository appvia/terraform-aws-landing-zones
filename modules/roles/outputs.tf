
output "iam_role_name" {
  description = "The name of the IAM role you are using to run this module"
  value       = local.assumed_role_name
}

output "iam_base_role_name" {
  description = "The base name of the IAM role you are using to run this module"
  value       = local.landing_zone_base_role_name
}

output "iam_network_role_name" {
  description = "The name of the IAM role you should use to interact with the connectivity account"
  value       = local.network_role_name
}

output "iam_identity_role_name" {
  description = "The name of the IAM role you should use to interact with the identity account"
  value       = local.identity_role_name
}
