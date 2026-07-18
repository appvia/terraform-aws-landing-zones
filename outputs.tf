
output "account_id" {
  description = "The account id where the pipeline is running"
  value       = data.aws_caller_identity.current.account_id
}

output "environment" {
  description = "The environment name for the tenant"
  value       = var.environment
}

## Note the nonsensitive() calls below. var.infrastructure_repository is marked sensitive as a
## whole because it carries webhooks[].secret and Terraform cannot mark a single attribute of an
## object type. That sensitivity propagates to anything derived from the variable, including
## these values. None of them contain the secret - they are a role name and repository URLs - so
## the marking is unwrapped here rather than redacting outputs consumers legitimately need.
output "infrastructure_repository_role_name" {
  description = "The IAM role name used for infrastructure repository OIDC permissions"
  value       = nonsensitive(local.infrastructure_repository_role_name)
}

output "infrastructure_repository_git_clone_url" {
  description = "The URL of the infrastructure repository for the landing zone"
  value       = nonsensitive(local.enable_infrastructure_repository ? module.github_repository[0].repository_git_clone_url : null)
}

output "infrastructure_repository_url" {
  description = "The HTML URL of the infrastructure repository for the landing zone"
  value       = nonsensitive(local.enable_infrastructure_repository ? module.github_repository[0].repository_html_url : null)
}

output "ipam_pools_by_name" {
  description = "A map of the ipam pool name to id"
  value       = local.ipam_pools_by_name
}

output "networks" {
  description = "A map of the network name to network details"
  value       = module.networks
}

output "private_hosted_zones" {
  description = "A map of the private hosted zones"
  value       = local.private_hosted_zones
}

output "private_hosted_zones_by_id" {
  description = "A map of the hosted zone name to id"
  value       = local.private_hosted_zones_by_id
}

output "sns_notification_arn" {
  description = "The SNS topic ARN for notifications"
  value       = module.notifications.sns_topic_arn
}

output "sns_notification_name" {
  description = "Name of the SNS topic used to channel notifications"
  value       = local.notifications_sns_topic_name
}

output "tags" {
  description = "The tags to apply to all resources"
  value       = local.tags
}

output "vpc_ids" {
  description = "A map of the network name to vpc id"
  value       = local.vpc_id_by_network_name
}
