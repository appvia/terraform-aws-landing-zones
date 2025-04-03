
override_module {
  target = module.notifications
  outputs = {
    sns_topic_arn = "arn:aws:sns:eu-west-2:123456789012:appvia-notifications"
  }
}

run "validate_module" {
  command = plan

  variables {
    environment    = "Production"
    owner          = "Support"
    product        = "Test"
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
