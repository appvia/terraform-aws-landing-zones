override_module {
  target = module.notifications
  outputs = {
    sns_topic_arn = "arn:aws:sns:eu-west-2:123456789012:appvia-notifications"
  }
}

override_module {
  target = module.kms_key_administrator
  outputs = {
    role_arn = "arn:aws:iam::123456789012:role/appvia-kms-key-administrator"
    key_arn  = "arn:aws:kms:eu-west-2:123456789012:key/12345678-1234-1234-1234-123456789012"
    key_id   = "12345678-1234-1234-1234-123456789012"
  }
}

run "basic" {
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

    kms_administrator = {
      enable              = true
      enable_account_root = true
    }
  }
}

mock_provider "aws" {}

mock_provider "aws" {
  alias  = "tenant"
  source = "./tests/providers/tenant"
}

mock_provider "aws" {
  alias  = "network"
  source = "./tests/providers/network"
}
