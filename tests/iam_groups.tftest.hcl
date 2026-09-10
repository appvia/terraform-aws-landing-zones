override_module {
  target = module.notifications
  outputs = {
    sns_topic_arn = "arn:aws:sns:eu-west-2:123456789012:appvia-notifications"
  }
}

## A group with members and additional managed policies attached. The policies field is a
## map of name => arn and is passed straight through to the upstream module.
run "iam_groups_basic" {
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
      }
    ]

    iam_groups = [
      {
        name  = "lza-engineering"
        users = ["lza-user-one", "lza-user-two"]
        policies = {
          "ReadOnlyAccess" = "arn:aws:iam::aws:policy/ReadOnlyAccess"
        }
      }
    ]
  }

  assert {
    condition     = length(module.iam_groups) == 1
    error_message = "The requested IAM group should be provisioned"
  }

  assert {
    condition     = module.iam_groups["lza-engineering"].name == "lza-engineering"
    error_message = "The IAM group should be keyed and named lza-engineering"
  }

  assert {
    condition     = contains(module.iam_groups["lza-engineering"].users, "lza-user-one")
    error_message = "The IAM group membership should contain lza-user-one"
  }

  assert {
    condition     = contains(module.iam_groups["lza-engineering"].users, "lza-user-two")
    error_message = "The IAM group membership should contain lza-user-two"
  }
}

## A group with no members - the upstream module skips the membership resource entirely, so
## the users output collapses to an empty list rather than erroring.
run "iam_groups_without_users" {
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

    iam_groups = [
      {
        name        = "lza-empty-group"
        path        = "/engineering/"
        enforce_mfa = false
      }
    ]
  }

  assert {
    condition     = module.iam_groups["lza-empty-group"].name == "lza-empty-group"
    error_message = "The IAM group should be provisioned without any members"
  }

  assert {
    condition     = length(module.iam_groups["lza-empty-group"].users) == 0
    error_message = "The IAM group should have no members"
  }
}

## Multiple groups, to confirm the list is keyed by name and not silently collapsed.
run "iam_groups_multiple" {
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

    iam_groups = [
      {
        name = "lza-admins"
        policies = {
          "AdministratorAccess" = "arn:aws:iam::aws:policy/AdministratorAccess"
        }
      },
      {
        name = "lza-auditors"
        policies = {
          "SecurityAudit" = "arn:aws:iam::aws:policy/SecurityAudit"
        }
      }
    ]
  }

  assert {
    condition     = length(module.iam_groups) == 2
    error_message = "Both of the requested IAM groups should be provisioned"
  }

  assert {
    condition     = module.iam_groups["lza-admins"].name == "lza-admins"
    error_message = "The lza-admins group should be provisioned"
  }

  assert {
    condition     = module.iam_groups["lza-auditors"].name == "lza-auditors"
    error_message = "The lza-auditors group should be provisioned"
  }
}

## Groups are home region only - outside of it the collection must be empty.
run "iam_groups_outside_home_region" {
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

    iam_groups = [
      {
        name = "lza-engineering"
      }
    ]
  }

  assert {
    condition     = length(module.iam_groups) == 0
    error_message = "No IAM groups should be provisioned outside of the home region"
  }
}

## The default - no groups requested, nothing provisioned.
run "iam_groups_default_empty" {
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
    condition     = length(module.iam_groups) == 0
    error_message = "No IAM groups should be provisioned by default"
  }
}

mock_provider "aws" {
  source = "./tests/providers/default"
}

mock_provider "aws" {
  alias  = "network"
  source = "./tests/providers/network"
}
