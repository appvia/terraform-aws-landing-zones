override_module {
  target = module.notifications
  outputs = {
    sns_topic_arn = "arn:aws:sns:eu-west-2:123456789012:appvia-notifications"
  }
}

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

## The access analyzer role is opt-in and must not be created by default
run "access_analyzer_role_disabled_by_default" {
  command = plan

  assert {
    condition     = length(module.access_analyzer_iam_role) == 0
    error_message = "The access analyzer role should not be created unless enabled"
  }
}

## Enabling the role with valid bucket and key ARNs provisions it
run "access_analyzer_role_enabled" {
  command = plan

  variables {
    include_iam_roles = {
      access_analyzer = {
        enable          = true
        logs_bucket_arn = "arn:aws:s3:::cloudtrail-logs"
        kms_key_arn     = "arn:aws:kms:eu-west-2:123456789012:key/00000000-0000-0000-0000-000000000000"
      }
    }
  }

  assert {
    condition     = length(module.access_analyzer_iam_role) == 1
    error_message = "The access analyzer role should be created when enabled"
  }
}

## A caller supplied role name is accepted
run "access_analyzer_role_custom_name" {
  command = plan

  variables {
    include_iam_roles = {
      access_analyzer = {
        enable          = true
        name            = "custom-access-analyzer"
        logs_bucket_arn = "arn:aws:s3:::cloudtrail-logs"
        kms_key_arn     = "arn:aws:kms:eu-west-2:123456789012:key/00000000-0000-0000-0000-000000000000"
      }
    }
  }

  assert {
    condition     = length(module.access_analyzer_iam_role) == 1
    error_message = "The access analyzer role should be created with a caller supplied name"
  }
}

## Non-commercial partitions are accepted by the ARN validation
run "access_analyzer_role_govcloud_partition" {
  command = plan

  variables {
    include_iam_roles = {
      access_analyzer = {
        enable          = true
        logs_bucket_arn = "arn:aws-us-gov:s3:::cloudtrail-logs"
        kms_key_arn     = "arn:aws-us-gov:kms:us-gov-west-1:123456789012:key/00000000-0000-0000-0000-000000000000"
      }
    }
  }

  assert {
    condition     = length(module.access_analyzer_iam_role) == 1
    error_message = "The access analyzer role should accept non-commercial partition ARNs"
  }
}

## The role is only provisioned within the home region
run "access_analyzer_role_outside_home_region" {
  command = plan

  variables {
    home_region = "us-east-1"
    include_iam_roles = {
      access_analyzer = {
        enable          = true
        logs_bucket_arn = "arn:aws:s3:::cloudtrail-logs"
        kms_key_arn     = "arn:aws:kms:eu-west-2:123456789012:key/00000000-0000-0000-0000-000000000000"
      }
    }
  }

  assert {
    condition     = length(module.access_analyzer_iam_role) == 0
    error_message = "The access analyzer role should only be created in the home region"
  }
}

## Enabling the role without the bucket and key ARNs is rejected
run "access_analyzer_role_missing_arns" {
  command = plan

  variables {
    include_iam_roles = {
      access_analyzer = {
        enable = true
      }
    }
  }

  expect_failures = [
    var.include_iam_roles,
  ]
}

## A bucket object ARN rather than a bucket ARN is rejected
run "access_analyzer_role_invalid_bucket_arn" {
  command = plan

  variables {
    include_iam_roles = {
      access_analyzer = {
        enable          = true
        logs_bucket_arn = "arn:aws:s3:::cloudtrail-logs/AWSLogs"
        kms_key_arn     = "arn:aws:kms:eu-west-2:123456789012:key/00000000-0000-0000-0000-000000000000"
      }
    }
  }

  expect_failures = [
    var.include_iam_roles,
  ]
}

## A non KMS ARN for the key is rejected
run "access_analyzer_role_invalid_kms_arn" {
  command = plan

  variables {
    include_iam_roles = {
      access_analyzer = {
        enable          = true
        logs_bucket_arn = "arn:aws:s3:::cloudtrail-logs"
        kms_key_arn     = "arn:aws:s3:::not-a-key"
      }
    }
  }

  expect_failures = [
    var.include_iam_roles,
  ]
}

mock_provider "aws" {
  source = "./tests/providers/default"
}

mock_provider "aws" {
  alias  = "network"
  source = "./tests/providers/network"
}
