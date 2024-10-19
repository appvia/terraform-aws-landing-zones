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

## Update Documentation

The `terraform-docs` utility is used to generate this README. Follow the below steps to update:

1. Make changes to the `.terraform-docs.yml` file
2. Fetch the `terraform-docs` binary (https://terraform-docs.io/user-guide/installation/)
3. Run `terraform-docs markdown table --output-file ${PWD}/README.md --output-mode inject .`

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_archive"></a> [archive](#requirement\_archive) | ~> 2.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | ~> 2.0 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0.0 |
| <a name="provider_aws.identity"></a> [aws.identity](#provider\_aws.identity) | >= 5.0.0 |
| <a name="provider_aws.management"></a> [aws.management](#provider\_aws.management) | >= 5.0.0 |
| <a name="provider_aws.network"></a> [aws.network](#provider\_aws.network) | >= 5.0.0 |
| <a name="provider_aws.tenant"></a> [aws.tenant](#provider\_aws.tenant) | >= 5.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_anomaly_detection"></a> [anomaly\_detection](#module\_anomaly\_detection) | appvia/anomaly-detection/aws | 0.2.7 |
| <a name="module_ebs_kms"></a> [ebs\_kms](#module\_ebs\_kms) | terraform-aws-modules/kms/aws | 3.1.1 |
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | terraform-aws-modules/iam/aws//modules/iam-assumable-role | 5.46.0 |
| <a name="module_kms"></a> [kms](#module\_kms) | terraform-aws-modules/kms/aws | 3.1.1 |
| <a name="module_networks"></a> [networks](#module\_networks) | appvia/network/aws | 0.3.2 |
| <a name="module_notifications"></a> [notifications](#module\_notifications) | appvia/notifications/aws | 1.0.5 |
| <a name="module_securityhub_notifications"></a> [securityhub\_notifications](#module\_securityhub\_notifications) | appvia/notifications/aws | 1.0.5 |
| <a name="module_sso_assignment"></a> [sso\_assignment](#module\_sso\_assignment) | ./modules/sso_assignment | n/a |
| <a name="module_tagging"></a> [tagging](#module\_tagging) | appvia/tagging/null | 0.0.5 |

## Resources

| Name | Type |
|------|------|
| [aws_accessanalyzer_analyzer.iam_access_analyzer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/accessanalyzer_analyzer) | resource |
| [aws_cloudwatch_event_rule.securityhub_findings](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.security_hub_findings_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_log_group.securityhub_lambda_log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ebs_default_kms_key.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_default_kms_key) | resource |
| [aws_ebs_encryption_by_default.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_encryption_by_default) | resource |
| [aws_iam_account_password_policy.iam_account_password_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_account_password_policy) | resource |
| [aws_iam_policy.iam_policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.securityhub_lambda_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.securityhub_lambda_logs_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.securityhub_lambda_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_lambda_function.securityhub_lambda_function](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.securityhub_event_bridge](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_macie2_account.macie_member](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/macie2_account) | resource |
| [aws_organizations_policy.service_control_policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_policy) | resource |
| [aws_route53_vpc_association_authorization.central_dns_authorization](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_vpc_association_authorization) | resource |
| [aws_route53_zone.zones](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |
| [aws_route53_zone_association.central_dns_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone_association) | resource |
| [aws_s3_account_public_access_block.s3_account_public_access_block](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_account_public_access_block) | resource |
| [archive_file.securityhub_lambda_package](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_caller_identity.tenant](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.ebs_encryption_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.securityhub_notifications_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_secretsmanager_secret.slack](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) | data source |
| [aws_secretsmanager_secret_version.slack](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |
| [aws_ssoadmin_instances.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssoadmin_instances) | data source |
| [aws_vpc_ipam_pools.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_ipam_pools) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | The environment in which to provision resources | `string` | n/a | yes |
| <a name="input_home_region"></a> [home\_region](#input\_home\_region) | The home region in which to provision global resources | `string` | n/a | yes |
| <a name="input_owner"></a> [owner](#input\_owner) | The owner of the product, and injected into all resource tags | `string` | n/a | yes |
| <a name="input_product"></a> [product](#input\_product) | The name of the product to provision resources and inject into all resource tags | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The region we are provisioning the resources for the landing zone | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A collection of tags to apply to resources | `map(string)` | n/a | yes |
| <a name="input_central_dns"></a> [central\_dns](#input\_central\_dns) | Configuration for the hub used to centrally resolved dns requests | <pre>object({<br/>    enabled = optional(bool, false)<br/>    # The domain name to use for the central DNS<br/>    vpc_id = optional(string, null)<br/>  })</pre> | <pre>{<br/>  "enabled": false,<br/>  "vpc_id": null<br/>}</pre> | no |
| <a name="input_cost_anomaly_detection"></a> [cost\_anomaly\_detection](#input\_cost\_anomaly\_detection) | A collection of cost anomaly detection monitors to apply to the account | <pre>object({<br/>    enabled = optional(bool, true)<br/>    # A flag indicating if the default monitors should be enabled <br/>    monitors = optional(list(object({<br/>      name = string<br/>      # The name of the anomaly detection rule <br/>      frequency = optional(string, "IMMEDIATE")<br/>      # The dimension of the anomaly detection rule, either SERVICE or DIMENSIONAL<br/>      threshold_expression = optional(list(object({<br/>        and = object({<br/>          dimension = object({<br/>            key = string<br/>            # The key of the dimension <br/>            match_options = list(string)<br/>            # The match options of the dimension <br/>            values = list(string)<br/>            # The values of the dimension <br/>          })<br/>        })<br/>        # The expression to apply to the cost anomaly detection monitor <br/>      })), [])<br/>      # The expression to apply to the anomaly detection rule<br/>      # see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ce_anomaly_monitor<br/>      specification = optional(string, "")<br/>      # The specification to anomaly detection monitor <br/>      # see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ce_anomaly_monitor<br/>    })), [])<br/>  })</pre> | <pre>{<br/>  "enabled": true,<br/>  "monitors": []<br/>}</pre> | no |
| <a name="input_cost_center"></a> [cost\_center](#input\_cost\_center) | The cost center of the product, and injected into all resource tags | `string` | `null` | no |
| <a name="input_dns"></a> [dns](#input\_dns) | A collection of DNS zones to provision and associate with networks | <pre>map(object({<br/>    comment = optional(string, "Managed by zone created by terraform")<br/>    # A comment associated with the DNS zone <br/>    network = string<br/>    # A list of network names to associate with the DNS zone <br/>    private = optional(bool, true)<br/>    # A flag indicating if the DNS zone is private or public<br/>  }))</pre> | `{}` | no |
| <a name="input_ebs_encryption"></a> [ebs\_encryption](#input\_ebs\_encryption) | A collection of EBS encryption settings to apply to the account | <pre>object({<br/>    enabled = optional(bool, false)<br/>    # A flag indicating if EBS encryption should be enabled<br/>    create_kms_key = optional(bool, true)<br/>    # A flag indicating if an EBS encryption key should be created<br/>    key_deletion_window_in_days = optional(number, 10)<br/>    # The number of days to retain the key before deletion when the key is removed<br/>    key_alias = optional(string, "lza/ebs/default")<br/>    # The alias of the EBS encryption key when provisioning a new key<br/>    key_arn = optional(string, null)<br/>    # The ARN of an existing EBS encryption key to use for EBS encryption<br/>  })</pre> | <pre>{<br/>  "create_kms_key": true,<br/>  "enabled": false,<br/>  "key_alias": "lza/ebs/default",<br/>  "key_arn": null,<br/>  "key_deletion_window_in_days": 10<br/>}</pre> | no |
| <a name="input_git_repository"></a> [git\_repository](#input\_git\_repository) | The git repository to use for the account | `string` | `"https://github.com/appvia/terraform-aws-landing-zones"` | no |
| <a name="input_iam_access_analyzer"></a> [iam\_access\_analyzer](#input\_iam\_access\_analyzer) | The IAM access analyzer configuration to apply to the account | <pre>object({<br/>    enabled = optional(bool, false)<br/>    # A flag indicating if IAM access analyzer should be enabled<br/>    analyzer_name = optional(string, "lza-iam-access-analyzer")<br/>    # The name of the IAM access analyzer <br/>    analyzer_type = optional(string, "ORGANIZATION")<br/>    # The type of the IAM access analyzer<br/>  })</pre> | <pre>{<br/>  "analyzer_name": "lza-iam-access-analyzer",<br/>  "analyzer_type": "ORGANIZATION",<br/>  "enabled": false<br/>}</pre> | no |
| <a name="input_iam_password_policy"></a> [iam\_password\_policy](#input\_iam\_password\_policy) | The IAM password policy to apply to the account | <pre>object({<br/>    enabled = optional(bool, false)<br/>    # A flag indicating if IAM password policy should be enabled<br/>    allow_users_to_change_password = optional(bool, true)<br/>    # A flag indicating if users can change their password <br/>    hard_expiry = optional(bool, false)<br/>    # A flag indicating if a hard expiry should be enforced <br/>    max_password_age = optional(number, 90)<br/>    # The maximum password age <br/>    minimum_password_length = optional(number, 8)<br/>    # The minimum password length <br/>    password_reuse_prevention = optional(number, 24)<br/>    # The number of passwords to prevent reuse <br/>    require_lowercase_characters = optional(bool, true)<br/>    # A flag indicating if lowercase characters are required <br/>    require_numbers = optional(bool, true)<br/>    # A flag indicating if numbers are required <br/>    require_symbols = optional(bool, true)<br/>    # A flag indicating if symbols are required <br/>    require_uppercase_characters = optional(bool, true)<br/>    # A flag indicating if uppercase characters are required <br/>  })</pre> | <pre>{<br/>  "allow_users_to_change_password": true,<br/>  "hard_expiry": false,<br/>  "max_password_age": 90,<br/>  "minimum_password_length": 8,<br/>  "password_reuse_prevention": 24,<br/>  "require_lowercase_characters": true,<br/>  "require_numbers": true,<br/>  "require_symbols": true,<br/>  "require_uppercase_characters": true<br/>}</pre> | no |
| <a name="input_iam_policies"></a> [iam\_policies](#input\_iam\_policies) | A collection of IAM policies to apply to the account | <pre>map(object({<br/>    name = optional(string, null)<br/>    # The name of the IAM policy <br/>    name_prefix = optional(string, null)<br/>    # The name prefix of the IAM policy <br/>    description = string<br/>    # The description of the IAM policy <br/>    path = optional(string, "/")<br/>    # The path of the IAM policy<br/>    policy = string<br/>    # The policy document to apply to the IAM policy <br/>  }))</pre> | `{}` | no |
| <a name="input_iam_roles"></a> [iam\_roles](#input\_iam\_roles) | A collection of IAM roles to apply to the account | <pre>map(object({<br/>    name = optional(string, null)<br/>    # The name of the IAM role <br/>    name_prefix = optional(string, null)<br/>    # The name prefix of the IAM role <br/>    assume_accounts = optional(list(string), [])<br/>    # List of accounts to assume the role<br/>    assume_roles = optional(list(string), [])<br/>    # List of principals to assume the role<br/>    assume_services = optional(list(string), [])<br/>    # List of services to assume the role<br/>    description = string<br/>    # The description of the IAM role <br/>    path = optional(string, "/")<br/>    # The path of the IAM role<br/>    permissions_boundary_arn = optional(string, "")<br/>    # A collection of tags to apply to the IAM role <br/>    permissions_arns = optional(list(string), [])<br/>    # A list of additional permissions to apply to the IAM role <br/>    policies = optional(any, [])<br/>  }))</pre> | `{}` | no |
| <a name="input_identity_center_permitted_roles"></a> [identity\_center\_permitted\_roles](#input\_identity\_center\_permitted\_roles) | A map of permitted SSO roles, with the name of the permitted SSO role as the key, and value the permissionset | `map(string)` | <pre>{<br/>  "network_viewer": "NetworkViewer",<br/>  "security_auditor": "SecurityAuditor"<br/>}</pre> | no |
| <a name="input_kms"></a> [kms](#input\_kms) | Configuration for the KMS key to use for encryption | <pre>object({<br/>    enable_default_kms = optional(bool, true)<br/>    # A flag indicating if the default KMS key should be enabled <br/>    key_alias = optional(string, "landing-zone/default")<br/>  })</pre> | <pre>{<br/>  "enable_default_kms": true<br/>}</pre> | no |
| <a name="input_macie"></a> [macie](#input\_macie) | A collection of Macie settings to apply to the account | <pre>object({<br/>    enabled = optional(bool, false)<br/>  })</pre> | <pre>{<br/>  "enabled": false<br/>}</pre> | no |
| <a name="input_networks"></a> [networks](#input\_networks) | A collection of networks to provision within the designated region | <pre>map(object({<br/>    firewall = optional(object({<br/>      capacity = number<br/>      # The capacity of the firewall rule group <br/>      rules_source = string<br/>      # The content of the suracata rules<br/>      ip_sets = map(list(string))<br/>      # A map of IP sets to apply to the firewall rule ie. WEBSERVERS = ["100.0.0.0/16"]<br/>      port_sets = map(list(number))<br/>      # A map of port sets to apply to the firewall rule ie. WEBSERVERS = [80, 443] <br/>      domains_whitelist = list(string)<br/>    }), null)<br/><br/>    subnets = map(object({<br/>      cidr = optional(string, null)<br/>      # The CIDR block of the subnet <br/>      netmask = optional(number, 0)<br/>    }))<br/><br/>    tags = optional(map(string), {})<br/>    # A collection of tags to apply to the network - these will be merged with the global tags<br/><br/>    vpc = object({<br/>      availability_zones = optional(string, 2)<br/>      # The availability zone in which to provision the network, defaults to 2 <br/>      cidr = optional(string, null)<br/>      # The CIDR block of the VPC network if not using IPAM<br/>      enable_private_endpoints = optional(list(string), [])<br/>      # An optional list of private endpoints to associate with the network i.e ["s3", "dynamodb"]<br/>      enable_shared_endpoints = optional(bool, true)<br/>      # Indicates if the network should accept shared endpoints <br/>      enable_transit_gateway = optional(bool, true)<br/>      # A flag indicating if the network should be associated with the transit gateway <br/>      enable_transit_gateway_appliance_mode = optional(bool, false)<br/>      # A flag indicating if the transit gateway should be in appliance mode<br/>      enable_default_route_table_association = optional(bool, true)<br/>      # A flag indicating if the default route table should be associated with the network <br/>      enable_default_route_table_propagation = optional(bool, true)<br/>      # A flag indicating if the default route table should be propagated to the network<br/>      ipam_pool_name = optional(string, null)<br/>      # The name of the IPAM pool to use for the network<br/>      nat_gateway_mode = optional(string, "none")<br/>      # The NAT gateway mode to use for the network, defaults to none <br/>      netmask = optional(number, null)<br/>      # The netmask of the VPC network if using IPAM<br/>      transit_gateway_routes = optional(map(string), null)<br/>      # A list of routes to associate with the transit gateway, optional <br/>    })<br/>  }))</pre> | `{}` | no |
| <a name="input_notifications"></a> [notifications](#input\_notifications) | A collection of notifications to send to users | <pre>object({<br/>    email = optional(object({<br/>      addresses = list(string)<br/>      # A list of email addresses to send notifications to <br/>      }), {<br/>      addresses = []<br/>    })<br/>    slack = optional(object({<br/>      webhook_url = string<br/>      # The slack webhook_url to send notifications to <br/>      }), {<br/>      webhook_url = ""<br/>    })<br/>  })</pre> | <pre>{<br/>  "email": {<br/>    "addresses": []<br/>  },<br/>  "slack": {<br/>    "webhook_url": ""<br/>  }<br/>}</pre> | no |
| <a name="input_rbac"></a> [rbac](#input\_rbac) | Provides the ability to associate one of more groups with a sso role in the account | <pre>map(object({<br/>    users = optional(list(string), [])<br/>    # A list of users to associate with the developer role<br/>    groups = optional(list(string), [])<br/>    # A list of groups to associate with the developer role <br/>  }))</pre> | `{}` | no |
| <a name="input_s3_block_public_access"></a> [s3\_block\_public\_access](#input\_s3\_block\_public\_access) | A collection of S3 public block access settings to apply to the account | <pre>object({<br/>    enabled = optional(bool, false)<br/>    # A flag indicating if S3 block public access should be enabled<br/>    enable_block_public_policy = optional(bool, true)<br/>    # A flag indicating if S3 block public policy should be enabled<br/>    enable_block_public_acls = optional(bool, true)<br/>    # A flag indicating if S3 block public ACLs should be enabled<br/>    enable_ignore_public_acls = optional(bool, true)<br/>    # A flag indicating if S3 ignore public ACLs should be enabled<br/>    enable_restrict_public_buckets = optional(bool, true)<br/>    # A flag indicating if S3 restrict public buckets should be enabled<br/>  })</pre> | <pre>{<br/>  "enable_block_public_acls": true,<br/>  "enable_block_public_policy": true,<br/>  "enable_ignore_public_acls": true,<br/>  "enable_restrict_public_buckets": true,<br/>  "enabled": false<br/>}</pre> | no |
| <a name="input_service_control_policies"></a> [service\_control\_policies](#input\_service\_control\_policies) | Provides the ability to associate one of more service control policies with an account | <pre>map(object({<br/>    name = string<br/>    # The policy name to associate with the account <br/>    policy = string<br/>    # The policy document to associate with the account <br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_id"></a> [account\_id](#output\_account\_id) | The account id where the pipeline is running |
| <a name="output_environment"></a> [environment](#output\_environment) | The environment name for the tenant |
| <a name="output_networks"></a> [networks](#output\_networks) | A map of the network name to network details |
| <a name="output_private_hosted_zones"></a> [private\_hosted\_zones](#output\_private\_hosted\_zones) | A map of the private hosted zones |
| <a name="output_private_hosted_zones_by_id"></a> [private\_hosted\_zones\_by\_id](#output\_private\_hosted\_zones\_by\_id) | A map of the hosted zone name to id |
| <a name="output_tags"></a> [tags](#output\_tags) | The tags to apply to all resources |
| <a name="output_tenant_account_id"></a> [tenant\_account\_id](#output\_tenant\_account\_id) | The region of the tenant account |
| <a name="output_vpc_ids"></a> [vpc\_ids](#output\_vpc\_ids) | A map of the network name to vpc id |
<!-- END_TF_DOCS -->

```

```
