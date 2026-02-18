# Control Tower Account Module

## Overview

This Terraform module automates the provisioning of AWS accounts through AWS Control Tower using AWS Service Catalog. It simplifies the process of creating new managed accounts within a Control Tower-enabled organization while managing the associated SSO user provisioning.

## Features

- **Automated Account Provisioning**: Provisions AWS accounts through Control Tower's Service Catalog
- **SSO User Integration**: Automatically creates SSO users with specified names and email addresses
- **Organizational Unit Management**: Places accounts in designated organizational units
- **Comprehensive Tagging**: Applies custom tags to all provisioned resources
- **Service Catalog Integration**: Leverages Control Tower's Service Catalog products for account creation
- **Lifecycle Management**: Ignores changes to managed parameters after initial provisioning to maintain stability
- **Output Tracking**: Provides account ID, email, ARN, and status information for created accounts

## Requirements

- **AWS Account**: Must be the management account in a Control Tower-enabled AWS Organization
- **Control Tower Setup**: Control Tower must be deployed with a Service Catalog product available for account provisioning
- **IAM Permissions**: Sufficient permissions to invoke Service Catalog products
- **Terraform**: >= 1.0
- **AWS Provider**: >= 6.0.0

## Module Inputs

The module requires the following inputs:

| Input | Description | Example |
|-------|-------------|---------|
| `account_name` | Name of the AWS account (alphanumeric and dashes, 1-32 chars) | `"production-apps"` |
| `account_email` | Email address for the account | `"prod@example.com"` |
| `organizational_unit_id` | Target OU ID for account placement | `"ou-abc123def456"` |
| `sso_user_first_name` | First name for the SSO user | `"John"` |
| `sso_user_last_name` | Last name for the SSO user | `"Doe"` |
| `service_catalog_provisioning_artifact_id` | Service Catalog artifact ID | `"pa-abc123def456"` |
| `tags` | Custom tags to apply to resources | `{ Environment = "prod", Owner = "team" }` |

Optional:
| Input | Description | Example |
|-------|-------------|---------|
| `service_catalog_product_id` | Service Catalog product ID | `"prod-abc123def456"` |
| `service_catalog_product_name` | Service Catalog product name | `"Control Tower Account Factory"` |

## Module Outputs

| Output | Description |
|--------|-------------|
| `account_id` | The AWS account ID of the provisioned account |
| `account_email` | Email address associated with the account |
| `id` | Service Catalog provisioned product ID |
| `arn` | ARN of the provisioned Service Catalog product |
| `name` | Name of the provisioned product |
| `status` | Provisioning status (AVAILABLE, UNDER_CHANGE, TAINTED, ERROR) |
| `product_id` | The Service Catalog product ID used |
| `provisioning_artifact_id` | The provisioning artifact ID used |
| `provisioning_artifact_name` | The provisioning artifact name used |

## Usage Examples

### Basic Example

```hcl
module "production_account" {
  source = "github.com/appvia/terraform-aws-landing-zones//modules/controltower_account?ref=v0.4.0"

  account_name                             = "production-apps"
  account_email                            = "prod-apps@example.com"
  organizational_unit_id                   = "ou-abc123def456"
  sso_user_first_name                      = "Platform"
  sso_user_last_name                       = "Engineer"
  service_catalog_product_name             = "AWS Control Tower Account Factory"
  service_catalog_provisioning_artifact_id = "pa-123456789abc"

  tags = {
    Environment = "production"
    Managed     = "true"
  }
}
```

### Creating Multiple Accounts with For-Each

```hcl
locals {
  accounts = {
    "development" = {
      email = "dev@example.com"
      ou_id = "ou-dev12345678"
    }
    "staging" = {
      email = "staging@example.com"
      ou_id = "ou-stg12345678"
    }
    "production" = {
      email = "prod@example.com"
      ou_id = "ou-prd12345678"
    }
  }
}

module "accounts" {
  source   = "github.com/appvia/terraform-aws-landing-zones//modules/controltower_account?ref=v0.4.0"
  for_each = local.accounts

  account_name                             = each.key
  account_email                            = each.value.email
  organizational_unit_id                   = each.value.ou_id
  sso_user_first_name                      = title(each.key)
  sso_user_last_name                       = "Account"
  service_catalog_product_name             = "AWS Control Tower Account Factory"
  service_catalog_provisioning_artifact_id = data.aws_servicecatalog_product.control_tower.provisioning_artifacts[0].id

  tags = {
    Environment = each.key
    CreatedBy   = "Terraform"
  }
}

# Output account IDs for reference
output "account_ids" {
  value = {
    for k, v in module.accounts : k => v.account_id
  }
}
```

### Using with Data Source for Product Lookup

```hcl
data "aws_servicecatalog_product" "control_tower" {
  name = "AWS Control Tower Account Factory"
}

module "new_account" {
  source = "github.com/appvia/terraform-aws-landing-zones//modules/controltower_account?ref=v0.4.0"

  account_name                             = "data-platform"
  account_email                            = "data-platform@example.com"
  organizational_unit_id                   = "ou-data12345678"
  sso_user_first_name                      = "Data"
  sso_user_last_name                       = "Admin"
  service_catalog_product_id               = data.aws_servicecatalog_product.control_tower.id
  service_catalog_provisioning_artifact_id = data.aws_servicecatalog_product.control_tower.provisioning_artifacts[0].id

  tags = {
    CostCenter = "engineering"
    Project    = "data-platform"
  }
}
```

## Configuration Details

### Account Email

The account email must be:
- A valid email address format
- Unique within AWS Organizations (AWS requirement)
- Used as the initial SSO user email

### Account Name

The account name must be:
- 1-32 characters long
- Contain only alphanumeric characters and dashes
- Unique within your organization

### SSO User Configuration

SSO users are created with:
- Email: Uses the `account_email` parameter
- First Name: Set via `sso_user_first_name`
- Last Name: Set via `sso_user_last_name`

### Service Catalog Integration

This module requires:
- An active Service Catalog product for Control Tower account provisioning
- A valid provisioning artifact within that product
- Either `product_id` or `product_name` to identify the product
- A `provisioning_artifact_id` to specify which artifact version to use

The service catalog product handles the actual account creation in AWS Organizations.

## Important Notes

1. **Idempotency**: The module uses `ignore_changes` on lifecycle parameters to ensure stable resource management after initial provisioning. Changes to parameters (except tags) on subsequent applies will be ignored.

2. **Service Catalog Dependency**: Account provisioning depends on having a properly configured Control Tower Service Catalog product. Without this, the module will fail.

3. **Email Uniqueness**: AWS Organizations requires unique email addresses. Ensure email addresses do not already exist in your organization.

4. **OU Validation**: The organizational unit must exist before provisioning. Provide the OU ID, not the name.

5. **SSO Email**: The SSO user is created with the same email as the account email.

6. **Status Monitoring**: Use the `status` output to monitor provisioning completion. Common values are `AVAILABLE` (success) and `UNDER_CHANGE` (in progress).

## Troubleshooting

### Account Provisioning Timeout
If account provisioning takes longer than expected:
- Verify the Service Catalog product is properly configured
- Check IAM permissions in the management account
- Review AWS Control Tower CloudTrail logs for errors

### Email Already Exists Error
- Ensure the email address is unique in the organization
- Check if the account was previously created

### OU Not Found
- Verify the `organizational_unit_id` is correct
- Ensure the OU exists before provisioning

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_email"></a> [account\_email](#input\_account\_email) | The email address of the account to create | `string` | n/a | yes |
| <a name="input_account_name"></a> [account\_name](#input\_account\_name) | The name of the account to create | `string` | n/a | yes |
| <a name="input_organizational_unit_id"></a> [organizational\_unit\_id](#input\_organizational\_unit\_id) | The organizational unit id where the account should be created | `string` | n/a | yes |
| <a name="input_service_catalog_provisioning_artifact_id"></a> [service\_catalog\_provisioning\_artifact\_id](#input\_service\_catalog\_provisioning\_artifact\_id) | The ID of the Service Catalog provisioning artifact to use for account creation | `string` | n/a | yes |
| <a name="input_sso_user_first_name"></a> [sso\_user\_first\_name](#input\_sso\_user\_first\_name) | The first name of the SSO user to create | `string` | n/a | yes |
| <a name="input_sso_user_last_name"></a> [sso\_user\_last\_name](#input\_sso\_user\_last\_name) | The last name of the SSO user to create | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to apply to all resources | `map(string)` | n/a | yes |
| <a name="input_service_catalog_product_id"></a> [service\_catalog\_product\_id](#input\_service\_catalog\_product\_id) | The ID of the Service Catalog provisioning artifact to use for account creation | `string` | `null` | no |
| <a name="input_service_catalog_product_name"></a> [service\_catalog\_product\_name](#input\_service\_catalog\_product\_name) | The name of the Service Catalog product to use for account creation | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_email"></a> [account\_email](#output\_account\_email) | The email address associated to the account |
| <a name="output_account_id"></a> [account\_id](#output\_account\_id) | The account ID of the provisioned account |
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the provisioned service catalog product |
| <a name="output_id"></a> [id](#output\_id) | The ID of the provisioned service catalog product |
| <a name="output_name"></a> [name](#output\_name) | The name of the provisioned service catalog product |
| <a name="output_product_id"></a> [product\_id](#output\_product\_id) | The ID of the product used to provision the service catalog product |
| <a name="output_provisioning_artifact_id"></a> [provisioning\_artifact\_id](#output\_provisioning\_artifact\_id) | The ID of the provisioning artifact used to provision the service catalog product |
| <a name="output_provisioning_artifact_name"></a> [provisioning\_artifact\_name](#output\_provisioning\_artifact\_name) | The name of the provisioning artifact used to provision the service catalog product |
| <a name="output_status"></a> [status](#output\_status) | The status of the provisioned service catalog product |
<!-- END_TF_DOCS -->