
override_module {
  target = module.notifications
  outputs = {
    sns_topic_arn = "arn:aws:sns:eu-west-2:123456789012:appvia-notifications"
  }
}

run "basic_with_query" {
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

    resource_groups = {
      "test-resource-group" = {
        description = "Test resource group"
        query = {
          resource_type_filters = ["AWS::AllSupported"]
          tag_filters           = { "Environment" = ["Production"] }
        }
      }
    }
  }

  assert {
    condition     = aws_resourcegroups_group.resource_groups["test-resource-group"] != null
    error_message = "Resource group should be created"
  }

  assert {
    condition     = aws_resourcegroups_group.resource_groups["test-resource-group"].resource_query[0].type == "TAG_FILTERS_1_0"
    error_message = "Resource group resource query type should be TAG_FILTERS_1_0"
  }

  assert {
    condition     = aws_resourcegroups_group.resource_groups["test-resource-group"].resource_query[0].query == "{\"ResourceTypeFilters\":[\"AWS::AllSupported\"],\"TagFilters\":[{\"Key\":\"Environment\",\"Values\":[\"Production\"]}]}"
    error_message = "Resource group resource query query should be equal to {\"ResourceTypeFilters\":[\"AWS::AllSupported\"],\"TagFilters\":[{\"Key\":\"Environment\",\"Values\":[\"Production\"]}]}"
  }
}

run "basic" {
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

    resource_groups = {
      "test-resource-group" = {
        description    = "Test resource group"
        type           = "TAG_FILTERS_1_0"
        resource_query = "{\"type\":\"TAG_FILTERS_1_0\",\"query\":\"{\\\"tagFilters\\\":[{\\\"key\\\":\\\"Environment\\\",\\\"values\\\":[\\\"Production\\\"]}]}\"}"
        configuration = {
          type = "TAG_FILTERS_1_0"
          parameters = [
            {
              name   = "Environment"
              values = ["Production"]
            }
          ]
        }
      }
    }
  }

  assert {
    condition     = aws_resourcegroups_group.resource_groups["test-resource-group"] != null
    error_message = "Resource group should be created"
  }

  assert {
    condition     = aws_resourcegroups_group.resource_groups["test-resource-group"].resource_query[0].type == "TAG_FILTERS_1_0"
    error_message = "Resource group resource query type should be TAG_FILTERS_1_0"
  }

  assert {
    condition     = aws_resourcegroups_group.resource_groups["test-resource-group"].resource_query[0].query == "{\"type\":\"TAG_FILTERS_1_0\",\"query\":\"{\\\"tagFilters\\\":[{\\\"key\\\":\\\"Environment\\\",\\\"values\\\":[\\\"Production\\\"]}]}\"}"
    error_message = "Resource group resource query query should be {\"type\":\"TAG_FILTERS_1_0\",\"query\":\"{\\\"tagFilters\\\":[{\\\"key\\\":\\\"Environment\\\",\\\"values\\\":[\\\"Production\\\"]}]}\""
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
