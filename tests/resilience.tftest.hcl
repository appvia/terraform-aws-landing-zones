# Resilience Hub Configuration Tests
# This file contains comprehensive tests for the AWS Resilience Hub configuration

# Override the notifications module to provide a mock SNS topic
override_module {
  target = module.notifications
  outputs = {
    sns_topic_arn = "arn:aws:sns:eu-west-2:123456789012:appvia-notifications"
  }
}

# Test 1: Basic resilience hub enablement (should create IAM role in home region)
run "basic_resilience_hub_enabled" {
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

    resilience_hub = {
      enable = true
    }
  }

  # Test that IAM role module is created when enabled in home region
  assert {
    condition     = length(module.resilience_hub_iam_role) == 1
    error_message = "Resilience Hub IAM role module should be created when enabled in home region"
  }
}

# Test 2: Resilience hub disabled (should not create IAM role)
run "resilience_hub_disabled" {
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

    include_iam_roles = {
      ssm_instance = {
        enable = true
        name   = "lza-ssm-instance"
      }
    }

    resilience_hub = {
      enable = false
    }
  }

  # Test that IAM role module is not created when disabled
  assert {
    condition     = length(module.resilience_hub_iam_role) == 0
    error_message = "Resilience Hub IAM role module should not be created when disabled"
  }

  # Test that no policies are created when disabled
  assert {
    condition     = length(aws_resiliencehub_resiliency_policy.policies) == 0
    error_message = "Resilience Hub policies should not be created when disabled"
  }
}

# Test 3: Resilience hub with single policy
run "resilience_hub_with_single_policy" {
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

    include_iam_roles = {
      ssm_instance = {
        enable = true
        name   = "lza-ssm-instance"
      }
    }

    resilience_hub = {
      enable = true
      policies = {
        "production-policy" = {
          name        = "production-application-policy"
          description = "Resiliency policy for production applications"
          tier        = "Critical"
          policy = {
            region = {
              rpo = "1h"
              rto = "4h"
            }
            hardware = {
              rpo = "15m"
              rto = "1h"
            }
            software = {
              rpo = "30m"
              rto = "2h"
            }
            az = {
              rpo = "1h"
              rto = "4h"
            }
          }
        }
      }
    }
  }

  # Test that IAM role module is created
  assert {
    condition     = length(module.resilience_hub_iam_role) == 1
    error_message = "Resilience Hub IAM role module should be created"
  }

  # Test that policy resource is created
  assert {
    condition     = aws_resiliencehub_resiliency_policy.policies["production-policy"] != null
    error_message = "Resilience Hub policy should be created"
  }

  # Test that policy has correct name
  assert {
    condition     = aws_resiliencehub_resiliency_policy.policies["production-policy"].name == "production-application-policy"
    error_message = "Policy should have the correct name"
  }

  # Test that policy has correct tier
  assert {
    condition     = aws_resiliencehub_resiliency_policy.policies["production-policy"].tier == "Critical"
    error_message = "Policy should have the correct tier"
  }

  # Test that policy has correct description
  assert {
    condition     = aws_resiliencehub_resiliency_policy.policies["production-policy"].description == "Resiliency policy for production applications"
    error_message = "Policy should have the correct description"
  }
}

# Test 4: Resilience hub with multiple policies
run "resilience_hub_with_multiple_policies" {
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

    include_iam_roles = {
      ssm_instance = {
        enable = true
        name   = "lza-ssm-instance"
      }
    }

    resilience_hub = {
      enable = true
      policies = {
        "production-policy" = {
          name        = "production-application-policy"
          description = "Resiliency policy for production applications"
          tier        = "Critical"
          policy = {
            region = {
              rpo = "1h"
              rto = "4h"
            }
            hardware = {
              rpo = "15m"
              rto = "1h"
            }
            software = {
              rpo = "30m"
              rto = "2h"
            }
            az = {
              rpo = "1h"
              rto = "4h"
            }
          }
        }
        "development-policy" = {
          name        = "development-application-policy"
          description = "Resiliency policy for development applications"
          tier        = "Important"
          policy = {
            region = {
              rpo = "24h"
              rto = "48h"
            }
            hardware = {
              rpo = "1h"
              rto = "4h"
            }
            software = {
              rpo = "2h"
              rto = "8h"
            }
            az = {
              rpo = "4h"
              rto = "12h"
            }
          }
        }
      }
    }
  }

  # Test that both policies are created
  assert {
    condition     = aws_resiliencehub_resiliency_policy.policies["production-policy"] != null
    error_message = "Production policy should be created"
  }

  assert {
    condition     = aws_resiliencehub_resiliency_policy.policies["development-policy"] != null
    error_message = "Development policy should be created"
  }

  # Test that we have exactly 2 policies
  assert {
    condition     = length(aws_resiliencehub_resiliency_policy.policies) == 2
    error_message = "Should have exactly 2 policies"
  }
}

# Test 5: Resilience hub with policy using map key as name (name not specified)
run "resilience_hub_policy_without_explicit_name" {
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

    resilience_hub = {
      enable = true
      policies = {
        "my-policy" = {
          description = "Resiliency policy without explicit name"
          tier        = "Important"
          policy = {
            region = {
              rpo = "1h"
              rto = "1h"
            }
            hardware = {
              rpo = "1h"
              rto = "1h"
            }
            software = {
              rpo = "1h"
              rto = "1h"
            }
            az = {
              rpo = "1h"
              rto = "1h"
            }
          }
        }
      }
    }
  }

  # Test that policy is created
  assert {
    condition     = aws_resiliencehub_resiliency_policy.policies["my-policy"] != null
    error_message = "Policy should be created even without explicit name"
  }
}

# Test 6: Resilience hub with different tier values
run "resilience_hub_with_different_tiers" {
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

    include_iam_roles = {
      ssm_instance = {
        enable = true
        name   = "lza-ssm-instance"
      }
    }

    resilience_hub = {
      enable = true
      policies = {
        "mission-critical" = {
          name        = "mission-critical-policy"
          description = "Mission critical application policy"
          tier        = "MissionCritical"
          policy = {
            region = {
              rpo = "15m"
              rto = "30m"
            }
            hardware = {
              rpo = "5m"
              rto = "15m"
            }
            software = {
              rpo = "10m"
              rto = "30m"
            }
            az = {
              rpo = "15m"
              rto = "30m"
            }
          }
        }
        "non-critical" = {
          name        = "non-critical-policy"
          description = "Non-critical application policy"
          tier        = "NonCritical"
          policy = {
            region = {
              rpo = "48h"
              rto = "72h"
            }
            hardware = {
              rpo = "24h"
              rto = "48h"
            }
            software = {
              rpo = "24h"
              rto = "48h"
            }
            az = {
              rpo = "24h"
              rto = "48h"
            }
          }
        }
      }
    }
  }

  # Test that both policies are created with correct tiers
  assert {
    condition     = aws_resiliencehub_resiliency_policy.policies["mission-critical"].tier == "MissionCritical"
    error_message = "Mission critical policy should have MissionCritical tier"
  }

  assert {
    condition     = aws_resiliencehub_resiliency_policy.policies["non-critical"].tier == "NonCritical"
    error_message = "Non-critical policy should have NonCritical tier"
  }
}

# Test 7: Resilience hub enabled but ssm_instance role not configured (should still work)
run "resilience_hub_without_ssm_instance_role" {
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

    resilience_hub = {
      enable = true
      policies = {
        "test-policy" = {
          name        = "test-policy"
          description = "Test policy"
          tier        = "Important"
          policy = {
            region = {
              rpo = "1h"
              rto = "1h"
            }
            hardware = {
              rpo = "1h"
              rto = "1h"
            }
            software = {
              rpo = "1h"
              rto = "1h"
            }
            az = {
              rpo = "1h"
              rto = "1h"
            }
          }
        }
      }
    }
  }

  # Test that IAM role module is still created (uses the name from include_iam_roles even if not enabled)
  assert {
    condition     = length(module.resilience_hub_iam_role) == 1
    error_message = "Resilience Hub IAM role module should be created even if ssm_instance role is not enabled"
  }

  # Test that policy is created
  assert {
    condition     = aws_resiliencehub_resiliency_policy.policies["test-policy"] != null
    error_message = "Policy should be created"
  }
}

# Test 8: Resilience hub with default tier (Important)
run "resilience_hub_with_default_tier" {
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

    resilience_hub = {
      enable = true
      policies = {
        "default-tier-policy" = {
          name        = "default-tier-policy"
          description = "Policy with default tier"
          # tier not specified, should default to "Important"
          policy = {
            region = {
              rpo = "1h"
              rto = "1h"
            }
            hardware = {
              rpo = "1h"
              rto = "1h"
            }
            software = {
              rpo = "1h"
              rto = "1h"
            }
            az = {
              rpo = "1h"
              rto = "1h"
            }
          }
        }
      }
    }
  }

  # Test that policy is created with default tier
  assert {
    condition     = aws_resiliencehub_resiliency_policy.policies["default-tier-policy"].tier == "Important"
    error_message = "Policy should have default tier of Important when not specified"
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
