
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
