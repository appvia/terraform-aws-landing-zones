
override_module {
  target = module.notifications
  outputs = {
    sns_topic_arn = "arn:aws:sns:eu-west-2:123456789012:appvia-notifications"
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

    ebs_encryption = {
      enable                      = true
      create_kms_key              = true
      key_deletion_window_in_days = 10
      key_alias                   = "lza/ebs/default"
      key_arn                     = null
    }
  }

  assert {
    condition     = aws_ebs_default_kms_key.default[0] != null
    error_message = "The EBS default KMS key should be created"
  }

  assert {
    condition     = aws_ebs_encryption_by_default.default[0].enabled == true
    error_message = "The EBS encryption should be enabled"
  }

  assert {
    condition     = module.ebs_kms[0] != null
    error_message = "The EBS KMS key should be created"
  }
}

mock_provider "aws" {}

mock_provider "aws" {
  alias  = "tenant"
  source = "./tests/providers/tenant"
}

mock_provider "aws" {
  alias  = "management"
  source = "./tests/providers/management"
}

mock_provider "aws" {
  alias  = "identity"
  source = "./tests/providers/identity"
}

mock_provider "aws" {
  alias  = "network"
  source = "./tests/providers/network"
}
