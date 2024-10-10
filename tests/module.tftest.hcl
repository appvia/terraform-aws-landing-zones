mock_provider "aws" {

  mock_data "aws_availability_zones" {
    defaults = {
      names = [
        "eu-west-1a",
        "eu-west-1b",
        "eu-west-1c"
      ]
    }
  }
}

mock_provider "aws" {
  alias = "tenant"

  mock_data "aws_availability_zones" {
    defaults = {
      names = [
        "eu-west-1a",
        "eu-west-1b",
        "eu-west-1c"
      ]
    }
  }
}

mock_provider "aws" {
  alias = "management"

  mock_data "aws_availability_zones" {
    defaults = {
      names = [
        "eu-west-1a",
        "eu-west-1b",
        "eu-west-1c"
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

run "basic" {
  command = plan

  variables {
    cost_center = "12345"
    environment = "Production"
    owner       = "Support"
    product     = "Test"
    region      = "eu-west-2"
    tags = {
      "Component" = "Test"
    }
  }
}
