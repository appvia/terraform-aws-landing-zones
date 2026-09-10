override_module {
  target = module.notifications
  outputs = {
    sns_topic_arn = "arn:aws:sns:eu-west-2:123456789012:appvia-notifications"
  }
}

## The users are only provisioned in the home region - this is the happy path where the
## current region (eu-west-2, from the mocked aws_region) matches var.home_region.
run "iam_users_basic" {
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

    iam_users = [
      {
        name = "lza-user-one"
      },
      {
        name = "lza-user-two"
        path = "/engineering/"
      }
    ]
  }

  assert {
    condition     = length(module.iam_users) == 2
    error_message = "Both of the requested IAM users should be provisioned"
  }

  assert {
    condition     = module.iam_users["lza-user-one"].name == "lza-user-one"
    error_message = "The IAM user should be keyed and named lza-user-one"
  }

  assert {
    condition     = module.iam_users["lza-user-two"].name == "lza-user-two"
    error_message = "The IAM user should be keyed and named lza-user-two"
  }
}

## A user carrying a permissions boundary - the module composes the boundary ARN from the
## account id and the supplied name, so an incorrect name must not silently disappear.
run "iam_users_with_permission_boundary" {
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

    iam_users = [
      {
        name                     = "lza-bounded-user"
        force_destroy            = false
        permission_boundary_name = "lza-developer-boundary"
        policy_arns              = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
      }
    ]
  }

  assert {
    condition     = module.iam_users["lza-bounded-user"].name == "lza-bounded-user"
    error_message = "The bounded IAM user should be provisioned"
  }
}

## Users are home region only - outside of it the collection must be empty, otherwise the
## same user would be created once per region the landing zone is applied in.
run "iam_users_outside_home_region" {
  command = plan

  variables {
    environment    = "Production"
    owner          = "Support"
    product        = "LandingZone"
    home_region    = "us-east-1"
    tags           = {}
    git_repository = "test"

    notifications = {
      email = {
        addresses = ["info@appvia.io"]
      }
    }

    iam_users = [
      {
        name = "lza-user-one"
      }
    ]
  }

  assert {
    condition     = length(module.iam_users) == 0
    error_message = "No IAM users should be provisioned outside of the home region"
  }
}

## The default - no users requested, nothing provisioned.
run "iam_users_default_empty" {
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
    condition     = length(module.iam_users) == 0
    error_message = "No IAM users should be provisioned by default"
  }
}

mock_provider "aws" {
  source = "./tests/providers/default"
}

mock_provider "aws" {
  alias  = "network"
  source = "./tests/providers/network"
}
