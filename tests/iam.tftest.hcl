override_module {
  target = module.notifications
  outputs = {
    sns_topic_arn = "arn:aws:sns:eu-west-2:123456789012:appvia-notifications"
  }
}

## Exercises the iam_roles trust policy construction. Prior to this fixture the
## assume_services branch had no coverage anywhere in examples/ or tests/, and the
## assume_accounts / assume_roles inputs were accepted but never reached a resource.
run "iam_roles_trust_policy" {
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

    iam_roles = {
      "delegated" = {
        name            = "lza-delegated-role"
        description     = "Exercises every trust policy branch"
        assume_accounts = ["111122223333"]
        assume_roles    = ["arn:aws:iam::444455556666:role/specific"]
        assume_services = ["ec2.amazonaws.com"]
      }
    }
  }
}

## The same role with the account root trust withheld - the tightly scoped case that
## enable_account_root exists to allow.
run "iam_roles_without_account_root" {
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

    iam_roles = {
      "scoped" = {
        name                = "lza-scoped-role"
        description         = "Trusts only the nominated role principal"
        enable_account_root = false
        assume_roles        = ["arn:aws:iam::444455556666:role/specific"]
      }
    }
  }
}

mock_provider "aws" {
  source = "./tests/providers/default"
}

mock_provider "aws" {
  alias  = "network"
  source = "./tests/providers/network"
}
