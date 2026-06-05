override_module {
  target = module.notifications
  outputs = {
    sns_topic_arn = "arn:aws:sns:eu-west-2:123456789012:appvia-notifications"
  }
}

override_module {
  target = module.github_repository
  outputs = {
    repository_git_clone_url = "https://github.com/appvia/test-repo.git"
    repository_html_url      = "https://github.com/appvia/test-repo"
  }
}

override_module {
  target          = module.repository_permissions
  override_during = plan
  outputs = {
    read_write   = { arn = "arn:aws:iam::123456781000:role/test" }
    read_only    = { arn = "arn:aws:iam::123456781000:role/test-ro" }
    state_reader = { arn = null }
  }
}

run "infrastructure_repository_disabled" {
  command = plan

  variables {
    environment    = "Production"
    owner          = "Support"
    product        = "LandingZone"
    home_region    = "eu-west-2"
    tags           = {}
    git_repository = "test"

    notifications = {
      email = {
        addresses = ["info@appvia.io"]
      }
    }
  }

  assert {
    condition     = length(module.repository_permissions) == 0
    error_message = "Repository permissions should not be created when infrastructure_repository is null"
  }

  assert {
    condition     = length(module.github_repository) == 0
    error_message = "GitHub repository should not be created when infrastructure_repository is null"
  }

  assert {
    condition     = length(aws_iam_policy.permissions_boundary) == 0
    error_message = "Permissions boundary policy should not be created when infrastructure_repository is null"
  }
}

run "role_name_defaults_to_repository_basename" {
  command = plan

  variables {
    environment    = "Production"
    owner          = "Support"
    product        = "LandingZone"
    home_region    = "eu-west-2"
    tags           = {}
    git_repository = "test"

    notifications = {
      email = {
        addresses = ["info@appvia.io"]
      }
    }

    infrastructure_repository = {
      name   = "appvia/my-product-infrastructure"
      create = true
    }
  }

  assert {
    condition     = length(module.repository_permissions) == 1
    error_message = "Repository permissions should be created when infrastructure_repository is set"
  }

  assert {
    condition     = output.infrastructure_repository_role_name == "my-product-infrastructure"
    error_message = "IAM role name should default to the repository basename when role_name is not set"
  }
}

run "role_name_uses_explicit_value" {
  command = plan

  variables {
    environment    = "Production"
    owner          = "Support"
    product        = "LandingZone"
    home_region    = "eu-west-2"
    tags           = {}
    git_repository = "test"

    notifications = {
      email = {
        addresses = ["info@appvia.io"]
      }
    }

    infrastructure_repository = {
      name      = "appvia/my-product-infrastructure"
      role_name = "custom-deploy-role"
      create    = true
    }
  }

  assert {
    condition     = output.infrastructure_repository_role_name == "custom-deploy-role"
    error_message = "IAM role name should use the explicit role_name when provided"
  }
}

run "permissions_boundary_policy_created" {
  command = plan

  variables {
    environment    = "Production"
    owner          = "Support"
    product        = "LandingZone"
    home_region    = "eu-west-2"
    tags           = {}
    git_repository = "test"

    notifications = {
      email = {
        addresses = ["info@appvia.io"]
      }
    }

    infrastructure_repository = {
      name   = "my-product-infrastructure"
      create = true
      permissions_boundary = {
        policy = <<-EOT
          {
            "Version": "2012-10-17",
            "Statement": [
              {
                "Effect": "Allow",
                "Action": "s3:ListBucket",
                "Resource": "*"
              }
            ]
          }
        EOT
      }
    }
  }

  assert {
    condition     = length(aws_iam_policy.permissions_boundary) == 1
    error_message = "Permissions boundary policy should be created when a policy document is provided"
  }

  assert {
    condition     = startswith(aws_iam_policy.permissions_boundary[0].name_prefix, "my-product-infrastructure-boundary-")
    error_message = "Permissions boundary policy name prefix should be derived from the repository name"
  }
}

mock_provider "aws" {
  source = "./tests/providers/default"
}

mock_provider "aws" {
  alias  = "network"
  source = "./tests/providers/network"
}
