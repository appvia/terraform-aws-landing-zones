![Github Actions](../../actions/workflows/terraform.yml/badge.svg)

# Terraform AWS Landing Zone

## Description

Note, this module is not intended to be used outside of the organization, as the template provides a consistent blueprint for the provisioning of accounts with the Appvia AWS estate.

## Usage

Please refer to one of the application, platform or sandbox pipelines for an example of how to use this module.

## Notification Features

Tenants are able to provision notifications within the designated region. This first step to ensure notifications is enabled.

```hcl
notifications = {
  email = {
    addresses = ["MY_EMAIL_ADDRESS"]
  }
  slack = {
    webhook = "MY_SLACK_WEBHOOK"
  }
}
```

## Security Features

The notifications can used to send notifications to users via email or slack, for events related to costs, security and budgets.

### Service Control Policies

Additional service control policies can be applied to the account. This is useful for ensuring that the account is compliant with the organization's security policies, specific to the accounts requirements.

You can configure additional service control policies using the `var.service_control_policies` variable, such as the below example

```hcl
data "aws_iam_policy_document" "deny_s3" {
  statement {
    effect    = "Deny"
    actions = ["s3:*"]
    resources = ["*"]
  }
}

module "account" {
  service_control_policies = {
    "MY_POLICY_NAME" = {
      name   = "deny-s3"
      policy = data.aws_iam_policy_document.deny_s3.json
    }
  }
}
```

### AWS Config Compliance Packs

You can configure additional compliance packs using the `var.aws_config` variable, such as the below example

```hcl
data "http" "security_hub_enabled" {
  url = "https://s3.amazonaws.com/aws-service-catalog-reference-architectures/AWS_Config_Rules/Security/SecurityHub/SecurityHub-Enabled.json"
}

module "account" {
  aws_config = {
    enable = true
    compliance_packs = {
      "MY_COMPLIANCE_PACK" = {
        parameter_overrides = {
          "MY_PARAMETER" = "MY_VALUE"
        }
        template_url = data.http.security_hub_enabled.body
      }
    }
  }
}
```

### IAM Password Policy

The IAM password policy can be configured to enforce password policies on the account. This is useful for ensuring that the account is compliant with the organization's security policies, specific to the accounts requirements.

```hcl
iam_password_policy = {
  enabled = true
  allow_users_to_change_password = true
  hard_expiry = false
  max_password_age = 90
  minimum_password_length = 8
  password_reuse_prevention = 24
  require_lowercase_characters = true
  require_numbers = true
  require_symbols = true
  require_uppercase_characters = true
}
```

### IAM Access Analyzer

The IAM access analyzer can be configured to analyze access to resources within your account and produce findings related to excessive permissions and or permissions which carry a high risk.

```hcl
iam_access_analyzer = {
  enabled = true
  analyzer_name = "lza-iam-access-analyzer" # optional
  analyzer_type = "ORGANIZATION" # optional but default
}
```

### EBS Encryption

The EBS encryption can be configured to encrypt all EBS volumes within the account. The feature ensures all volumes are automatically encrypted.

```hcl
ebs_encryption = {
  enabled = true
  create_kms_key = true
  key_alias = "lza/ebs/default"
}
```

### S3 Block Public Access

The S3 block public access can be configured to block public access to S3 buckets within the account. The feature ensures all buckets are automatically blocked from public access.

```hcl
s3_block_public_access = {
  enabled = true
  enable_block_public_policy = true
  enable_block_public_acls = true
  enable_ignore_public_acls = true
  enable_restrict_public_buckets = true
}
```

### IAM Customers Managed Policies

This module can ensure a set of IAM policies are created within the account. This is useful for ensuring that the account is preloaded with any required policy sets.

You can configure additional IAM policies using the `var.iam_policies` variable, such as the below example

```hcl
module "account" {
  iam_policies = {
    "deny_s3" = {
      name = "deny-s3"
      description = "Used to deny access to S3"
      policy = data.aws_iam_policy_document.deny_s3.json
    }
    "deny_s3_with_prefix" = {
      name_prefix = "deny-s3-"
      policy = data.aws_iam_policy_document.deny_s3.json
      description = "Used to deny access to S3"
      path   = "/"
    }
  }
}
```

### IAM Roles

This module can ensure a set of IAM roles are created within the account. This is useful for ensuring that the account is compliant with the organization's security policies, specific to the accounts requirements. Note, the IAM role have an automatic dependency on any IAM policies defined above to ensure ordering.

You can configure additional IAM roles using the `var.iam_roles` variable, such as the below example

```hcl
module "account" {
  iam_roles = {
    "s3_administrator" = {
      name = "MY_ROLE_NAME"
      assume_roles = ["arn:aws:iam::123456789012:role/role-name"]
      description = "Administrator role for S3"
      path = "/"
      permissions_boundary_arn = null
      permissions_arns = [
        "arn:aws:iam::aws:policy/AmazonS3FullAccess"
      ]
      #policies = [data.aws_iam_policy_document.deny_s3.json]
    }
    "ec2_instance_profile" {
      name = "lza-ssm-instance-profile"
      assume_services = ["ec2.amazonaws.com"]
      description = "Instance profiles for ec2 compute machine"
      path = "/"
      permissions_arns = [
        "arn:aws:iam::aws:policy/AmazonSSMDirectoryServiceAccess",
        "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
        "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
      ]
    }
    "kms_admin" = {
      name = "kms-admin"
      assume_accounts = ["123456789012"]
      description = "Administrator role for KMS"
      path = "/"
      permissions_arns = [
        "arn:aws:iam::aws:policy/AmazonKMSFullAccess"
      ]
    }
  }
}
```

### RBAC & Identity Center Assignment

This module provides the ability for tenants to manage the assignment of prescribed roles to users and groups within the account. The `sso_assignment` module is used to manage the assignment of roles to users and groups within the account.

Note, the roles permitted for assignment can be found within `local.sso_permitted_permission_sets`, an example of the permitted roles can be found below:

```hcl
sso_permitted_permission_sets = {
  "devops_engineer"   = "DevOpsEngineer"
  "finops_engineer"   = "FinOpsEngineer"
  "network_engineer"  = "NetworkEngineer"
  "network_viewer"    = "NetworkViewer"
  "platform_engineer" = "PlatformEngineer"
  "security_auditor"  = "SecurityAuditor"
}
```

This maps the exposed name used in the `var.rbac` to the name of the role within the AWS Identity Center.

Tenants can assign roles to users and groups by providing a map of users and groups to roles within the `var.rbac` variable. An example of this can be found below:

```hcl
rbac = {
  "devops_engineer" = {
    users  = ["MY_SSO_USER"]
    groups = ["MY_SSO_GROUP"]
  }
}
```

## Cost Management Features

Tenants are able to receive budgets notifications related to the services. Once notifications have been configured they will automatically receive daily, weekly or monthly reports and notifications on where they sit in the budget.

### Anomaly Detection

Tenants are able to provision anomaly detection rules within the designated region. This is useful for ensure cost awareness and alerting on any unexpected costs.

```hcl
cost_anomaly_detection = {
  enabled = true
  monitors = [
    {
      name      = lower("lza-${local.region}")
      frequency = "IMMEDIATE"
      threshold_expression = [
        {
          and = {
            dimension = {
              key           = "ANOMALY_TOTAL_IMPACT_ABSOLUTE"
              match_options = ["GREATER_THAN_OR_EQUAL"]
              values        = ["100"]
            }
          }
        },
        {
          and = {
            dimension = {
              key           = "ANOMALY_TOTAL_IMPACT_PERCENTAGE"
              match_options = ["GREATER_THAN_OR_EQUAL"]
              values        = ["50"]
            }
          }
        }
      ]

      specification = jsonencode({
        "And" : [
          {
            "Dimensions" : {
              "Key" : "REGION"
              "Values" : [local.region]
            }
          }
        ]
      })
    }
  ]
}
```

## Networking Features

Tenants are able to provision networks within the designated region, while allowing the platform to decide how these are wired up into the network topology of the organization i.e. ensuring the are using IPAM, connected to the transit gateway, egress via the central vpc and so forth.

All networks are defined within the `var.networks` variable, an example of this can be found below:

```hcl
networks = {
  my_vpc_name = {
    subnets = {
      private = {
        netmask = 28
      }
      database = {
        netmask = 22
      }
    }

    vpc = {
      availability_zones     = 2
      enable_ipam            = true
      enable_transit_gateway = true
    }
  }

  my_second_vpc = {
    subnets = {
      private = {
        netmask = 28
      }
    }

    vpc = {
      enable_ipam            = true
      enable_transit_gateway = true
    }
  }
}
```

### Transit Gateway Connectivity

When network have defined the `enable_transit_gateway` boolean it is the responsibility of the consumer of this module to have defined the correct transit gateway id and any default routing requirements.

Assuming the following configuration

```hcl
module "my_account" {
  ...
  networks = {
    dev = {
      vpc = {
        enable_transit_gateway = true
        ipam_pool_name = "development"
        netmask        = 21
      }

      transit_gateway = {
        gateway_id = "tgw-1234567890"
        gateway_routes = {
          private = "10.0.0.0/8"
        }
      }

      subnets = {
        private = {
          netmask = 24
        }
      }
    },
  }
```

We can also create transit gateway route table associations by extending the above configuration

```hcl
module "my_account" {
  ...
  networks = {
    dev = {
      vpc = {
        enable_transit_gateway = true
        ipam_pool_name = "development"
        netmask        = 21
      }

      transit_gateway = {
        gateway_id = "tgw-1234567890"
        gateway_routes = {
          private = "10.0.0.0/8"
        }
        gateway_route_table_id = "rtb-1234567890"
      }
    }
  }
}
```

## Update Documentation

The `terraform-docs` utility is used to generate this README. Follow the below steps to update:

1. Make changes to the `.terraform-docs.yml` file
2. Fetch the `terraform-docs` binary (https://terraform-docs.io/user-guide/installation/)
3. Run `terraform-docs markdown table --output-file ${PWD}/README.md --output-mode inject .`

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | ~> 2.0 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0.0 |
| <a name="provider_aws.identity"></a> [aws.identity](#provider\_aws.identity) | >= 5.0.0 |
| <a name="provider_aws.management"></a> [aws.management](#provider\_aws.management) | >= 5.0.0 |
| <a name="provider_aws.network"></a> [aws.network](#provider\_aws.network) | >= 5.0.0 |
| <a name="provider_aws.tenant"></a> [aws.tenant](#provider\_aws.tenant) | >= 5.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | The environment in which to provision resources | `string` | n/a | yes |
| <a name="input_git_repository"></a> [git\_repository](#input\_git\_repository) | The git repository to use for the account | `string` | n/a | yes |
| <a name="input_home_region"></a> [home\_region](#input\_home\_region) | The home region in which to provision global resources | `string` | n/a | yes |
| <a name="input_owner"></a> [owner](#input\_owner) | The owner of the product, and injected into all resource tags | `string` | n/a | yes |
| <a name="input_product"></a> [product](#input\_product) | The name of the product to provision resources and inject into all resource tags | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A collection of tags to apply to resources | `map(string)` | n/a | yes |
| <a name="input_aws_config"></a> [aws\_config](#input\_aws\_config) | Account specific configuration for AWS Config | <pre>object({<br/>    enable = optional(bool, false)<br/>    # A flag indicating if AWS Config should be enabled<br/>    compliance_packs = map(object({<br/>      parameter_overrides = optional(map(string), {})<br/>      # A map of parameter overrides to apply to the compliance pack<br/>      template_url = optional(string, "")<br/>      # The URL of the compliance pack<br/>      template_body = optional(string, "")<br/>    }))<br/>    ## A list of compliance packs to provision in the account<br/>  })</pre> | <pre>{<br/>  "compliance_packs": {},<br/>  "enable": false<br/>}</pre> | no |
| <a name="input_budgets"></a> [budgets](#input\_budgets) | A collection of budgets to provision | <pre>list(object({<br/>    name         = string<br/>    budget_type  = optional(string, "COST")<br/>    limit_amount = optional(string, "100.0")<br/>    limit_unit   = optional(string, "PERCENTAGE")<br/>    time_unit    = optional(string, "MONTHLY")<br/><br/>    notification = optional(object({<br/>      comparison_operator = string<br/>      threshold           = number<br/>      threshold_type      = string<br/>      notification_type   = string<br/>    }), null)<br/><br/>    auto_adjust_data = optional(list(object({<br/>      auto_adjust_type = string<br/>    })), [])<br/><br/>    cost_filter = optional(list(object({<br/>      name   = string<br/>      values = list(string)<br/>    })), [])<br/><br/>    cost_types = optional(object({<br/>      include_credit             = optional(bool, false)<br/>      include_discount           = optional(bool, false)<br/>      include_other_subscription = optional(bool, false)<br/>      include_recurring          = optional(bool, false)<br/>      include_refund             = optional(bool, false)<br/>      include_subscription       = optional(bool, false)<br/>      include_support            = optional(bool, false)<br/>      include_tax                = optional(bool, false)<br/>      include_upfront            = optional(bool, false)<br/>      use_blended                = optional(bool, false)<br/>      }), {<br/>      include_credit             = false<br/>      include_discount           = false<br/>      include_other_subscription = false<br/>      include_recurring          = false<br/>      include_refund             = false<br/>      include_subscription       = true<br/>      include_support            = false<br/>      include_tax                = false<br/>      include_upfront            = false<br/>      use_blended                = false<br/>    })<br/><br/>    tags = optional(map(string), {})<br/>  }))</pre> | `[]` | no |
| <a name="input_central_dns"></a> [central\_dns](#input\_central\_dns) | Configuration for the hub used to centrally resolved dns requests | <pre>object({<br/>    enable = optional(bool, false)<br/>    # The domain name to use for the central DNS<br/>    vpc_id = optional(string, null)<br/>  })</pre> | <pre>{<br/>  "enable": false,<br/>  "vpc_id": null<br/>}</pre> | no |
| <a name="input_cost_anomaly_detection"></a> [cost\_anomaly\_detection](#input\_cost\_anomaly\_detection) | A collection of cost anomaly detection monitors to apply to the account | <pre>object({<br/>    enable = optional(bool, true)<br/>    # A flag indicating if the default monitors should be enabled<br/>    monitors = optional(list(object({<br/>      name = string<br/>      # The name of the anomaly detection rule<br/>      frequency = optional(string, "IMMEDIATE")<br/>      # The dimension of the anomaly detection rule, either SERVICE or DIMENSIONAL<br/>      threshold_expression = optional(list(object({<br/>        and = object({<br/>          dimension = object({<br/>            key = string<br/>            # The key of the dimension<br/>            match_options = list(string)<br/>            # The match options of the dimension<br/>            values = list(string)<br/>            # The values of the dimension<br/>          })<br/>        })<br/>        # The expression to apply to the cost anomaly detection monitor<br/>      })), [])<br/>      # The expression to apply to the anomaly detection rule<br/>      # see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ce_anomaly_monitor<br/>      specification = optional(string, "")<br/>      # The specification to anomaly detection monitor<br/>      # see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ce_anomaly_monitor<br/>    })), [])<br/>  })</pre> | <pre>{<br/>  "enabled": true,<br/>  "monitors": []<br/>}</pre> | no |
| <a name="input_cost_center"></a> [cost\_center](#input\_cost\_center) | The cost center of the product, and injected into all resource tags | `string` | `null` | no |
| <a name="input_dns"></a> [dns](#input\_dns) | A collection of DNS zones to provision and associate with networks | <pre>map(object({<br/>    comment = optional(string, "Managed by zone created by terraform")<br/>    # A comment associated with the DNS zone<br/>    network = string<br/>    # A list of network names to associate with the DNS zone<br/>    private = optional(bool, true)<br/>    # A flag indicating if the DNS zone is private or public<br/>  }))</pre> | `{}` | no |
| <a name="input_ebs_encryption"></a> [ebs\_encryption](#input\_ebs\_encryption) | A collection of EBS encryption settings to apply to the account | <pre>object({<br/>    enable = optional(bool, false)<br/>    # A flag indicating if EBS encryption should be enabled<br/>    create_kms_key = optional(bool, true)<br/>    # A flag indicating if an EBS encryption key should be created<br/>    key_deletion_window_in_days = optional(number, 10)<br/>    # The number of days to retain the key before deletion when the key is removed<br/>    key_alias = optional(string, "lza/ebs/default")<br/>    # The alias of the EBS encryption key when provisioning a new key<br/>    key_arn = optional(string, null)<br/>    # The ARN of an existing EBS encryption key to use for EBS encryption<br/>  })</pre> | `null` | no |
| <a name="input_guardduty"></a> [guardduty](#input\_guardduty) | A collection of GuardDuty settings to apply to the account | <pre>object({<br/>    # A flag indicating if GuardDuty should be created<br/>    finding_publishing_frequency = optional(string, "FIFTEEN_MINUTES")<br/>    # The frequency of finding publishing<br/>    detectors = optional(list(object({<br/>      name = string<br/>      # The name of the detector<br/>      enable = optional(bool, true)<br/>      # The frequency of finding publishing<br/>      additional_configuration = optional(list(object({<br/>        name = string<br/>        # The name of the additional configuration<br/>        enable = optional(bool, true)<br/>        # The status of the additional configuration<br/>      })), [])<br/>    })), [])<br/>    # Configuration for the detector<br/>    filters = optional(map(object({<br/>      # The name of the filter<br/>      action = string<br/>      # The action of the filter<br/>      rank = number<br/>      # The rank of the filter<br/>      description = string<br/>      # The description of the filter<br/>      criterion = list(object({<br/>        field = string<br/>        # The field of the criterion<br/>        equals = optional(string, null)<br/>        # The equals of the criterion<br/>        not_equals = optional(string, null)<br/>        # The not equals of the criterion<br/>        greater_than = optional(string, null)<br/>        # The greater than of the criterion<br/>        greater_than_or_equal = optional(string, null)<br/>        # The greater than or equal of the criterion<br/>        less_than = optional(string, null)<br/>        # The less than of the criterion<br/>        less_than_or_equal = optional(string, null)<br/>        # The less than or equal of the criterion<br/>      }))<br/>      # The criterion of the filter<br/>    })), {})<br/>  })</pre> | `null` | no |
| <a name="input_iam_access_analyzer"></a> [iam\_access\_analyzer](#input\_iam\_access\_analyzer) | The IAM access analyzer configuration to apply to the account | <pre>object({<br/>    enable = optional(bool, false)<br/>    # A flag indicating if IAM access analyzer should be enabled<br/>    analyzer_name = optional(string, "lza-iam-access-analyzer")<br/>    # The name of the IAM access analyzer<br/>    analyzer_type = optional(string, "ORGANIZATION")<br/>    # The type of the IAM access analyzer<br/>  })</pre> | <pre>{<br/>  "analyzer_name": "lza-iam-access-analyzer",<br/>  "analyzer_type": "ORGANIZATION",<br/>  "enabled": false<br/>}</pre> | no |
| <a name="input_iam_password_policy"></a> [iam\_password\_policy](#input\_iam\_password\_policy) | The IAM password policy to apply to the account | <pre>object({<br/>    enable = optional(bool, false)<br/>    # A flag indicating if IAM password policy should be enabled<br/>    allow_users_to_change_password = optional(bool, true)<br/>    # A flag indicating if users can change their password<br/>    hard_expiry = optional(bool, false)<br/>    # A flag indicating if a hard expiry should be enforced<br/>    max_password_age = optional(number, 90)<br/>    # The maximum password age<br/>    minimum_password_length = optional(number, 8)<br/>    # The minimum password length<br/>    password_reuse_prevention = optional(number, 24)<br/>    # The number of passwords to prevent reuse<br/>    require_lowercase_characters = optional(bool, true)<br/>    # A flag indicating if lowercase characters are required<br/>    require_numbers = optional(bool, true)<br/>    # A flag indicating if numbers are required<br/>    require_symbols = optional(bool, true)<br/>    # A flag indicating if symbols are required<br/>    require_uppercase_characters = optional(bool, true)<br/>    # A flag indicating if uppercase characters are required<br/>  })</pre> | <pre>{<br/>  "allow_users_to_change_password": true,<br/>  "hard_expiry": false,<br/>  "max_password_age": 90,<br/>  "minimum_password_length": 8,<br/>  "password_reuse_prevention": 24,<br/>  "require_lowercase_characters": true,<br/>  "require_numbers": true,<br/>  "require_symbols": true,<br/>  "require_uppercase_characters": true<br/>}</pre> | no |
| <a name="input_iam_policies"></a> [iam\_policies](#input\_iam\_policies) | A collection of IAM policies to apply to the account | <pre>map(object({<br/>    name = optional(string, null)<br/>    # The name of the IAM policy<br/>    name_prefix = optional(string, null)<br/>    # The name prefix of the IAM policy<br/>    description = string<br/>    # The description of the IAM policy<br/>    path = optional(string, "/")<br/>    # The path of the IAM policy<br/>    policy = string<br/>    # The policy document to apply to the IAM policy<br/>  }))</pre> | `{}` | no |
| <a name="input_iam_roles"></a> [iam\_roles](#input\_iam\_roles) | A collection of IAM roles to apply to the account | <pre>map(object({<br/>    name = optional(string, null)<br/>    # The name of the IAM role<br/>    name_prefix = optional(string, null)<br/>    # The name prefix of the IAM role<br/>    assume_accounts = optional(list(string), [])<br/>    # List of accounts to assume the role<br/>    assume_roles = optional(list(string), [])<br/>    # List of principals to assume the role<br/>    assume_services = optional(list(string), [])<br/>    # List of services to assume the role<br/>    description = string<br/>    # The description of the IAM role<br/>    path = optional(string, "/")<br/>    # The path of the IAM role<br/>    permission_boundary_arn = optional(string, "")<br/>    # A collection of tags to apply to the IAM role<br/>    permission_arns = optional(list(string), [])<br/>    # A list of additional permissions to apply to the IAM role<br/>    policies = optional(any, [])<br/>  }))</pre> | `{}` | no |
| <a name="input_iam_service_linked_roles"></a> [iam\_service\_linked\_roles](#input\_iam\_service\_linked\_roles) | A collection of service linked roles to apply to the account | `list(string)` | `[]` | no |
| <a name="input_identity_center_permitted_roles"></a> [identity\_center\_permitted\_roles](#input\_identity\_center\_permitted\_roles) | A map of permitted SSO roles, with the name of the permitted SSO role as the key, and value the permissionset | `map(string)` | <pre>{<br/>  "network_viewer": "NetworkViewer",<br/>  "security_auditor": "SecurityAuditor"<br/>}</pre> | no |
| <a name="input_include_iam_roles"></a> [include\_iam\_roles](#input\_include\_iam\_roles) | Collection of IAM roles to include in the account | <pre>object({<br/>    security_auditor = object({<br/>      enable = optional(bool, false)<br/>      name   = optional(string, "lza-security-auditor")<br/>    })<br/>    ssm_instance = object({<br/>      enable = optional(bool, false)<br/>      name   = optional(string, "lza-ssm-instance")<br/>    })<br/>  })</pre> | <pre>{<br/>  "security_auditor": {<br/>    "enable": false,<br/>    "name": "lza-security-auditor"<br/>  },<br/>  "ssm_instance": {<br/>    "enable": false,<br/>    "name": "lza-ssm-instance"<br/>  }<br/>}</pre> | no |
| <a name="input_kms_administrator"></a> [kms\_administrator](#input\_kms\_administrator) | Configuration for the default kms administrator role to use for the account | <pre>object({<br/>    # The domain name to use for the central DNS<br/>    assume_accounts = optional(list(string), [])<br/>    # A list of roles to assume the kms administrator role<br/>    assume_roles = optional(list(string), [])<br/>    # A list of roles to assume the kms administrator role<br/>    assume_services = optional(list(string), [])<br/>    # A list of services to assume the kms administrator role<br/>    description = optional(string, null)<br/>    # The description of the default kms administrator role<br/>    enable = optional(bool, false)<br/>    # A flag indicating if the default kms administrator role should be enabled<br/>    enable_account_root = optional(bool, false)<br/>    # A flag indicating if the account root should be enabled<br/>    name = optional(string, "lza-kms-adminstrator")<br/>    # The name of the default kms administrator role<br/>  })</pre> | <pre>{<br/>  "assume_accounts": [],<br/>  "assume_roles": [],<br/>  "assume_services": [],<br/>  "description": "Provides access to administer the KMS keys for the account",<br/>  "enable": false,<br/>  "enable_account_root": false,<br/>  "name": "lza-kms-adminstrator"<br/>}</pre> | no |
| <a name="input_kms_key"></a> [kms\_key](#input\_kms\_key) | Configuration for the default kms encryption key to use for the account (per region) | <pre>object({<br/>    enable = optional(bool, false)<br/>    # A flag indicating if account encryption should be enabled<br/>    key_deletion_window_in_days = optional(number, 7)<br/>    # The number of days to retain the key before deletion when the key is removed<br/>    key_alias = optional(string, null)<br/>    # The alias of the account encryption key when provisioning a new key<br/>    key_administrators = optional(list(string), [])<br/>    # A list of ARN of the key administrators<br/>  })</pre> | <pre>{<br/>  "enabled": false,<br/>  "key_administrators": [],<br/>  "key_alias": "lza/account/default",<br/>  "key_deletion_window_in_days": 10<br/>}</pre> | no |
| <a name="input_macie"></a> [macie](#input\_macie) | A collection of Macie settings to apply to the account | <pre>object({<br/>    enable = optional(bool, false)<br/>    # A flag indicating if Macie should be enabled<br/>    frequency = optional(string, "FIFTEEN_MINUTES")<br/>    # The frequency of Macie findings<br/>    admin_account_id = optional(string, null)<br/>    # Is defined the member account will accept any invitations from the management account<br/>  })</pre> | `null` | no |
| <a name="input_networks"></a> [networks](#input\_networks) | A collection of networks to provision within the designated region | <pre>map(object({<br/>    firewall = optional(object({<br/>      capacity = number<br/>      # The capacity of the firewall rule group<br/>      rules_source = string<br/>      # The content of the suracata rules<br/>      ip_sets = map(list(string))<br/>      # A map of IP sets to apply to the firewall rule ie. WEBSERVERS = ["100.0.0.0/16"]<br/>      port_sets = map(list(number))<br/>      # A map of port sets to apply to the firewall rule ie. WEBSERVERS = [80, 443]<br/>      domains_whitelist = list(string)<br/>    }), null)<br/><br/>    subnets = map(object({<br/>      cidr = optional(string, null)<br/>      # The CIDR block of the subnet<br/>      netmask = optional(number, 0)<br/>    }))<br/><br/>    tags = optional(map(string), {})<br/>    # A collection of tags to apply to the network - these will be merged with the global tags<br/><br/>    transit_gateway = optional(object({<br/>      gateway_id = optional(string, null)<br/>      # The transit gateway ID to associate with the network<br/>      gateway_route_table_id = optional(string, null)<br/>      ## Optional id of the transit gateway route table to associate with the network<br/>      gateway_routes = optional(map(string), null)<br/>      # A map used to associate routes with subnets provisioned by the module - i.e ensure<br/>      # all private subnets push<br/>      }), {<br/>      gateway_id             = null<br/>      gateway_route_table_id = null<br/>      gateway_routes         = null<br/>    })<br/>    ## Configuration for the transit gateway for this network<br/><br/>    vpc = object({<br/>      availability_zones = optional(string, 2)<br/>      # The availability zone in which to provision the network, defaults to 2<br/>      cidr = optional(string, null)<br/>      # The CIDR block of the VPC network if not using IPAM<br/>      enable_private_endpoints = optional(list(string), [])<br/>      # An optional list of private endpoints to associate with the network i.e ["s3", "dynamodb"]<br/>      enable_shared_endpoints = optional(bool, true)<br/>      # Indicates if the network should accept shared endpoints<br/>      enable_transit_gateway = optional(bool, true)<br/>      # A flag indicating if the network should be associated with the transit gateway<br/>      enable_transit_gateway_appliance_mode = optional(bool, false)<br/>      # A flag indicating if the transit gateway should be in appliance mode<br/>      enable_default_route_table_association = optional(bool, true)<br/>      # A flag indicating if the default route table should be associated with the network<br/>      enable_default_route_table_propagation = optional(bool, true)<br/>      # A flag indicating if the default route table should be propagated to the network<br/>      ipam_pool_name = optional(string, null)<br/>      # The name of the IPAM pool to use for the network<br/>      nat_gateway_mode = optional(string, "none")<br/>      # The NAT gateway mode to use for the network, defaults to none<br/>      netmask = optional(number, null)<br/>      # The netmask of the VPC network if using IPAM<br/>      transit_gateway_routes = optional(map(string), null)<br/>      # A list of routes to associate with the transit gateway, optional<br/>    })<br/>  }))</pre> | `{}` | no |
| <a name="input_notifications"></a> [notifications](#input\_notifications) | Configuration for the notifications to the owner of the account | <pre>object({<br/>    email = optional(object({<br/>      addresses = optional(list(string), [])<br/>      # A list of email addresses to send notifications to<br/>      }), {<br/>      addresses = []<br/>    })<br/><br/>    slack = optional(object({<br/>      webhook_url = optional(string, "")<br/>      # The slack webhook_url to send notifications to<br/>      }), {<br/>      webhook_url = null<br/>    })<br/><br/>    teams = optional(object({<br/>      webhook_url = optional(string, "")<br/>      # The teams webhook_url to send notifications to<br/>      }), {<br/>      webhook_url = null<br/>    })<br/><br/>    services = optional(object({<br/>      securityhub = object({<br/>        enable = optional(bool, false)<br/>        # A flag indicating if security hub notifications should be enabled<br/>        eventbridge_rule_name = optional(string, "lza-securityhub-eventbridge")<br/>        # The sns topic name which is created per region in the account,<br/>        # this is used to receive notifications, and forward them on via email or other means.<br/>        lambda_name = optional(string, "lza-securityhub-slack-forwarder")<br/>        # The name of the lambda which will be used to forward the security hub events to slack<br/>        lambda_role_name = optional(string, "lza-securityhub-slack-forwarder")<br/>        # The name of the eventbridge rule which is used to forward the security hub events to the lambda<br/>        severity = optional(list(string), ["CRITICAL"])<br/>      })<br/>      }), {<br/>      securityhub = {<br/>        enable = false<br/>      }<br/>    })<br/>  })</pre> | <pre>{<br/>  "email": {<br/>    "addresses": []<br/>  },<br/>  "services": {<br/>    "securityhub": {<br/>      "enable": false,<br/>      "eventbridge_rule_name": "lza-securityhub-eventbridge",<br/>      "lambda_name": "lza-securityhub-slack-forwarder",<br/>      "lambda_role_name": "lza-securityhub-slack-forwarder",<br/>      "severity": [<br/>        "CRITICAL"<br/>      ]<br/>    }<br/>  },<br/>  "slack": {<br/>    "webhook_url": null<br/>  },<br/>  "teams": {<br/>    "webhook_url": null<br/>  }<br/>}</pre> | no |
| <a name="input_rbac"></a> [rbac](#input\_rbac) | Provides the ability to associate one of more groups with a sso role in the account | <pre>map(object({<br/>    users = optional(list(string), [])<br/>    # A list of users to associate with the developer role<br/>    groups = optional(list(string), [])<br/>    # A list of groups to associate with the developer role<br/>  }))</pre> | `{}` | no |
| <a name="input_s3_block_public_access"></a> [s3\_block\_public\_access](#input\_s3\_block\_public\_access) | A collection of S3 public block access settings to apply to the account | <pre>object({<br/>    enable = optional(bool, false)<br/>    # A flag indicating if S3 block public access should be enabled<br/>    enable_block_public_policy = optional(bool, true)<br/>    # A flag indicating if S3 block public policy should be enabled<br/>    enable_block_public_acls = optional(bool, true)<br/>    # A flag indicating if S3 block public ACLs should be enabled<br/>    enable_ignore_public_acls = optional(bool, true)<br/>    # A flag indicating if S3 ignore public ACLs should be enabled<br/>    enable_restrict_public_buckets = optional(bool, true)<br/>    # A flag indicating if S3 restrict public buckets should be enabled<br/>  })</pre> | <pre>{<br/>  "enable_block_public_acls": true,<br/>  "enable_block_public_policy": true,<br/>  "enable_ignore_public_acls": true,<br/>  "enable_restrict_public_buckets": true,<br/>  "enabled": false<br/>}</pre> | no |
| <a name="input_service_control_policies"></a> [service\_control\_policies](#input\_service\_control\_policies) | Provides the ability to associate one of more service control policies with an account | <pre>map(object({<br/>    name = string<br/>    # The policy name to associate with the account<br/>    policy = string<br/>    # The policy document to associate with the account<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_id"></a> [account\_id](#output\_account\_id) | The account id where the pipeline is running |
| <a name="output_auditor_account_id"></a> [auditor\_account\_id](#output\_auditor\_account\_id) | The account id for the audit account |
| <a name="output_environment"></a> [environment](#output\_environment) | The environment name for the tenant |
| <a name="output_log_archive_account_id"></a> [log\_archive\_account\_id](#output\_log\_archive\_account\_id) | The account id for the log archive account |
| <a name="output_networks"></a> [networks](#output\_networks) | A map of the network name to network details |
| <a name="output_private_hosted_zones"></a> [private\_hosted\_zones](#output\_private\_hosted\_zones) | A map of the private hosted zones |
| <a name="output_private_hosted_zones_by_id"></a> [private\_hosted\_zones\_by\_id](#output\_private\_hosted\_zones\_by\_id) | A map of the hosted zone name to id |
| <a name="output_sns_notification_arn"></a> [sns\_notification\_arn](#output\_sns\_notification\_arn) | The SNS topic ARN for notifications |
| <a name="output_sns_notification_name"></a> [sns\_notification\_name](#output\_sns\_notification\_name) | Name of the SNS topic used to channel notifications |
| <a name="output_tags"></a> [tags](#output\_tags) | The tags to apply to all resources |
| <a name="output_tenant_account_id"></a> [tenant\_account\_id](#output\_tenant\_account\_id) | The region of the tenant account |
| <a name="output_vpc_ids"></a> [vpc\_ids](#output\_vpc\_ids) | A map of the network name to vpc id |
<!-- END_TF_DOCS -->

```

```
