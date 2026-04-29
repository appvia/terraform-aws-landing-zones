# CloudWatch Configuration Tests
# This file contains comprehensive tests for the CloudWatch features:
# - Cross-Account Observability (sink and source)
# - Account-level subscription filter policies

# Override the notifications module to provide a mock SNS topic
override_module {
  target = module.notifications
  outputs = {
    sns_topic_arn = "arn:aws:sns:eu-west-2:123456789012:appvia-notifications"
  }
}

# Test 1: CloudWatch observability sink enabled
run "cloudwatch_observability_sink_enabled" {
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

    cloudwatch = {
      observability_sink = {
        enable      = true
        identifiers = ["arn:aws:iam::111111111111:root", "arn:aws:iam::222222222222:root"]
        resource_types = [
          "AWS::CloudWatch::Metric",
          "AWS::Logs::LogGroup",
          "AWS::XRay::Trace",
        ]
      }
      observability_source  = null
      account_subscriptions = {}
    }
  }

  # Test that OAM sink is created when enabled with identifiers
  assert {
    condition     = length(aws_oam_sink.observability_sink) == 1
    error_message = "OAM observability sink should be created when enable=true and identifiers are provided"
  }

  # Test that sink has correct name
  assert {
    condition     = aws_oam_sink.observability_sink[0].name == "observability-sink"
    error_message = "OAM sink should have name 'observability-sink'"
  }

  # Test that sink policy is created
  assert {
    condition     = length(aws_oam_sink_policy.observability_sink) == 1
    error_message = "OAM sink policy should be created when sink is enabled"
  }

  # Test that observability source is not created
  assert {
    condition     = length(aws_oam_link.cloudwatch_cao) == 0
    error_message = "OAM link (observability source) should not be created when observability_source is null"
  }
}

# Test 2: CloudWatch observability sink disabled (no identifiers)
run "cloudwatch_observability_sink_disabled_no_identifiers" {
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

    cloudwatch = {
      observability_sink = {
        enable      = true
        identifiers = []
      }
      observability_source  = null
      account_subscriptions = {}
    }
  }

  # Test that OAM sink is NOT created when identifiers is empty
  assert {
    condition     = length(aws_oam_sink.observability_sink) == 0
    error_message = "OAM observability sink should not be created when identifiers is empty"
  }

  assert {
    condition     = length(aws_oam_sink_policy.observability_sink) == 0
    error_message = "OAM sink policy should not be created when sink is disabled"
  }
}

# Test 3: CloudWatch observability sink disabled (enable=false)
run "cloudwatch_observability_sink_disabled" {
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

    cloudwatch = {
      observability_sink = {
        enable      = false
        identifiers = ["arn:aws:iam::111111111111:root"]
      }
      observability_source  = null
      account_subscriptions = {}
    }
  }

  # Test that OAM sink is NOT created when enable=false
  assert {
    condition     = length(aws_oam_sink.observability_sink) == 0
    error_message = "OAM observability sink should not be created when enable is false"
  }
}

# Test 4: CloudWatch observability sink with organization_id restriction
run "cloudwatch_observability_sink_with_organization" {
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

    cloudwatch = {
      observability_sink = {
        enable          = true
        identifiers     = ["arn:aws:iam::111111111111:root"]
        organization_id = "o-xxxxxxxxxx"
        resource_types  = ["AWS::CloudWatch::Metric", "AWS::Logs::LogGroup"]
      }
      observability_source  = null
      account_subscriptions = {}
    }
  }

  # Test that sink is created with organization restriction
  assert {
    condition     = length(aws_oam_sink.observability_sink) == 1
    error_message = "OAM sink should be created when enable=true with organization_id"
  }

  # Test that sink policy references the sink
  assert {
    condition     = length(aws_oam_sink_policy.observability_sink) == 1
    error_message = "OAM sink policy should be created"
  }
}

# Test 5: CloudWatch observability source enabled
run "cloudwatch_observability_source_enabled" {
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

    cloudwatch = {
      observability_sink = null
      observability_source = {
        enable          = true
        account_id      = "999999999999"
        sink_identifier = "arn:aws:oam:eu-west-2:999999999999:sink/abcd1234-1234-1234-1234-123456789012"
        resource_types = [
          "AWS::CloudWatch::Metric",
          "AWS::Logs::LogGroup",
          "AWS::XRay::Trace",
        ]
      }
      account_subscriptions = {}
    }
  }

  # Test that observability source IAM role module is created
  assert {
    condition     = length(module.observability_source) == 1
    error_message = "Observability source IAM role module should be created when enable=true and account_id is set"
  }

  # Test that OAM link is created
  assert {
    condition     = length(aws_oam_link.cloudwatch_cao) == 1
    error_message = "OAM CloudWatch CAO link should be created when observability source is enabled"
  }

  # Test that OAM link has correct sink identifier
  assert {
    condition     = aws_oam_link.cloudwatch_cao[0].sink_identifier == "arn:aws:oam:eu-west-2:999999999999:sink/abcd1234-1234-1234-1234-123456789012"
    error_message = "OAM link should have correct sink_identifier"
  }

  # Test that OAM link has correct label template
  assert {
    condition     = aws_oam_link.cloudwatch_cao[0].label_template == "$AccountName"
    error_message = "OAM link should have label_template $AccountName"
  }
}

# Test 6: CloudWatch observability source disabled (no account_id)
run "cloudwatch_observability_source_disabled_no_account_id" {
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

    cloudwatch = {
      observability_sink = null
      observability_source = {
        enable          = true
        account_id      = null
        sink_identifier = "arn:aws:oam:eu-west-2:999999999999:sink/abcd1234"
      }
      account_subscriptions = {}
    }
  }

  # Test that observability source is NOT created when account_id is null
  assert {
    condition     = length(module.observability_source) == 0
    error_message = "Observability source should not be created when account_id is null"
  }

  assert {
    condition     = length(aws_oam_link.cloudwatch_cao) == 0
    error_message = "OAM link should not be created when observability source is disabled"
  }
}

# Test 7: CloudWatch observability source disabled (enable=false)
run "cloudwatch_observability_source_disabled" {
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

    cloudwatch = {
      observability_sink = null
      observability_source = {
        enable          = false
        account_id      = "999999999999"
        sink_identifier = "arn:aws:oam:eu-west-2:999999999999:sink/abcd1234"
      }
      account_subscriptions = {}
    }
  }

  # Test that observability source is NOT created when enable=false
  assert {
    condition     = length(module.observability_source) == 0
    error_message = "Observability source should not be created when enable is false"
  }

  assert {
    condition     = length(aws_oam_link.cloudwatch_cao) == 0
    error_message = "OAM link should not be created when enable is false"
  }
}

# Test 8: CloudWatch account subscriptions
run "cloudwatch_account_subscriptions" {
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

    cloudwatch = {
      observability_sink   = null
      observability_source = null
      account_subscriptions = {
        "kinesis-destination" = {
          policy             = "{\"SourceAccount\": \"123456789012\", \"DestinationArn\": \"arn:aws:logs:eu-west-2:111111111111:destination:kinesis\", \"FilterName\": \"\"}"
          selection_criteria = "ALL"
        }
        "lambda-destination" = {
          policy             = "{\"SourceAccount\": \"123456789012\", \"DestinationArn\": \"arn:aws:lambda:eu-west-2:111111111111:function:log-processor\", \"FilterName\": \"\"}"
          selection_criteria = "ALL"
        }
      }
    }
  }

  # Test that account subscription policies are created for each entry
  assert {
    condition     = length(aws_cloudwatch_log_account_policy.cloudwatch_subscriptions) == 2
    error_message = "Two CloudWatch account subscription policies should be created"
  }

  # Test that kinesis subscription has correct policy name
  assert {
    condition     = aws_cloudwatch_log_account_policy.cloudwatch_subscriptions["kinesis-destination"].policy_name == "lz-subscription-kinesis-destination"
    error_message = "Account subscription policy name should use lz-subscription- prefix"
  }

  # Test that subscription has correct policy type
  assert {
    condition     = aws_cloudwatch_log_account_policy.cloudwatch_subscriptions["kinesis-destination"].policy_type == "SUBSCRIPTION_FILTER_POLICY"
    error_message = "Account subscription should have policy_type SUBSCRIPTION_FILTER_POLICY"
  }

  # Test that subscription has correct scope
  assert {
    condition     = aws_cloudwatch_log_account_policy.cloudwatch_subscriptions["kinesis-destination"].scope == "ALL"
    error_message = "Account subscription should have scope ALL"
  }
}

# Test 9: CloudWatch default (all disabled)
run "cloudwatch_default_disabled" {
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

    # Use default cloudwatch config (observability_sink=null, observability_source=null, account_subscriptions={})
    cloudwatch = {
      account_subscriptions = {}
      observability_sink    = null
      observability_source  = null
    }
  }

  # Test that no OAM sink is created
  assert {
    condition     = length(aws_oam_sink.observability_sink) == 0
    error_message = "OAM sink should not be created with default config"
  }

  # Test that no observability source is created
  assert {
    condition     = length(module.observability_source) == 0
    error_message = "Observability source should not be created with default config"
  }

  # Test that no OAM link is created
  assert {
    condition     = length(aws_oam_link.cloudwatch_cao) == 0
    error_message = "OAM link should not be created with default config"
  }

  # Test that no account subscriptions are created
  assert {
    condition     = length(aws_cloudwatch_log_account_policy.cloudwatch_subscriptions) == 0
    error_message = "Account subscriptions should not be created with empty account_subscriptions"
  }
}

# Test 10: CloudWatch combined sink and source
run "cloudwatch_combined_sink_and_source" {
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

    cloudwatch = {
      observability_sink = {
        enable         = true
        identifiers    = ["arn:aws:iam::111111111111:root"]
        resource_types = ["AWS::CloudWatch::Metric", "AWS::Logs::LogGroup", "AWS::XRay::Trace"]
      }
      observability_source = {
        enable          = true
        account_id      = "888888888888"
        sink_identifier = "arn:aws:oam:eu-west-2:888888888888:sink/sink-12345"
        resource_types  = ["AWS::CloudWatch::Metric", "AWS::Logs::LogGroup", "AWS::XRay::Trace"]
      }
      account_subscriptions = {
        "test-sub" = {
          policy             = "{\"SourceAccount\": \"123456789012\"}"
          selection_criteria = "ALL"
        }
      }
    }
  }

  # Test that both sink and source can be configured (in different accounts typically)
  assert {
    condition     = length(aws_oam_sink.observability_sink) == 1
    error_message = "OAM sink should be created"
  }

  assert {
    condition     = length(aws_oam_link.cloudwatch_cao) == 1
    error_message = "OAM link should be created"
  }

  assert {
    condition     = length(aws_cloudwatch_log_account_policy.cloudwatch_subscriptions) == 1
    error_message = "Account subscription policy should be created"
  }
}

# Mock providers
mock_provider "aws" {
  source = "./tests/providers/default"
}

mock_provider "aws" {
  alias  = "network"
  source = "./tests/providers/network"
}
