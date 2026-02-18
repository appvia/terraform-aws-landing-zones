# AWS Organizations Account Module

## Overview

This Terraform module creates and manages AWS accounts within AWS Organizations. Unlike the Control Tower account module which relies on Service Catalog, this module provides a simpler, direct approach to provisioning accounts using the AWS Organizations API. It's ideal for organizations that haven't implemented Control Tower or need direct organizational account management.

## Features

- **Direct AWS Organizations Integration**: Creates accounts directly in AWS Organizations without requiring Control Tower
- **Organizational Unit Assignment**: Automatically places accounts in specified organizational units
- **IAM Billing Access Control**: Optional IAM user access to billing information
- **Account Lifecycle Management**: Configurable behavior for account deletion (close or retain)
- **Comprehensive Tagging**: Apply custom tags to all provisioned accounts
- **Status Tracking**: Monitor account status throughout its lifecycle
- **Simple Configuration**: Minimal required inputs for straightforward account creation

## Requirements

- **AWS Account**: Must be the management account in an AWS Organization
- **AWS Organizations**: Organization must be enabled in the account
- **IAM Permissions**: Sufficient permissions to create accounts in AWS Organizations
- **Terraform**: >= 1.0
- **AWS Provider**: >= 6.0.0

## Module Inputs

The module requires the following inputs:

| Input | Description | Type | Example |
|-------|-------------|------|---------|
| `account_name` | Name of the AWS account | `string` | `"production-apps"` |
| `account_email` | Email address for the account | `string` | `"prod@example.com"` |
| `organizational_unit_id` | Target OU ID for account placement | `string` | `"ou-abc123def456"` |
| `tags` | Custom tags to apply to resources | `map(string)` | `{ Environment = "prod" }` |

Optional:
| Input | Description | Type | Default |
|-------|-------------|------|---------|
| `close_on_deletion` | Close account when removed from Terraform | `bool` | `null` |
| `enable_iam_billing_access` | Allow IAM users to access billing info | `bool` | `true` |

## Module Outputs

| Output | Description |
|--------|-------------|
| `account_id` | The AWS account ID |
| `account_arn` | ARN of the account |
| `account_name` | The account name |
| `account_email` | Email address of the account |
| `account_status` | Provisioning status (ACTIVE, SUSPENDED, etc.) |

## Usage Examples

### Basic Example

```hcl
module "production_account" {
  source = "github.com/appvia/terraform-aws-landing-zones//modules/organizations_account?ref=v0.4.0"

  account_name           = "production-apps"
  account_email          = "prod-apps@example.com"
  organizational_unit_id = "ou-abc123def456"

  tags = {
    Environment = "production"
    Managed     = "terraform"
  }
}

output "prod_account_id" {
  value = module.production_account.account_id
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
  source   = "github.com/appvia/terraform-aws-landing-zones//modules/organizations_account?ref=v0.4.0"
  for_each = local.accounts

  account_name           = each.key
  account_email          = each.value.email
  organizational_unit_id = each.value.ou_id

  tags = {
    Environment = each.key
    CreatedBy   = "Terraform"
  }
}

# Output account mapping
output "account_ids" {
  value = {
    for k, v in module.accounts : k => v.account_id
  }
}

output "account_details" {
  value = {
    for k, v in module.accounts : k => {
      id     = v.account_id
      arn    = v.account_arn
      email  = v.account_email
      status = v.account_status
    }
  }
}
```

### With Billing Access Control

```hcl
module "data_platform_account" {
  source = "github.com/appvia/terraform-aws-landing-zones//modules/organizations_account?ref=v0.4.0"

  account_name           = "data-platform"
  account_email          = "data-platform@example.com"
  organizational_unit_id = "ou-data12345678"

  # Allow IAM users to access billing (default)
  enable_iam_billing_access = true

  tags = {
    Environment = "production"
    CostCenter  = "engineering"
  }
}
```

### With Account Closure on Deletion

```hcl
module "sandbox_account" {
  source = "github.com/appvia/terraform-aws-landing-zones//modules/organizations_account?ref=v0.4.0"

  account_name           = "sandbox-testing"
  account_email          = "sandbox@example.com"
  organizational_unit_id = "ou-sandbox12345678"

  # Automatically close the account when removed from Terraform
  close_on_deletion = true

  tags = {
    Environment = "sandbox"
    Ephemeral   = "true"
  }
}
```

### Referencing Organizational Unit Dynamically

```hcl
data "aws_organizations_organization" "org" {}

data "aws_organizations_organizational_unit" "workloads" {
  parent_id = data.aws_organizations_organization.org.roots[0].id
  name      = "Workloads"
}

module "workload_account" {
  source = "github.com/appvia/terraform-aws-landing-zones//modules/organizations_account?ref=v0.4.0"

  account_name           = "workload-project"
  account_email          = "workload@example.com"
  organizational_unit_id = data.aws_organizations_organizational_unit.workloads.id

  tags = {
    Environment = "production"
  }
}
```

## Configuration Details

### Account Email

The account email must be:
- A valid email address format
- Unique within AWS Organizations (AWS requirement)
- An email address you can access (AWS will send confirmation emails)

### Account Name

The account name can be:
- Up to 50 characters
- A friendly name for identification
- Can include spaces (unlike Control Tower accounts)

### Organizational Unit

The organizational unit must:
- Exist before account provisioning
- Be specified by its ID (not name)
- Be a target for the management account

To find your OU ID:
```hcl
data "aws_organizations_organizational_unit" "workloads" {
  parent_id = data.aws_organizations_organization.org.roots[0].id
  name      = "Workloads"
}

# Use: data.aws_organizations_organizational_unit.workloads.id
```

### IAM Billing Access

By default (`enable_iam_billing_access = true`), IAM users in created accounts can access:
- Consolidated billing information
- Cost and usage reports
- AWS Billing and Cost Management console

Set to `false` to restrict IAM users from accessing billing information.

### Account Deletion Behavior

The `close_on_deletion` parameter controls what happens when the account is removed from Terraform:

- `null` (default): Account remains in organization (safest for production)
- `true`: Account is closed when removed (suitable for ephemeral/sandbox accounts)
- `false`: Account is suspended when removed

## Key Differences from Control Tower Module

| Aspect | Organizations Account | Control Tower Account |
|--------|----------------------|----------------------|
| **Dependency** | AWS Organizations only | Requires Control Tower + Service Catalog |
| **Setup Complexity** | Simpler | More complex |
| **SSOUser Creation** | Not automated | Automated |
| **Account Name** | Allows spaces, 50 chars | Alphanumeric/dashes, 32 chars |
| **Implementation** | Direct AWS Organizations API | Service Catalog product |
| **Best For** | Simple account creation | Enterprise governance |

## Important Notes

1. **Email Uniqueness**: AWS Organizations requires unique email addresses across all accounts. Ensure email addresses don't already exist in your organization.

2. **Account Creation Time**: Account creation typically takes 5-15 minutes. Check the `account_status` output to monitor progress.

3. **Immutable Properties**: Some properties like account email cannot be changed after creation—they're part of the account's identity.

4. **Role Name**: The module ignores changes to the role name after creation as AWS Organizations doesn't allow re-reading this value.

5. **No Automatic SSO**: This module doesn't create SSO users. Use AWS IAM Identity Center (formerly SSO) separately to set up access.

6. **Account Deletion Risks**: Setting `close_on_deletion = true` will close the account permanently. Use with caution in non-sandboxed environments.

7. **OU Existence**: Ensure the target OU exists before provisioning. Moving accounts between OUs is possible but requires separate operations.

## Troubleshooting

### Account Creation Timeout

If the account status remains `CREATING` for more than 15 minutes:
- Check AWS Service Health Dashboard for AWS Organizations
- Verify IAM permissions in the management account
- Review CloudTrail logs for any permission errors

### Email Already Exists Error

```
Error: Account with email address already exists
```

Solution:
- Ensure the email address is unique in your organization
- Check if the account was previously created and not removed from Terraform state
- Use a different email address

### Invalid OU ID Error

```
Error: Invalid OU ID
```

Solution:
- Verify the OU exists: `aws organizations describe-organizational-unit --organizational-unit-id "ou-xxx"`
- Ensure you're providing the OU ID (not the name)
- Confirm the OU is not the organization root if you need a specific OU

### Access Denied

```
Error: AccessDenied
```

Solution:
- Verify you're using the management account
- Confirm IAM permissions include `organizations:CreateAccount` and related actions
- Check for SCPs (Service Control Policies) that might restrict account creation

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
| <a name="input_close_on_deletion"></a> [close\_on\_deletion](#input\_close\_on\_deletion) | Whether to close the account when it is deleted from the organization | `bool` | `null` | no |
| <a name="input_enable_iam_billing_access"></a> [enable\_iam\_billing\_access](#input\_enable\_iam\_billing\_access) | Whether to allow IAM users to access billing information | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_arn"></a> [account\_arn](#output\_account\_arn) | The ARN of the account |
| <a name="output_account_email"></a> [account\_email](#output\_account\_email) | The email address of the account |
| <a name="output_account_id"></a> [account\_id](#output\_account\_id) | The ID of the account |
| <a name="output_account_name"></a> [account\_name](#output\_account\_name) | The name of the account |
| <a name="output_account_status"></a> [account\_status](#output\_account\_status) | The status of the account |
<!-- END_TF_DOCS -->