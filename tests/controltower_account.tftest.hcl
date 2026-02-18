run "controltower_account_basic" {
  command = plan

  module {
    source = "./modules/controltower_account"
  }

  variables {
    account_email                            = "prod-apps@example.com"
    account_name                             = "production-apps"
    organizational_unit_id                   = "ou-1234-12345678"
    sso_user_first_name                      = "Platform"
    sso_user_last_name                       = "Engineer"
    service_catalog_provisioning_artifact_id = "pa-123456789abc"
    service_catalog_product_name             = "AWS Control Tower Account Factory"
    tags = {
      Environment = "production"
      Managed     = "true"
    }
  }

  assert {
    condition     = aws_servicecatalog_provisioned_product.control_tower_account.name == "production-apps"
    error_message = "The provisioned product name should match the account name"
  }

  assert {
    condition     = length(aws_servicecatalog_provisioned_product.control_tower_account.provisioning_parameters) > 0
    error_message = "The provisioning parameters should be provided"
  }

  assert {
    condition     = aws_servicecatalog_provisioned_product.control_tower_account.tags["Environment"] == "production"
    error_message = "The Environment tag should be applied"
  }
}

run "controltower_account_with_product_id" {
  command = plan

  module {
    source = "./modules/controltower_account"
  }

  variables {
    account_email                            = "dev-apps@example.com"
    account_name                             = "development-apps"
    organizational_unit_id                   = "ou-1234-12345678"
    sso_user_first_name                      = "Developer"
    sso_user_last_name                       = "Account"
    service_catalog_provisioning_artifact_id = "pa-987654321xyz"
    service_catalog_product_id               = "prod-abc123def456"
    tags = {
      Environment = "development"
      Owner       = "engineering"
    }
  }

  assert {
    condition     = aws_servicecatalog_provisioned_product.control_tower_account.product_id == "prod-abc123def456"
    error_message = "The product ID should be set correctly"
  }

  assert {
    condition     = aws_servicecatalog_provisioned_product.control_tower_account.provisioning_artifact_id == "pa-987654321xyz"
    error_message = "The provisioning artifact ID should be set correctly"
  }
}

run "controltower_account_sso_parameters" {
  command = plan

  module {
    source = "./modules/controltower_account"
  }

  variables {
    account_email                            = "test@example.com"
    account_name                             = "test-account"
    organizational_unit_id                   = "ou-1234-12345678"
    sso_user_first_name                      = "John"
    sso_user_last_name                       = "Doe"
    service_catalog_provisioning_artifact_id = "pa-test123456789"
    service_catalog_product_name             = "AWS Control Tower Account Factory"
    tags                                     = {}
  }

  assert {
    condition     = aws_servicecatalog_provisioned_product.control_tower_account.provisioning_parameters != null
    error_message = "Provisioning parameters should not be null"
  }

  assert {
    condition     = length(aws_servicecatalog_provisioned_product.control_tower_account.provisioning_parameters) == 6
    error_message = "There should be 6 provisioning parameters (AccountName, AccountEmail, SSOUserFirstName, SSOUserLastName, OrganizationalUnitId, ServiceCatalogProductName)"
  }
}

run "controltower_account_lifecycle" {
  command = plan

  module {
    source = "./modules/controltower_account"
  }

  variables {
    account_email                            = "lifecycle@example.com"
    account_name                             = "lifecycle-test"
    organizational_unit_id                   = "ou-1234-12345678"
    sso_user_first_name                      = "Lifecycle"
    sso_user_last_name                       = "Test"
    service_catalog_provisioning_artifact_id = "pa-lifecycle1234"
    service_catalog_product_name             = "AWS Control Tower Account Factory"
    tags = {
      Test = "lifecycle"
    }
  }
}

mock_provider "aws" {}