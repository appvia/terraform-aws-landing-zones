
# Provision the account via the Service Catalog product
resource "aws_servicecatalog_provisioned_product" "control_tower_account" {
  name                     = var.account_name
  product_id               = var.service_catalog_product_id
  product_name             = var.service_catalog_product_name
  provisioning_artifact_id = var.service_catalog_provisioning_artifact_id
  tags                     = var.tags

  provisioning_parameters {
    key   = "AccountName"
    value = var.account_name
  }

  provisioning_parameters {
    key   = "AccountEmail"
    value = var.account_email
  }

  provisioning_parameters {
    key   = "SSOUserEmail"
    value = var.account_email
  }

  provisioning_parameters {
    key   = "ManagedOrganizationalUnit"
    value = var.organizational_unit_id
  }

  provisioning_parameters {
    key   = "SSOUserFirstName"
    value = var.sso_user_first_name
  }

  provisioning_parameters {
    key   = "SSOUserLastName"
    value = var.sso_user_last_name
  }

  lifecycle {
    ignore_changes = [
      product_id,
      product_name,
      provisioning_artifact_id,
      provisioning_parameters,
      tags,
    ]
  }
}
