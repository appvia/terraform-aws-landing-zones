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

run "caller_tags_are_not_overridden_by_null_tagging_values" {
  command = plan

  variables {
    environment    = "Production"
    owner          = "Support"
    product        = "LandingZone"
    home_region    = "eu-west-2"
    git_repository = "test"

    tags = {
      Application = "LandingZone"
      Team        = "Platform"
    }

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

  assert {
    condition     = local.tags["Application"] == "LandingZone"
    error_message = "The Application tag supplied by the caller must be preserved"
  }

  assert {
    condition     = local.tags["Team"] == "Platform"
    error_message = "The Team tag supplied by the caller must be preserved"
  }

  assert {
    condition     = alltrue([for k, v in local.tags : v != null])
    error_message = "The tags must not contain null values"
  }
}

mock_provider "aws" {
  source = "./tests/providers/default"
}

mock_provider "aws" {
  alias  = "network"
  source = "./tests/providers/network"
}
