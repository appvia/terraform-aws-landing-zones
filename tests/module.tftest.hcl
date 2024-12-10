

run "basic" {
  command = plan

  variables {
    environment    = "Production"
    owner          = "Support"
    product        = "Test"
    region         = "eu-west-2"
    home_region    = "eu-west-2"
    tags           = {}
    git_repository = "test"

    notifications = {
      email = {
        addresses = ["john.doe@example.com"]
      }
    }
  }
}

mock_provider "aws" {
  alias = "tenant"

  mock_data "aws_region" {
    defaults = {
      current_region = "eu-west-2"
    }
  }

  mock_data "aws_caller_identity" {
    defaults = {
      account_id = "123456789012"
    }
  }

  mock_data "aws_partition" {
    defaults = {
      partition = "aws"
    }
  }
}

mock_provider "aws" {
  mock_data "aws_region" {
    defaults = {
      current_region = "eu-west-2"
    }
  }

  mock_data "aws_caller_identity" {
    defaults = {
      account_id = "123456789012"
    }
  }
}

mock_provider "aws" {
  alias = "management"

  mock_data "aws_organizations_organization" {
    defaults = {
      roots = [
        {
          id = "r-1234567890abcdef0"
        }
      ]
    }
  }
}

mock_provider "aws" {
  alias = "identity"

  mock_data "aws_ssoadmin_instances" {
    defaults = {
      instances = [
        {
          id     = "ssoins-1234567890abcdef0"
          name   = "default"
          status = "ACTIVE"
        }
      ]
      arns = [
        "arn:aws:sso:::instance/ssoins-1234567890abcdef0"
      ]
      identity_store_ids = [
        "ssoins-1234567890abcdeft"
      ]
    }
  }
}

mock_provider "aws" {
  alias = "network"
}
