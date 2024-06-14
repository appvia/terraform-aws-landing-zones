
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
