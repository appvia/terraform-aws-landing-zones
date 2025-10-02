# GitHub Repository Module Tests
# This file contains comprehensive tests for the modules/github_repository module

# Mock the GitHub provider
mock_provider "github" {
  source = "./tests/providers/github"
}

# Test 1: Basic Repository Configuration
run "test_basic_repository" {
  command = plan

  module {
    source = "./modules/github_repository"
  }

  variables {
    repository  = "test-basic-repo"
    description = "A basic test repository"

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
    enable_repository_template = true
    repository_template        = "terraform-aws-pipeline-template"
    organization_template      = "appvia"

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

  # Assertions for basic repository
  assert {
    condition     = github_repository.repository.name == "test-basic-repo"
    error_message = "Repository name should be 'test-basic-repo'"
  }

  assert {
    condition     = github_repository.repository.description == "A basic test repository"
    error_message = "Repository description should match expected value"
  }

  assert {
    condition     = github_repository.repository.visibility == "private"
    error_message = "Repository visibility should be private"
  }

  assert {
    condition     = github_repository.repository.allow_merge_commit == true
    error_message = "Allow merge commit should be enabled"
  }

  assert {
    condition     = github_repository.repository.allow_rebase_merge == true
    error_message = "Allow rebase merge should be enabled"
  }

  assert {
    condition     = github_repository.repository.allow_squash_merge == true
    error_message = "Allow squash merge should be enabled"
  }

  assert {
    condition     = github_repository.repository.allow_auto_merge == false
    error_message = "Allow auto merge should be disabled"
  }

  assert {
    condition     = github_repository.repository.delete_branch_on_merge == true
    error_message = "Delete branch on merge should be enabled"
  }

  assert {
    condition     = github_repository.repository.vulnerability_alerts == true
    error_message = "Vulnerability alerts should be enabled"
  }

  assert {
    condition     = contains(github_repository.repository.topics, "terraform")
    error_message = "Repository should contain 'terraform' topic"
  }

  assert {
    condition     = contains(github_repository.repository.topics, "aws")
    error_message = "Repository should contain 'aws' topic"
  }

  assert {
    condition     = contains(github_repository.repository.topics, "infrastructure")
    error_message = "Repository should contain 'infrastructure' topic"
  }

  assert {
    condition     = contains(github_repository.repository.topics, "iac")
    error_message = "Repository should contain 'iac' topic"
  }

  # Test branch protection
  assert {
    condition     = github_branch_protection_v3.branch_protection.enforce_admins == true
    error_message = "Branch protection should enforce admins"
  }

  assert {
    condition     = github_branch_protection_v3.branch_protection.require_conversation_resolution == true
    error_message = "Branch protection should require conversation resolution"
  }

  assert {
    condition     = github_branch_protection_v3.branch_protection.require_signed_commits == true
    error_message = "Branch protection should require signed commits"
  }

  assert {
    condition     = github_branch_protection_v3.branch_protection.required_pull_request_reviews[0].dismiss_stale_reviews == true
    error_message = "Branch protection should dismiss stale reviews"
  }

  assert {
    condition     = github_branch_protection_v3.branch_protection.required_pull_request_reviews[0].required_approving_review_count == 2
    error_message = "Branch protection should require 2 approving reviews"
  }

  # Test environments
  assert {
    condition     = length(github_repository_environment.environments) == 2
    error_message = "Should create 2 environments (staging and production)"
  }

  assert {
    condition     = contains([for env in github_repository_environment.environments : env.environment], "staging")
    error_message = "Should create staging environment"
  }

  assert {
    condition     = contains([for env in github_repository_environment.environments : env.environment], "production")
    error_message = "Should create production environment"
  }

  # Test collaborators
  assert {
    condition     = length(github_repository_collaborator.collaborators) == 2
    error_message = "Should create 2 collaborators"
  }

  assert {
    condition     = contains([for collab in github_repository_collaborator.collaborators : collab.username], "developer1")
    error_message = "Should include developer1 as collaborator"
  }

  assert {
    condition     = contains([for collab in github_repository_collaborator.collaborators : collab.username], "developer2")
    error_message = "Should include developer2 as collaborator"
  }
}

# Test 2: Enterprise Repository Configuration
run "test_enterprise_repository" {
  command = plan

  module {
    source = "./modules/github_repository"
  }

  variables {
    repository  = "test-enterprise-repo"
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
    enable_repository_template = true
    repository_template        = "enterprise-terraform-template"
    organization_template      = "test-enterprise-org"

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

  # Assertions for enterprise repository
  assert {
    condition     = github_repository.repository.name == "test-enterprise-repo"
    error_message = "Repository name should be 'test-enterprise-repo'"
  }

  assert {
    condition     = github_repository.repository.description == "Enterprise critical system repository with strict controls"
    error_message = "Repository description should match expected value"
  }

  assert {
    condition     = github_repository.repository.visibility == "private"
    error_message = "Repository visibility should be private"
  }

  # Test conservative merge settings
  assert {
    condition     = github_repository.repository.allow_merge_commit == false
    error_message = "Allow merge commit should be disabled for enterprise repo"
  }

  assert {
    condition     = github_repository.repository.allow_rebase_merge == false
    error_message = "Allow rebase merge should be disabled for enterprise repo"
  }

  assert {
    condition     = github_repository.repository.allow_squash_merge == true
    error_message = "Allow squash merge should be enabled for enterprise repo"
  }

  assert {
    condition     = github_repository.repository.allow_auto_merge == false
    error_message = "Allow auto merge should be disabled for enterprise repo"
  }

  # Test enterprise topics
  assert {
    condition     = contains(github_repository.repository.topics, "enterprise")
    error_message = "Repository should contain 'enterprise' topic"
  }

  assert {
    condition     = contains(github_repository.repository.topics, "critical")
    error_message = "Repository should contain 'critical' topic"
  }

  assert {
    condition     = contains(github_repository.repository.topics, "compliance")
    error_message = "Repository should contain 'compliance' topic"
  }

  # Test strict branch protection
  assert {
    condition     = github_branch_protection_v3.branch_protection.required_pull_request_reviews[0].required_approving_review_count == 3
    error_message = "Enterprise repo should require 3 approving reviews"
  }

  assert {
    condition     = github_branch_protection_v3.branch_protection.enforce_admins == true
    error_message = "Enterprise repo should enforce admins"
  }

  # Test bypass allowances
  assert {
    condition     = contains(github_branch_protection_v3.branch_protection.required_pull_request_reviews[0].bypass_pull_request_allowances[0].users, "emergency-user")
    error_message = "Should allow emergency-user to bypass pull request requirements"
  }

  assert {
    condition     = contains(github_branch_protection_v3.branch_protection.required_pull_request_reviews[0].bypass_pull_request_allowances[0].teams, "platform-team")
    error_message = "Should allow platform-team to bypass pull request requirements"
  }

  # Test comprehensive status checks
  assert {
    condition     = contains(github_branch_protection_v3.branch_protection.required_status_checks[0].checks, "Security / Security Scan")
    error_message = "Should require security scan status check"
  }

  assert {
    condition     = contains(github_branch_protection_v3.branch_protection.required_status_checks[0].checks, "Compliance / Compliance Check")
    error_message = "Should require compliance check status check"
  }

  assert {
    condition     = contains(github_branch_protection_v3.branch_protection.required_status_checks[0].checks, "Performance / Performance Test")
    error_message = "Should require performance test status check"
  }

  # Test multiple environments
  assert {
    condition     = length(github_repository_environment.environments) == 3
    error_message = "Should create 3 environments (dev, staging, production)"
  }

  assert {
    condition     = contains([for env in github_repository_environment.environments : env.environment], "dev")
    error_message = "Should create dev environment"
  }

  assert {
    condition     = contains([for env in github_repository_environment.environments : env.environment], "staging")
    error_message = "Should create staging environment"
  }

  assert {
    condition     = contains([for env in github_repository_environment.environments : env.environment], "production")
    error_message = "Should create production environment"
  }

  # Test enterprise collaborators
  assert {
    condition     = length(github_repository_collaborator.collaborators) == 4
    error_message = "Should create 4 collaborators"
  }

  assert {
    condition     = contains([for collab in github_repository_collaborator.collaborators : collab.username], "senior-dev1")
    error_message = "Should include senior-dev1 as collaborator"
  }

  assert {
    condition     = contains([for collab in github_repository_collaborator.collaborators : collab.username], "senior-dev2")
    error_message = "Should include senior-dev2 as collaborator"
  }

  assert {
    condition     = contains([for collab in github_repository_collaborator.collaborators : collab.username], "junior-dev1")
    error_message = "Should include junior-dev1 as collaborator"
  }

  assert {
    condition     = contains([for collab in github_repository_collaborator.collaborators : collab.username], "junior-dev2")
    error_message = "Should include junior-dev2 as collaborator"
  }

  # Test admin permissions
  assert {
    condition     = contains([for collab in github_repository_collaborator.collaborators : collab.permission if collab.username == "senior-dev1"], "admin")
    error_message = "senior-dev1 should have admin permission"
  }

  assert {
    condition     = contains([for collab in github_repository_collaborator.collaborators : collab.permission if collab.username == "senior-dev2"], "admin")
    error_message = "senior-dev2 should have admin permission"
  }

  # Test write permissions
  assert {
    condition     = contains([for collab in github_repository_collaborator.collaborators : collab.permission if collab.username == "junior-dev1"], "write")
    error_message = "junior-dev1 should have write permission"
  }

  assert {
    condition     = contains([for collab in github_repository_collaborator.collaborators : collab.permission if collab.username == "junior-dev2"], "write")
    error_message = "junior-dev2 should have write permission"
  }
}

# Test 3: Public Repository Configuration
run "test_public_repository" {
  command = plan

  module {
    source = "./modules/github_repository"
  }

  variables {
    repository  = "test-public-repo"
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

    # No template for open source project
    enable_repository_template = false

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

  # Assertions for public repository
  assert {
    condition     = github_repository.repository.name == "test-public-repo"
    error_message = "Repository name should be 'test-public-repo'"
  }

  assert {
    condition     = github_repository.repository.visibility == "public"
    error_message = "Repository visibility should be public"
  }

  assert {
    condition     = github_repository.repository.allow_auto_merge == true
    error_message = "Allow auto merge should be enabled for public repo"
  }

  # Test open source topics
  assert {
    condition     = contains(github_repository.repository.topics, "open-source")
    error_message = "Repository should contain 'open-source' topic"
  }

  assert {
    condition     = contains(github_repository.repository.topics, "community")
    error_message = "Repository should contain 'community' topic"
  }

  # Test open source status checks
  assert {
    condition     = contains(github_branch_protection_v3.branch_protection.required_status_checks[0].checks, "CI / Build and Test")
    error_message = "Should require CI build and test status check"
  }

  assert {
    condition     = contains(github_branch_protection_v3.branch_protection.required_status_checks[0].checks, "Security / Security Scan")
    error_message = "Should require security scan status check"
  }

  assert {
    condition     = contains(github_branch_protection_v3.branch_protection.required_status_checks[0].checks, "Code Quality / Lint")
    error_message = "Should require code quality lint status check"
  }

  # Test no environments for open source
  assert {
    condition     = length(github_repository_environment.environments) == 0
    error_message = "Public repo should not have environments"
  }

  # Test no collaborators for open source
  assert {
    condition     = length(github_repository_collaborator.collaborators) == 0
    error_message = "Public repo should not have specific collaborators"
  }

  # Test relaxed review requirements
  assert {
    condition     = github_branch_protection_v3.branch_protection.required_pull_request_reviews[0].required_approving_review_count == 1
    error_message = "Public repo should require only 1 approving review"
  }
}
