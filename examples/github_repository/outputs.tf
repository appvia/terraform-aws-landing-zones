#####################################################################################
# Outputs for the GitHub Repository Module Example
# These outputs demonstrate what information is available from the module
#####################################################################################

# Basic repository outputs
output "basic_repository_name" {
  description = "The name of the basic repository"
  value       = var.enable_basic_repository ? module.basic_repository.repository : null
}

output "basic_repository_url" {
  description = "The URL of the basic repository"
  value       = var.enable_basic_repository ? "https://github.com/${var.github_organization}/${var.basic_repository_name}" : null
}

output "basic_repository_ssh_url" {
  description = "The SSH URL of the basic repository"
  value       = var.enable_basic_repository ? "git@github.com:${var.github_organization}/${var.basic_repository_name}.git" : null
}

output "basic_repository_visibility" {
  description = "The visibility of the basic repository"
  value       = var.enable_basic_repository ? "private" : null
}

output "basic_repository_default_branch" {
  description = "The default branch of the basic repository"
  value       = var.enable_basic_repository ? "main" : null
}

output "basic_repository_environments" {
  description = "The environments configured for the basic repository"
  value       = var.enable_basic_repository ? var.basic_repository_environments : null
}

output "basic_repository_collaborators" {
  description = "The collaborators of the basic repository"
  value       = var.enable_basic_repository ? var.basic_repository_collaborators : null
}

output "basic_repository_topics" {
  description = "The topics of the basic repository"
  value       = var.enable_basic_repository ? var.basic_repository_topics : null
}

# Public repository outputs
output "public_repository_name" {
  description = "The name of the public repository"
  value       = var.enable_public_repository ? module.public_repository.repository : null
}

output "public_repository_url" {
  description = "The URL of the public repository"
  value       = var.enable_public_repository ? "https://github.com/${var.github_organization}/${var.public_repository_name}" : null
}

output "public_repository_ssh_url" {
  description = "The SSH URL of the public repository"
  value       = var.enable_public_repository ? "git@github.com:${var.github_organization}/${var.public_repository_name}.git" : null
}

output "public_repository_visibility" {
  description = "The visibility of the public repository"
  value       = var.enable_public_repository ? "public" : null
}

output "public_repository_default_branch" {
  description = "The default branch of the public repository"
  value       = var.enable_public_repository ? "main" : null
}

output "public_repository_topics" {
  description = "The topics of the public repository"
  value       = var.enable_public_repository ? var.public_repository_topics : null
}

# Enterprise repository outputs
output "enterprise_repository_name" {
  description = "The name of the enterprise repository"
  value       = var.enable_enterprise_repository ? module.enterprise_repository.repository : null
}

output "enterprise_repository_url" {
  description = "The URL of the enterprise repository"
  value       = var.enable_enterprise_repository ? "https://github.com/${var.github_organization}/${var.enterprise_repository_name}" : null
}

output "enterprise_repository_ssh_url" {
  description = "The SSH URL of the enterprise repository"
  value       = var.enable_enterprise_repository ? "git@github.com:${var.github_organization}/${var.enterprise_repository_name}.git" : null
}

output "enterprise_repository_visibility" {
  description = "The visibility of the enterprise repository"
  value       = var.enable_enterprise_repository ? "private" : null
}

output "enterprise_repository_default_branch" {
  description = "The default branch of the enterprise repository"
  value       = var.enable_enterprise_repository ? "main" : null
}

output "enterprise_repository_environments" {
  description = "The environments configured for the enterprise repository"
  value       = var.enable_enterprise_repository ? var.enterprise_repository_environments : null
}

output "enterprise_repository_collaborators" {
  description = "The collaborators of the enterprise repository"
  value       = var.enable_enterprise_repository ? var.enterprise_repository_collaborators : null
}

output "enterprise_repository_topics" {
  description = "The topics of the enterprise repository"
  value       = var.enable_enterprise_repository ? var.enterprise_repository_topics : null
}

output "enterprise_repository_required_approving_review_count" {
  description = "The required approving review count for the enterprise repository"
  value       = var.enable_enterprise_repository ? var.enterprise_required_approving_review_count : null
}

# Summary outputs
output "all_repository_names" {
  description = "List of all created repository names"
  value = compact([
    var.enable_basic_repository ? var.basic_repository_name : "",
    var.enable_public_repository ? var.public_repository_name : "",
    var.enable_enterprise_repository ? var.enterprise_repository_name : ""
  ])
}

output "all_repository_urls" {
  description = "List of all created repository URLs"
  value = compact([
    var.enable_basic_repository ? "https://github.com/${var.github_organization}/${var.basic_repository_name}" : "",
    var.enable_public_repository ? "https://github.com/${var.github_organization}/${var.public_repository_name}" : "",
    var.enable_enterprise_repository ? "https://github.com/${var.github_organization}/${var.enterprise_repository_name}" : ""
  ])
}

output "repository_count" {
  description = "Total number of repositories created"
  value = ((var.enable_basic_repository ? 1 : 0) +
    (var.enable_public_repository ? 1 : 0) +
  (var.enable_enterprise_repository ? 1 : 0))
}
