run "organizations_account_basic" {
  command = plan

  module {
    source = "./modules/organizations_account"
  }

  variables {
    account_email          = "prod-apps@example.com"
    account_name           = "production-apps"
    organizational_unit_id = "ou-1234-12345678"
    tags = {
      Environment = "production"
      Managed     = "terraform"
    }
  }

  assert {
    condition     = aws_organizations_account.account.name == "production-apps"
    error_message = "The account name should match the input variable"
  }

  assert {
    condition     = aws_organizations_account.account.email == "prod-apps@example.com"
    error_message = "The account email should match the input variable"
  }

  assert {
    condition     = aws_organizations_account.account.parent_id == "ou-1234-12345678"
    error_message = "The parent OU ID should be set correctly"
  }

  assert {
    condition     = aws_organizations_account.account.tags["Environment"] == "production"
    error_message = "The Environment tag should be applied"
  }
}

run "organizations_account_billing_access_enabled" {
  command = plan

  module {
    source = "./modules/organizations_account"
  }

  variables {
    account_email             = "dev-apps@example.com"
    account_name              = "development-apps"
    organizational_unit_id    = "ou-1234-12345678"
    enable_iam_billing_access = true
    tags = {
      Environment = "development"
    }
  }

  assert {
    condition     = aws_organizations_account.account.iam_user_access_to_billing == "ALLOW"
    error_message = "IAM billing access should be ALLOW when enabled"
  }
}

run "organizations_account_billing_access_disabled" {
  command = plan

  module {
    source = "./modules/organizations_account"
  }

  variables {
    account_email             = "secure-apps@example.com"
    account_name              = "secure-apps"
    organizational_unit_id    = "ou-1234-12345678"
    enable_iam_billing_access = false
    tags = {
      Environment = "production"
      Security    = "high"
    }
  }

  assert {
    condition     = aws_organizations_account.account.iam_user_access_to_billing == "DENY"
    error_message = "IAM billing access should be DENY when disabled"
  }
}

run "organizations_account_close_on_deletion_true" {
  command = plan

  module {
    source = "./modules/organizations_account"
  }

  variables {
    account_email          = "sandbox@example.com"
    account_name           = "sandbox-testing"
    organizational_unit_id = "ou-1234-12345678"
    close_on_deletion      = true
    tags = {
      Environment = "sandbox"
      Ephemeral   = "true"
    }
  }

  assert {
    condition     = aws_organizations_account.account.close_on_deletion == true
    error_message = "The close_on_deletion flag should be set to true for ephemeral accounts"
  }
}

run "organizations_account_close_on_deletion_false" {
  command = plan

  module {
    source = "./modules/organizations_account"
  }

  variables {
    account_email          = "staging@example.com"
    account_name           = "staging-apps"
    organizational_unit_id = "ou-1234-12345678"
    close_on_deletion      = false
    tags = {
      Environment = "staging"
    }
  }

  assert {
    condition     = aws_organizations_account.account.close_on_deletion == false
    error_message = "The close_on_deletion flag should respect the input variable"
  }
}

run "organizations_account_tags_applied" {
  command = plan

  module {
    source = "./modules/organizations_account"
  }

  variables {
    account_email          = "tagged@example.com"
    account_name           = "tagged-account"
    organizational_unit_id = "ou-1234-12345678"
    tags = {
      Environment = "test"
      CostCenter  = "engineering"
      Owner       = "platform-team"
      CreatedBy   = "terraform"
    }
  }

  assert {
    condition     = aws_organizations_account.account.tags["Environment"] == "test"
    error_message = "The Environment tag should be applied"
  }

  assert {
    condition     = aws_organizations_account.account.tags["CostCenter"] == "engineering"
    error_message = "The CostCenter tag should be applied"
  }

  assert {
    condition     = aws_organizations_account.account.tags["Owner"] == "platform-team"
    error_message = "The Owner tag should be applied"
  }

  assert {
    condition     = aws_organizations_account.account.tags["CreatedBy"] == "terraform"
    error_message = "The CreatedBy tag should be applied"
  }
}

run "organizations_account_multiple_instances" {
  command = apply

  module {
    source = "./modules/organizations_account"
  }

  variables {
    account_email          = "multi-test@example.com"
    account_name           = "multi-account"
    organizational_unit_id = "ou-1234-12345678"
    tags = {
      Environment = "test"
    }
  }

  assert {
    condition     = can(aws_organizations_account.account.id)
    error_message = "The account ID should be accessible in the output"
  }

  assert {
    condition     = aws_organizations_account.account.arn != ""
    error_message = "The account ARN should be accessible in the output"
  }

  assert {
    condition     = aws_organizations_account.account.state != ""
    error_message = "The account state should be accessible in the output"
  }
}

run "organizations_account_default_billing_access" {
  command = plan

  module {
    source = "./modules/organizations_account"
  }

  variables {
    account_email          = "default-test@example.com"
    account_name           = "default-test-account"
    organizational_unit_id = "ou-1234-12345678"
    tags = {
      Environment = "test"
    }
  }

  assert {
    condition     = aws_organizations_account.account.iam_user_access_to_billing == "ALLOW"
    error_message = "The default IAM billing access should be ALLOW"
  }
}

mock_provider "aws" {
  source = "./tests/providers/management"
}
