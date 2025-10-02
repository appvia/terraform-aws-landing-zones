# GitHub Repository Module Outputs

output "repository_name" {
  description = "The name of the created repository"
  value       = github_repository.repository.name
}

output "repository_full_name" {
  description = "The full name of the created repository (owner/repo)"
  value       = github_repository.repository.full_name
}

output "repository_description" {
  description = "The description of the created repository"
  value       = github_repository.repository.description
}

output "repository_visibility" {
  description = "The visibility of the created repository"
  value       = github_repository.repository.visibility
}

output "repository_html_url" {
  description = "The HTML URL of the created repository"
  value       = github_repository.repository.html_url
}

output "repository_ssh_clone_url" {
  description = "The SSH clone URL of the created repository"
  value       = github_repository.repository.ssh_clone_url
}

output "repository_git_clone_url" {
  description = "The Git clone URL of the created repository"
  value       = github_repository.repository.git_clone_url
}

output "repository_topics" {
  description = "The topics applied to the repository"
  value       = github_repository.repository.topics
}

output "repository_vulnerability_alerts" {
  description = "Whether vulnerability alerts are enabled"
  value       = github_repository.repository.vulnerability_alerts
}

output "repository_allow_merge_commit" {
  description = "Whether merge commits are allowed"
  value       = github_repository.repository.allow_merge_commit
}

output "repository_allow_rebase_merge" {
  description = "Whether rebase merges are allowed"
  value       = github_repository.repository.allow_rebase_merge
}

output "repository_allow_squash_merge" {
  description = "Whether squash merges are allowed"
  value       = github_repository.repository.allow_squash_merge
}

output "repository_allow_auto_merge" {
  description = "Whether auto merges are allowed"
  value       = github_repository.repository.allow_auto_merge
}

output "repository_delete_branch_on_merge" {
  description = "Whether branches are deleted on merge"
  value       = github_repository.repository.delete_branch_on_merge
}

output "environments" {
  description = "The environments configured for the repository"
  value = {
    for env in github_repository_environment.environments : env.environment => {
      environment         = env.environment
      prevent_self_review = env.prevent_self_review
    }
  }
}

output "collaborators" {
  description = "The collaborators of the repository"
  value = {
    for collab in github_repository_collaborator.collaborators : collab.username => {
      username   = collab.username
      permission = collab.permission
    }
  }
}

output "branch_protection_enabled" {
  description = "Whether branch protection is enabled"
  value       = github_branch_protection_v3.branch_protection != null
}

output "branch_protection_settings" {
  description = "The branch protection settings"
  value = {
    enforce_admins                  = github_branch_protection_v3.branch_protection.enforce_admins
    require_conversation_resolution = github_branch_protection_v3.branch_protection.require_conversation_resolution
    require_signed_commits          = github_branch_protection_v3.branch_protection.require_signed_commits
    required_approving_review_count = try(github_branch_protection_v3.branch_protection.required_pull_request_reviews[0].required_approving_review_count, 0)
    dismiss_stale_reviews           = try(github_branch_protection_v3.branch_protection.required_pull_request_reviews[0].dismiss_stale_reviews, false)
  }
}

output "required_status_checks" {
  description = "The required status checks for the repository"
  value       = try(github_branch_protection_v3.branch_protection.required_status_checks[0].checks, [])
}
