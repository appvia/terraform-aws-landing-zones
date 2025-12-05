# Service Quotas Configuration Tests
# This file contains comprehensive tests for the AWS Service Quotas configuration

# Override the notifications module to provide a mock SNS topic
override_module {
  target = module.notifications
  outputs = {
    sns_topic_arn = "arn:aws:sns:eu-west-2:123456789012:appvia-notifications"
  }
}

# Test 1: Basic service quota configuration with single quota
run "basic_service_quota" {
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

    service_quotas = [
      {
        service_code = "ec2"
        quota_code   = "L-1216C47A"
        value        = 100
      }
    ]
  }

  # Test that service quota resource is created
  assert {
    condition     = aws_servicequotas_service_quota.service_quotas["ec2-L-1216C47A"] != null
    error_message = "Service quota should be created for ec2-L-1216C47A"
  }

  # Test that service quota has correct service code
  assert {
    condition     = aws_servicequotas_service_quota.service_quotas["ec2-L-1216C47A"].service_code == "ec2"
    error_message = "Service quota should have correct service code"
  }

  # Test that service quota has correct quota code
  assert {
    condition     = aws_servicequotas_service_quota.service_quotas["ec2-L-1216C47A"].quota_code == "L-1216C47A"
    error_message = "Service quota should have correct quota code"
  }

  # Test that service quota has correct value
  assert {
    condition     = aws_servicequotas_service_quota.service_quotas["ec2-L-1216C47A"].value == 100
    error_message = "Service quota should have correct value"
  }
}

# Test 2: Service quotas disabled (empty list)
run "service_quotas_disabled" {
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

    service_quotas = []
  }

  # Test that no service quotas are created when list is empty
  assert {
    condition     = length(aws_servicequotas_service_quota.service_quotas) == 0
    error_message = "No service quotas should be created when list is empty"
  }
}

# Test 3: Multiple service quotas from different services
run "multiple_service_quotas" {
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

    service_quotas = [
      {
        service_code = "ec2"
        quota_code   = "L-1216C47A"
        value        = 100
      },
      {
        service_code = "s3"
        quota_code   = "L-89B4F0A3"
        value        = 1000
      },
      {
        service_code = "rds"
        quota_code   = "L-29A0A3C3"
        value        = 200
      }
    ]
  }

  # Test that all service quotas are created
  assert {
    condition     = aws_servicequotas_service_quota.service_quotas["ec2-L-1216C47A"] != null
    error_message = "EC2 service quota should be created"
  }

  assert {
    condition     = aws_servicequotas_service_quota.service_quotas["s3-L-89B4F0A3"] != null
    error_message = "S3 service quota should be created"
  }

  assert {
    condition     = aws_servicequotas_service_quota.service_quotas["rds-L-29A0A3C3"] != null
    error_message = "RDS service quota should be created"
  }

  # Test that we have exactly 3 service quotas
  assert {
    condition     = length(aws_servicequotas_service_quota.service_quotas) == 3
    error_message = "Should have exactly 3 service quotas"
  }

  # Test that each quota has correct values
  assert {
    condition     = aws_servicequotas_service_quota.service_quotas["ec2-L-1216C47A"].value == 100
    error_message = "EC2 quota should have value 100"
  }

  assert {
    condition     = aws_servicequotas_service_quota.service_quotas["s3-L-89B4F0A3"].value == 1000
    error_message = "S3 quota should have value 1000"
  }

  assert {
    condition     = aws_servicequotas_service_quota.service_quotas["rds-L-29A0A3C3"].value == 200
    error_message = "RDS quota should have value 200"
  }
}

# Test 4: Multiple quotas for the same service
run "multiple_quotas_same_service" {
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

    service_quotas = [
      {
        service_code = "ec2"
        quota_code   = "L-1216C47A" # Running On-Demand All G and VT instances
        value        = 100
      },
      {
        service_code = "ec2"
        quota_code   = "L-0263D0A3" # Running On-Demand F instances
        value        = 50
      },
      {
        service_code = "ec2"
        quota_code   = "L-34B43A08" # Running On-Demand Standard instances
        value        = 200
      }
    ]
  }

  # Test that all EC2 quotas are created
  assert {
    condition     = aws_servicequotas_service_quota.service_quotas["ec2-L-1216C47A"] != null
    error_message = "EC2 quota L-1216C47A should be created"
  }

  assert {
    condition     = aws_servicequotas_service_quota.service_quotas["ec2-L-0263D0A3"] != null
    error_message = "EC2 quota L-0263D0A3 should be created"
  }

  assert {
    condition     = aws_servicequotas_service_quota.service_quotas["ec2-L-34B43A08"] != null
    error_message = "EC2 quota L-34B43A08 should be created"
  }

  # Test that all quotas have correct service code
  assert {
    condition     = aws_servicequotas_service_quota.service_quotas["ec2-L-1216C47A"].service_code == "ec2"
    error_message = "All quotas should have service code ec2"
  }

  assert {
    condition     = aws_servicequotas_service_quota.service_quotas["ec2-L-0263D0A3"].service_code == "ec2"
    error_message = "All quotas should have service code ec2"
  }

  assert {
    condition     = aws_servicequotas_service_quota.service_quotas["ec2-L-34B43A08"].service_code == "ec2"
    error_message = "All quotas should have service code ec2"
  }
}

# Test 5: Service quotas with various numeric values
run "service_quotas_various_values" {
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

    service_quotas = [
      {
        service_code = "lambda"
        quota_code   = "L-B99A9384" # Concurrent executions
        value        = 1000
      },
      {
        service_code = "vpc"
        quota_code   = "L-F678F1CE" # VPCs per Region
        value        = 50
      },
      {
        service_code = "rds"
        quota_code   = "L-7B6409FD" # DB clusters
        value        = 25
      }
    ]
  }

  # Test that quotas with different values are created correctly
  assert {
    condition     = aws_servicequotas_service_quota.service_quotas["lambda-L-B99A9384"].value == 1000
    error_message = "Lambda quota should have value 1000"
  }

  assert {
    condition     = aws_servicequotas_service_quota.service_quotas["vpc-L-F678F1CE"].value == 50
    error_message = "VPC quota should have value 50"
  }

  assert {
    condition     = aws_servicequotas_service_quota.service_quotas["rds-L-7B6409FD"].value == 25
    error_message = "RDS quota should have value 25"
  }
}

# Test 6: Service quotas with large values
run "service_quotas_large_values" {
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

    service_quotas = [
      {
        service_code = "s3"
        quota_code   = "L-89B4F0A3" # Number of buckets
        value        = 10000
      }
    ]
  }

  # Test that quota with large value is created
  assert {
    condition     = aws_servicequotas_service_quota.service_quotas["s3-L-89B4F0A3"].value == 10000
    error_message = "S3 quota should have large value 10000"
  }
}

# Test 7: Service quotas with minimum value (1)
run "service_quotas_minimum_value" {
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

    service_quotas = [
      {
        service_code = "ec2"
        quota_code   = "L-1216C47A"
        value        = 1
      }
    ]
  }

  # Test that quota with minimum value is created
  assert {
    condition     = aws_servicequotas_service_quota.service_quotas["ec2-L-1216C47A"].value == 1
    error_message = "Service quota should accept minimum value of 1"
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

