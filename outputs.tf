
output "environment" {
  description = "The environment name for the tenant"
  value       = var.environment
}

output "tags" {
  description = "The tags to apply to all resources"
  value       = local.tags
}

output "private_hosted_zones_by_id" {
  description = "A map of the hosted zone name to id"
  value       = local.private_hosted_zones_by_id
}

output "vpc_ids" {
  description = "A map of the network name to vpc id"
  value       = local.vpc_id_by_network_name
}

output "networks" {
  description = "A map of the network name to network details"
  value       = module.networks
}

output "account_id" {
  description = "The account id where the pipeline is running"
  value       = data.aws_caller_identity.current.account_id
}

output "tenant_account_id" {
  description = "The region of the tenant account"
  value       = data.aws_caller_identity.tenant.id
}

output "private_hosted_zones" {
  description = "A map of the private hosted zones"
  value       = local.private_hosted_zones
}

output "sns_notification_name" {
  description = "Name of the SNS topic used to channel notifications"
  value       = local.notifications_sns_topic_name
}

output "sns_notification_arn" {
  description = "The SNS topic ARN for notifications"
  value       = module.notifications.sns_topic_arn
}

output "auditor_account_id" {
  description = "The account id for the audit account"
  value       = local.audit_account_id
}

output "log_archive_account_id" {
  description = "The account id for the log archive account"
  value       = local.log_archive_account_id
}

output "ipam_pools_by_name" {
  description = "A map of the ipam pool name to id"
  value       = local.ipam_pools_by_name
}
