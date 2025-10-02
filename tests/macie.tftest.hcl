# Macie Service Tests
# This file contains comprehensive tests for the Macie service configuration

# Override the notifications module to provide a mock SNS topic
override_module {
  target = module.notifications
  outputs = {
    sns_topic_arn = "arn:aws:sns:eu-west-2:123456789012:appvia-notifications"
  }
}

# Test 1: Macie service enabled with default settings
run "macie_enabled_default" {
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

    macie = {
      enable    = true
      frequency = "FIFTEEN_MINUTES"
    }
  }

  # Test that Macie account is created
  assert {
    condition     = aws_macie2_account.macie_member[0] != null
    error_message = "Macie account should be created when enabled"
  }

  # Test that Macie account is enabled
  assert {
    condition     = aws_macie2_account.macie_member[0].status == "ENABLED"
    error_message = "Macie account should be enabled when enable is true"
  }

  # Test that frequency is set correctly
  assert {
    condition     = aws_macie2_account.macie_member[0].finding_publishing_frequency == "FIFTEEN_MINUTES"
    error_message = "Macie finding publishing frequency should be set to FIFTEEN_MINUTES"
  }

  # Test that invitation accepter is not created (no admin account)
  assert {
    condition     = length(aws_macie2_invitation_accepter.member) == 0
    error_message = "Macie invitation accepter should not be created when no admin account is specified"
  }
}

# Test 2: Macie service disabled
run "macie_disabled" {
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

    macie = {
      enable    = false
      frequency = "FIFTEEN_MINUTES"
    }
  }

  # Test that Macie account is created but paused
  assert {
    condition     = aws_macie2_account.macie_member[0] != null
    error_message = "Macie account should be created even when disabled"
  }

  # Test that Macie account is paused
  assert {
    condition     = aws_macie2_account.macie_member[0].status == "PAUSED"
    error_message = "Macie account should be paused when enable is false"
  }

  # Test that invitation accepter is not created
  assert {
    condition     = length(aws_macie2_invitation_accepter.member) == 0
    error_message = "Macie invitation accepter should not be created when disabled"
  }
}

# Test 3: Macie service with admin account (invitation accepter)
run "macie_with_admin_account" {
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

    macie = {
      enable           = true
      frequency        = "ONE_HOUR"
      admin_account_id = "123456789012"
    }
  }

  # Test that Macie account is created and enabled
  assert {
    condition     = aws_macie2_account.macie_member[0] != null
    error_message = "Macie account should be created when enabled with admin account"
  }

  # Test that Macie account is enabled
  assert {
    condition     = aws_macie2_account.macie_member[0].status == "ENABLED"
    error_message = "Macie account should be enabled when enable is true"
  }

  # Test that frequency is set correctly
  assert {
    condition     = aws_macie2_account.macie_member[0].finding_publishing_frequency == "ONE_HOUR"
    error_message = "Macie finding publishing frequency should be set to ONE_HOUR"
  }

  # Test that invitation accepter is created
  assert {
    condition     = aws_macie2_invitation_accepter.member[0] != null
    error_message = "Macie invitation accepter should be created when admin account is specified"
  }

  # Test that invitation accepter has correct admin account ID
  assert {
    condition     = aws_macie2_invitation_accepter.member[0].administrator_account_id == "123456789012"
    error_message = "Macie invitation accepter should have correct administrator account ID"
  }
}

# Test 4: Macie service with different frequency settings
run "macie_different_frequencies" {
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

    macie = {
      enable    = true
      frequency = "SIX_HOURS"
    }
  }

  # Test that frequency is set correctly
  assert {
    condition     = aws_macie2_account.macie_member[0].finding_publishing_frequency == "SIX_HOURS"
    error_message = "Macie finding publishing frequency should be set to SIX_HOURS"
  }
}

# Test 5: Macie service not configured (null)
run "macie_not_configured" {
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

    # macie is not set (defaults to null)
  }

  # Test that Macie account is not created
  assert {
    condition     = length(aws_macie2_account.macie_member) == 0
    error_message = "Macie account should not be created when macie is not configured"
  }

  # Test that invitation accepter is not created
  assert {
    condition     = length(aws_macie2_invitation_accepter.member) == 0
    error_message = "Macie invitation accepter should not be created when macie is not configured"
  }
}

# Test 6: Macie service with admin account but disabled
run "macie_with_admin_but_disabled" {
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

    macie = {
      enable           = false
      frequency        = "FIFTEEN_MINUTES"
      admin_account_id = "123456789012"
    }
  }

  # Test that Macie account is created but paused
  assert {
    condition     = aws_macie2_account.macie_member[0] != null
    error_message = "Macie account should be created even when disabled with admin account"
  }

  # Test that Macie account is paused
  assert {
    condition     = aws_macie2_account.macie_member[0].status == "PAUSED"
    error_message = "Macie account should be paused when enable is false"
  }

  # Test that invitation accepter is not created when disabled
  assert {
    condition     = length(aws_macie2_invitation_accepter.member) == 0
    error_message = "Macie invitation accepter should not be created when disabled even with admin account"
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
