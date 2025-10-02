#####################################################################################
# Terraform module examples are meant to show an _example_ on how to use a module
# per use-case. The code below should not be copied directly but referenced in order
# to build your own root module that invokes this module
#####################################################################################

# Example 1: Basic repository creation
module "basic_repository" {
  source = "../../modules/github_repository"

  repository  = "my-terraform-project"
  description = "A basic Terraform project repository"

  # Repository settings
  visibility     = "private"
  default_branch = "main"

  # Merge settings
  allow_merge_commit     = true
  allow_rebase_merge     = true
  allow_squash_merge     = true
  allow_auto_merge       = false
  delete_branch_on_merge = true

  # Template settings
  repository_template   = "terraform-aws-pipeline-template"
  organization_template = "appvia"

  # Branch protection settings
  enforce_branch_protection_for_admins = true
  required_approving_review_count      = 2
  dismiss_stale_reviews                = true
  prevent_self_review                  = true

  # Required status checks
  required_status_checks = [
    "Terraform / Terraform Plan and Apply / Commitlint",
    "Terraform / Terraform Plan and Apply / Terraform Format",
    "Terraform / Terraform Plan and Apply / Terraform Lint",
    "Terraform / Terraform Plan and Apply / Terraform Plan",
    "Terraform / Terraform Plan and Apply / Terraform Security",
    "Terraform / Terraform Plan and Apply / Terraform Validate",
  ]

  # Environment settings
  repository_environments          = ["staging", "production"]
  default_environment_review_users = ["admin-user"]
  default_environment_review_teams = ["platform-team"]

  # Repository topics
  repository_topics = ["terraform", "aws", "infrastructure", "iac"]

  # Collaborators
  repository_collaborators = [
    {
      username   = "developer1"
      permission = "write"
    },
    {
      username   = "developer2"
      permission = "write"
    }
  ]
}

# Example 2: Public repository with different settings
module "public_repository" {
  source = "../../modules/github_repository"

  repository  = "my-open-source-project"
  description = "An open source project repository"

  # Public repository settings
  visibility     = "public"
  default_branch = "main"

  # More permissive merge settings for open source
  allow_merge_commit     = true
  allow_rebase_merge     = true
  allow_squash_merge     = true
  allow_auto_merge       = true
  delete_branch_on_merge = true

  # Stricter branch protection for public repo
  enforce_branch_protection_for_admins = true
  required_approving_review_count      = 1
  dismiss_stale_reviews                = true
  prevent_self_review                  = true

  # Custom status checks for open source
  required_status_checks = [
    "CI / Build and Test",
    "Security / Security Scan",
    "Code Quality / Lint"
  ]

  # No environments for open source
  repository_environments = []

  # Open source topics
  repository_topics = ["open-source", "terraform", "aws", "community"]

  # No specific collaborators for open source
  repository_collaborators = []
}

# Example 3: Enterprise repository with strict controls
module "enterprise_repository" {
  source = "../../modules/github_repository"

  repository  = "enterprise-critical-system"
  description = "Enterprise critical system repository with strict controls"

  # Private enterprise repository
  visibility     = "private"
  default_branch = "main"

  # Conservative merge settings
  allow_merge_commit     = false
  allow_rebase_merge     = false
  allow_squash_merge     = true
  allow_auto_merge       = false
  delete_branch_on_merge = true

  # Use enterprise template
  repository_template   = "enterprise-terraform-template"
  organization_template = "my-enterprise-org"

  # Strict branch protection
  enforce_branch_protection_for_admins = true
  required_approving_review_count      = 3
  dismiss_stale_reviews                = true
  prevent_self_review                  = true

  # Bypass allowances for emergency fixes
  bypass_pull_request_allowances_users = ["emergency-user"]
  bypass_pull_request_allowances_teams = ["platform-team"]

  # Comprehensive status checks
  required_status_checks = [
    "Terraform / Terraform Plan and Apply / Commitlint",
    "Terraform / Terraform Plan and Apply / Terraform Format",
    "Terraform / Terraform Plan and Apply / Terraform Lint",
    "Terraform / Terraform Plan and Apply / Terraform Plan",
    "Terraform / Terraform Plan and Apply / Terraform Security",
    "Terraform / Terraform Plan and Apply / Terraform Validate",
    "Security / Security Scan",
    "Compliance / Compliance Check",
    "Performance / Performance Test"
  ]

  # Multiple environments with reviewers
  repository_environments          = ["dev", "staging", "production"]
  default_environment_review_users = ["senior-dev1", "senior-dev2"]
  default_environment_review_teams = ["platform-team", "security-team"]

  # Enterprise topics
  repository_topics = ["enterprise", "terraform", "aws", "critical", "compliance"]

  # Specific collaborators with different permissions
  repository_collaborators = [
    {
      username   = "senior-dev1"
      permission = "admin"
    },
    {
      username   = "senior-dev2"
      permission = "admin"
    },
    {
      username   = "junior-dev1"
      permission = "write"
    },
    {
      username   = "junior-dev2"
      permission = "write"
    }
  ]
}
