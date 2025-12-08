# GuardDuty Configuration Tests
# This file contains comprehensive tests for the GuardDuty configuration

# Override the notifications module to provide a mock SNS topic
override_module {
  target = module.notifications
  outputs = {
    sns_topic_arn = "arn:aws:sns:eu-west-2:123456789012:appvia-notifications"
  }
}

# Test 1: GuardDuty with existing detector (lookup mode)
run "guardduty_existing_detector" {
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

    guardduty = {
      create                       = false
      finding_publishing_frequency = "FIFTEEN_MINUTES"
    }
  }

  # Test that GuardDuty data source is used when create is false
  assert {
    condition     = length(data.aws_guardduty_detector.guardduty) == 1
    error_message = "GuardDuty detector data source should be used when create is false"
  }

  # Test that GuardDuty detector resource is not created
  assert {
    condition     = length(aws_guardduty_detector.guardduty) == 0
    error_message = "GuardDuty detector resource should not be created when create is false"
  }
}

# Test 2: GuardDuty with new detector creation
run "guardduty_create_detector" {
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

    guardduty = {
      create                       = true
      finding_publishing_frequency = "FIFTEEN_MINUTES"
    }
  }

  # Test that GuardDuty detector resource is created
  assert {
    condition     = length(aws_guardduty_detector.guardduty) == 1
    error_message = "GuardDuty detector resource should be created when create is true"
  }

  # Test that GuardDuty detector is enabled
  assert {
    condition     = aws_guardduty_detector.guardduty[0].enable == true
    error_message = "GuardDuty detector should be enabled"
  }

  # Test that GuardDuty data source is not used when creating
  assert {
    condition     = length(data.aws_guardduty_detector.guardduty) == 0
    error_message = "GuardDuty detector data source should not be used when create is true"
  }

  # Test that detector has proper tags
  assert {
    condition     = aws_guardduty_detector.guardduty[0].tags["Name"] == "guardduty-detector"
    error_message = "GuardDuty detector should have Name tag set to 'guardduty-detector'"
  }
}

# Test 3: GuardDuty with detector features enabled
run "guardduty_with_detector_features" {
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

    guardduty = {
      create                       = true
      finding_publishing_frequency = "FIFTEEN_MINUTES"
      detectors = [
        {
          name                     = "S3_DATA_EVENTS"
          enable                   = true
          additional_configuration = []
        },
        {
          name                     = "EKS_AUDIT_LOGS"
          enable                   = true
          additional_configuration = []
        },
        {
          name                     = "RDS_LOGIN_EVENTS"
          enable                   = false
          additional_configuration = []
        }
      ]
    }
  }

  # Test that detector features are created
  assert {
    condition     = length(aws_guardduty_detector_feature.detectors) == 3
    error_message = "Three GuardDuty detector features should be created"
  }

  # Test that S3_DATA_EVENTS is enabled
  assert {
    condition     = aws_guardduty_detector_feature.detectors["S3_DATA_EVENTS"].status == "ENABLED"
    error_message = "S3_DATA_EVENTS detector feature should be enabled"
  }

  # Test that EKS_AUDIT_LOGS is enabled
  assert {
    condition     = aws_guardduty_detector_feature.detectors["EKS_AUDIT_LOGS"].status == "ENABLED"
    error_message = "EKS_AUDIT_LOGS detector feature should be enabled"
  }

  # Test that RDS_LOGIN_EVENTS is disabled
  assert {
    condition     = aws_guardduty_detector_feature.detectors["RDS_LOGIN_EVENTS"].status == "DISABLED"
    error_message = "RDS_LOGIN_EVENTS detector feature should be disabled"
  }
}

# Test 4: GuardDuty with detector features and additional configuration
run "guardduty_with_additional_configuration" {
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

    guardduty = {
      create                       = true
      finding_publishing_frequency = "FIFTEEN_MINUTES"
      detectors = [
        {
          name   = "EKS_AUDIT_LOGS"
          enable = true
          additional_configuration = [
            {
              name   = "EKS_ADDON_MANAGEMENT"
              enable = true
            }
          ]
        }
      ]
    }
  }

  # Test that detector feature with additional configuration is created
  assert {
    condition     = aws_guardduty_detector_feature.detectors["EKS_AUDIT_LOGS"] != null
    error_message = "EKS_AUDIT_LOGS detector feature should be created"
  }

  # Test that additional configuration is present
  assert {
    condition     = length(aws_guardduty_detector_feature.detectors["EKS_AUDIT_LOGS"].additional_configuration) > 0
    error_message = "EKS_AUDIT_LOGS should have additional configuration"
  }
}

# Test 5: GuardDuty with filters
run "guardduty_with_filters" {
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

    guardduty = {
      create                       = true
      finding_publishing_frequency = "FIFTEEN_MINUTES"
      filters = {
        "low-severity-filter" = {
          action      = "ARCHIVE"
          rank        = 1
          description = "Archive low severity findings"
          criterion = [
            {
              field                 = "severity"
              less_than             = "4"
              equals                = null
              not_equals            = null
              greater_than          = null
              greater_than_or_equal = null
              less_than_or_equal    = null
            }
          ]
        }
        "high-severity-filter" = {
          action      = "NOOP"
          rank        = 2
          description = "Flag high severity findings"
          criterion = [
            {
              field                 = "severity"
              greater_than_or_equal = "7"
              equals                = null
              not_equals            = null
              greater_than          = null
              less_than             = null
              less_than_or_equal    = null
            }
          ]
        }
      }
    }
  }

  # Test that filters are created
  assert {
    condition     = length(aws_guardduty_filter.filters) == 2
    error_message = "Two GuardDuty filters should be created"
  }

  # Test that low-severity filter has correct action
  assert {
    condition     = aws_guardduty_filter.filters["low-severity-filter"].action == "ARCHIVE"
    error_message = "Low severity filter should have ARCHIVE action"
  }

  # Test that low-severity filter has correct rank
  assert {
    condition     = aws_guardduty_filter.filters["low-severity-filter"].rank == 1
    error_message = "Low severity filter should have rank 1"
  }

  # Test that high-severity filter has correct action
  assert {
    condition     = aws_guardduty_filter.filters["high-severity-filter"].action == "NOOP"
    error_message = "High severity filter should have NOOP action"
  }

  # Test that high-severity filter has correct rank
  assert {
    condition     = aws_guardduty_filter.filters["high-severity-filter"].rank == 2
    error_message = "High severity filter should have rank 2"
  }
}

# Test 6: GuardDuty disabled (null configuration)
run "guardduty_disabled" {
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

    guardduty = null
  }

  # Test that no GuardDuty detector is created
  assert {
    condition     = length(aws_guardduty_detector.guardduty) == 0
    error_message = "GuardDuty detector should not be created when guardduty is null"
  }

  # Test that no GuardDuty data source is used
  assert {
    condition     = length(data.aws_guardduty_detector.guardduty) == 0
    error_message = "GuardDuty detector data source should not be used when guardduty is null"
  }

  # Test that no detector features are created
  assert {
    condition     = length(aws_guardduty_detector_feature.detectors) == 0
    error_message = "No GuardDuty detector features should be created when guardduty is null"
  }

  # Test that no filters are created
  assert {
    condition     = length(aws_guardduty_filter.filters) == 0
    error_message = "No GuardDuty filters should be created when guardduty is null"
  }
}

# Test 7: GuardDuty with comprehensive configuration (create mode)
run "guardduty_comprehensive_create" {
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

    guardduty = {
      create                       = true
      finding_publishing_frequency = "FIFTEEN_MINUTES"
      detectors = [
        {
          name   = "S3_DATA_EVENTS"
          enable = true
          additional_configuration = []
        },
        {
          name   = "EKS_AUDIT_LOGS"
          enable = true
          additional_configuration = [
            {
              name   = "EKS_ADDON_MANAGEMENT"
              enable = true
            }
          ]
        }
      ]
      filters = {
        "test-filter" = {
          action      = "ARCHIVE"
          rank        = 1
          description = "Test filter"
          criterion = [
            {
              field                 = "severity"
              less_than             = "4"
              equals                = null
              not_equals            = null
              greater_than          = null
              greater_than_or_equal = null
              less_than_or_equal    = null
            }
          ]
        }
      }
    }
  }

  # Test that GuardDuty detector is created
  assert {
    condition     = length(aws_guardduty_detector.guardduty) == 1
    error_message = "GuardDuty detector should be created"
  }

  # Test that detector features are created
  assert {
    condition     = length(aws_guardduty_detector_feature.detectors) == 2
    error_message = "Two GuardDuty detector features should be created"
  }

  # Test that filters are created
  assert {
    condition     = length(aws_guardduty_filter.filters) == 1
    error_message = "One GuardDuty filter should be created"
  }

  # Test that all resources reference the created detector
  assert {
    condition     = aws_guardduty_detector.guardduty[0].enable == true
    error_message = "GuardDuty detector should be enabled"
  }
}

# Test 8: GuardDuty with comprehensive configuration (lookup mode)
run "guardduty_comprehensive_lookup" {
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

    guardduty = {
      create                       = false
      finding_publishing_frequency = "FIFTEEN_MINUTES"
      detectors = [
        {
          name   = "S3_DATA_EVENTS"
          enable = true
          additional_configuration = []
        }
      ]
      filters = {
        "existing-detector-filter" = {
          action      = "NOOP"
          rank        = 1
          description = "Filter for existing detector"
          criterion = [
            {
              field                 = "type"
              equals                = "Recon:EC2/PortProbeUnprotectedPort"
              not_equals            = null
              greater_than          = null
              greater_than_or_equal = null
              less_than             = null
              less_than_or_equal    = null
            }
          ]
        }
      }
    }
  }

  # Test that GuardDuty data source is used
  assert {
    condition     = length(data.aws_guardduty_detector.guardduty) == 1
    error_message = "GuardDuty detector data source should be used when create is false"
  }

  # Test that GuardDuty detector is not created
  assert {
    condition     = length(aws_guardduty_detector.guardduty) == 0
    error_message = "GuardDuty detector should not be created when create is false"
  }

  # Test that detector features are created for existing detector
  assert {
    condition     = length(aws_guardduty_detector_feature.detectors) == 1
    error_message = "One GuardDuty detector feature should be created"
  }

  # Test that filters are created for existing detector
  assert {
    condition     = length(aws_guardduty_filter.filters) == 1
    error_message = "One GuardDuty filter should be created"
  }
}

# Mock providers
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
