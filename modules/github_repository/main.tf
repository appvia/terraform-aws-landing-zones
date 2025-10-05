## Provision the repositories in github
resource "github_repository" "repository" {
  allow_auto_merge       = var.allow_auto_merge
  allow_merge_commit     = var.allow_merge_commit
  allow_rebase_merge     = var.allow_rebase_merge
  allow_squash_merge     = var.allow_squash_merge
  delete_branch_on_merge = var.delete_branch_on_merge
  description            = var.description
  name                   = var.repository
  topics                 = var.repository_topics
  visibility             = var.visibility
  vulnerability_alerts   = true

  dynamic "template" {
    for_each = local.enable_repository_template == true ? [1] : toset([])
    content {
      owner                = var.organization_template
      repository           = var.repository_template
      include_all_branches = false
    }
  }
}

## Define the main branch
resource "github_branch" "default" {
  branch     = var.default_branch
  repository = github_repository.repository.name
}

## Define the default branch
resource "github_branch" "default_branch" {
  branch     = var.default_branch
  repository = github_repository.repository.name
}

## Associate the production enviroment with each of the repositories
resource "github_repository_environment" "environments" {
  for_each = toset(var.repository_environments)

  environment         = each.value
  prevent_self_review = var.prevent_self_review
  repository          = github_repository.repository.name


  deployment_branch_policy {
    protected_branches     = true
    custom_branch_policies = false
  }
}

## Associate the branch protection with each of the repositories
resource "github_branch_protection_v3" "branch_protection" {
  branch                          = var.default_branch
  enforce_admins                  = var.enforce_branch_protection_for_admins
  repository                      = github_repository.repository.name
  require_conversation_resolution = true
  require_signed_commits          = true

  required_status_checks {
    strict = false
    checks = var.required_status_checks
  }

  required_pull_request_reviews {
    dismiss_stale_reviews           = var.dismiss_stale_reviews
    dismissal_users                 = var.dismissal_users
    dismissal_teams                 = var.dismissal_teams
    dismissal_apps                  = var.dismissal_apps
    required_approving_review_count = var.required_approving_review_count

    dynamic "bypass_pull_request_allowances" {
      for_each = var.bypass_pull_request_allowances_users != null || var.bypass_pull_request_allowances_teams != null || var.bypass_pull_request_allowances_apps != null ? [1] : []
      content {
        users = var.bypass_pull_request_allowances_users
        teams = var.bypass_pull_request_allowances_teams
        apps  = var.bypass_pull_request_allowances_apps
      }
    }
  }
}

## Associate any collaborators with the repositories
resource "github_repository_collaborator" "collaborators" {
  for_each = { for collaborator in var.repository_collaborators : collaborator.username => collaborator }

  permission = each.value.permission
  repository = github_repository.repository.name
  username   = each.value.username
}
