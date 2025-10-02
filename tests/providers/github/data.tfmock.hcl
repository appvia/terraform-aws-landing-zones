# GitHub provider mock for testing
# This file provides mock data for GitHub resources during testing

mock_data "github_organization" {
  defaults = {
    name        = "test-organization"
    login       = "test-organization"
    description = "Test organization for terraform testing"
    plan        = "free"
  }
}

mock_data "github_repository" {
  defaults = {
    name                   = "test-repository"
    full_name              = "test-organization/test-repository"
    description            = "Test repository"
    private                = true
    visibility             = "private"
    default_branch         = "main"
    allow_auto_merge       = false
    allow_merge_commit     = true
    allow_rebase_merge     = true
    allow_squash_merge     = true
    delete_branch_on_merge = true
    vulnerability_alerts   = true
    topics                 = ["terraform", "aws", "test"]
    html_url               = "https://github.com/test-organization/test-repository"
    ssh_clone_url          = "git@github.com:test-organization/test-repository.git"
    git_clone_url          = "https://github.com/test-organization/test-repository.git"
    clone_url              = "https://github.com/test-organization/test-repository.git"
    svn_url                = "https://github.com/test-organization/test-repository"
    homepage_url           = ""
    language               = ""
    forks_count            = 0
    stargazers_count       = 0
    watchers_count         = 0
    size                   = 0
    archived               = false
    disabled               = false
    has_issues             = true
    has_projects           = true
    has_downloads          = true
    has_wiki               = true
    has_pages              = false
    has_discussions        = false
    created_at             = "2024-01-01T00:00:00Z"
    updated_at             = "2024-01-01T00:00:00Z"
    pushed_at              = "2024-01-01T00:00:00Z"
  }
}

mock_data "github_branch" {
  defaults = {
    repository                                                                    = "test-repository"
    branch                                                                        = "main"
    ref                                                                           = "refs/heads/main"
    sha                                                                           = "abc123def456"
    source_branch                                                                 = null
    source_sha                                                                    = null
    protection_enabled                                                            = true
    protection_restricts_pushes                                                   = false
    protection_required_status_checks                                             = []
    protection_required_pull_request_reviews                                      = []
    protection_dismiss_stale_reviews                                              = false
    protection_require_code_owner_reviews                                         = false
    protection_required_approving_review_count                                    = 0
    protection_enforce_admins                                                     = false
    protection_restrictions                                                       = []
    protection_allow_force_pushes                                                 = false
    protection_allow_deletions                                                    = false
    protection_allow_fork_syncing                                                 = false
    protection_lock_branch                                                        = false
    protection_allow_force_pushes_bypass_who                                      = []
    protection_allow_deletions_bypass_who                                         = []
    protection_restrictions_users                                                 = []
    protection_restrictions_teams                                                 = []
    protection_restrictions_apps                                                  = []
    protection_required_status_checks_contexts                                    = []
    protection_required_status_checks_strict                                      = false
    protection_required_status_checks_checks                                      = []
    protection_required_pull_request_reviews_dismiss_stale_reviews                = false
    protection_required_pull_request_reviews_require_code_owner_reviews           = false
    protection_required_pull_request_reviews_required_approving_review_count      = 0
    protection_required_pull_request_reviews_bypass_pull_request_allowances_users = []
    protection_required_pull_request_reviews_bypass_pull_request_allowances_teams = []
    protection_required_pull_request_reviews_bypass_pull_request_allowances_apps  = []
    protection_required_pull_request_reviews_dismissal_users                      = []
    protection_required_pull_request_reviews_dismissal_teams                      = []
    protection_required_pull_request_reviews_dismissal_apps                       = []
  }
}

mock_data "github_repository_environment" {
  defaults = {
    repository          = "test-repository"
    environment         = "production"
    wait_timer          = 0
    prevent_self_review = true
    reviewers           = []
    deployment_branch_policy = {
      protected_branches     = true
      custom_branch_policies = false
    }
  }
}

mock_data "github_branch_protection_v3" {
  defaults = {
    repository                      = "test-repository"
    branch                          = "main"
    enforce_admins                  = true
    require_conversation_resolution = true
    require_signed_commits          = true
    required_status_checks = {
      strict = false
      checks = ["test-check"]
    }
    required_pull_request_reviews = {
      dismiss_stale_reviews           = true
      dismissal_users                 = []
      dismissal_teams                 = []
      dismissal_apps                  = []
      required_approving_review_count = 1
      bypass_pull_request_allowances = {
        users = []
        teams = []
        apps  = []
      }
    }
  }
}

mock_data "github_repository_collaborator" {
  defaults = {
    repository                  = "test-repository"
    username                    = "test-user"
    permission                  = "write"
    permission_diff_suppression = false
  }
}
