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

AWS Config Conformance Packs are collections of AWS Config rules and remediation actions that are packaged together for common compliance and security best practices. You can configure compliance packs using the `var.aws_config` variable to ensure your account meets specific compliance requirements.

Compliance packs can be created using either a template body (YAML or JSON) or a template URL. You can also override default parameters in the compliance pack template to customize the rules for your specific requirements.

#### Basic Compliance Pack Configuration

```hcl
module "account" {
  aws_config = {
    enable = true
    compliance_packs = {
      "security-best-practices" = {
        template_body = file("${path.module}/templates/security-best-practices.yml")
      }
    }
  }
}
```

#### Compliance Pack with Template URL

```hcl
data "http" "security_hub_enabled" {
  url = "https://s3.amazonaws.com/aws-service-catalog-reference-architectures/AWS_Config_Rules/Security/SecurityHub/SecurityHub-Enabled.json"
}

module "account" {
  aws_config = {
    enable = true
    compliance_packs = {
      "security-hub-enabled" = {
        template_body = data.http.security_hub_enabled.body
      }
    }
  }
}
```

#### Compliance Pack with Parameter Overrides

Many compliance packs support parameter overrides that allow you to customize the behavior of the rules within the pack. For example, you can adjust thresholds, specify resource types, or configure other rule-specific settings.

```hcl
module "account" {
  aws_config = {
    enable = true
    compliance_packs = {
      "hipaa-compliance" = {
        template_body = file("${path.module}/templates/hipaa-compliance.yml")
        parameter_overrides = {
          "AccessKeysRotatedParamMaxAccessKeyAge" = "45"
          "PasswordPolicyParamMinimumPasswordLength" = "14"
          "PasswordPolicyParamRequireUppercaseCharacters" = "true"
          "PasswordPolicyParamRequireLowercaseCharacters" = "true"
          "PasswordPolicyParamRequireNumbers" = "true"
          "PasswordPolicyParamRequireSymbols" = "true"
        }
      }
      "pci-dss-compliance" = {
        template_body = file("${path.module}/templates/pci-dss-compliance.yml")
        parameter_overrides = {
          "EncryptedVolumesParamKmsKeyId" = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
        }
      }
    }
  }
}
```

#### Compliance Pack Configuration Options

The compliance pack configuration supports the following options:

- **template_body**: (Required) The YAML or JSON template body for the compliance pack. This can be provided directly as a string, loaded from a file using `file()`, or fetched from a URL using `data.http`.
- **template_url**: (Optional) The URL of the compliance pack template. Note: Either `template_body` or `template_url` must be provided, but not both.
- **parameter_overrides**: (Optional) A map of parameter overrides to customize the compliance pack rules. The keys should match the parameter names defined in the compliance pack template, and the values are the custom values you want to apply.

#### Using AWS Managed Compliance Packs

AWS provides several pre-built compliance pack templates that you can use. These templates are available in the AWS Service Catalog and can be referenced by their S3 URLs. Common examples include:

- **Operational Best Practices**: General security and operational best practices
- **HIPAA Compliance**: Healthcare industry compliance requirements
- **PCI-DSS Compliance**: Payment card industry data security standards
- **Security Best Practices**: Security-focused configuration rules
- **CIS AWS Foundations Benchmark**: Center for Internet Security benchmarks

You can find the complete list of AWS managed compliance pack templates in the [AWS Config Conformance Pack Sample Templates](https://docs.aws.amazon.com/config/latest/developerguide/conformancepack-sample-templates.html) documentation.

#### Example: Multiple Compliance Packs

You can configure multiple compliance packs simultaneously to meet various compliance requirements:

```hcl
module "account" {
  aws_config = {
    enable = true
    compliance_packs = {
      "operational-best-practices" = {
        template_body = file("${path.module}/templates/operational-best-practices.yml")
      }
      "security-best-practices" = {
        template_body = file("${path.module}/templates/security-best-practices.yml")
        parameter_overrides = {
          "CheckPublicReadAclParam" = "true"
          "CheckPublicWriteAclParam" = "true"
        }
      }
      "cis-aws-foundations-benchmark" = {
        template_body = file("${path.module}/templates/cis-aws-foundations-benchmark.yml")
        parameter_overrides = {
          "AccessKeysRotatedParamMaxAccessKeyAge" = "90"
        }
      }
    }
  }
}
```

**Note**: Ensure that AWS Config is enabled (`enable = true`) in the `aws_config` variable for compliance packs to be provisioned. The compliance packs will be deployed to the account and will continuously evaluate your resources against the rules defined in the pack.

### AWS Config Rules

You can configure additional AWS Config managed rules using the `var.aws_config` variable. AWS Config rules allow you to evaluate the configuration settings of your AWS resources to ensure they comply with your organization's policies.

```hcl
module "account" {
  aws_config = {
    enable = true
    rules = {
      "encrypted-volumes" = {
        description = "Checks whether EBS volumes are encrypted"
        identifier = "ENCRYPTED_VOLUMES"
        resource_types = ["AWS::EC2::Volume"]
      }
      "s3-bucket-public-read-prohibited" = {
        description = "Checks that your S3 buckets do not allow public read access"
        identifier = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
        resource_types = ["AWS::S3::Bucket"]
      }
      "rds-instance-public-access-check" = {
        description = "Checks whether the Amazon Relational Database Service instances are not publicly accessible"
        identifier = "RDS_INSTANCE_PUBLIC_ACCESS_CHECK"
        resource_types = ["AWS::RDS::DBInstance"]
        max_execution_frequency = "TwentyFour_Hours"
        inputs = {
          "publicAccessCheckValue" = "true"
        }
      }
      "tagged-resources" = {
        description = "Checks whether resources are properly tagged"
        identifier = "REQUIRED_TAGS"
        resource_types = ["AWS::EC2::Instance"]
        inputs = {
          "tag1Key" = "Environment"
          "tag2Key" = "Owner"
        }
        scope = {
          compliance_resource_types = ["AWS::EC2::Instance"]
          tag_key = "Environment"
          tag_value = "Production"
        }
      }
    }
  }
}
```

The rules configuration supports the following options:

- **description**: A description of what the rule checks
- **identifier**: The identifier of the AWS managed Config rule (e.g., `ENCRYPTED_VOLUMES`, `S3_BUCKET_PUBLIC_READ_PROHIBITED`)
- **resource_types**: A list of resource types that the rule evaluates (for documentation purposes)
- **inputs**: (Optional) A map of input parameters for the rule
- **max_execution_frequency**: (Optional) The maximum frequency at which the rule runs. Valid values: `One_Hour`, `Three_Hours`, `Six_Hours`, `Twelve_Hours`, `TwentyFour_Hours`
- **scope**: (Optional) Defines which resources are evaluated by the rule:
  - **compliance_resource_types**: A list of resource types to scope the rule
  - **tag_key**: (Optional) The tag key to scope the rule
  - **tag_value**: (Optional) The tag value to scope the rule

For a complete list of available AWS managed Config rules and their identifiers, see the [AWS Config Managed Rules documentation](https://docs.aws.amazon.com/config/latest/developerguide/managed-rules-by-aws-config.html).

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

### AWS Inspector

You can control the enable for disabling of the AWS Inspector service via the `var.inspector` variable, such as the below example

```hcl
module "account" {
  inspector = {
    enable = true
    delegate_account_id = "123456789012" # Usually the security account
  }
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

## Resource Groups

AWS Resource Groups allow you to organize and manage AWS resources by grouping them based on tags, resource types, or other criteria. This module provides the ability to create and manage resource groups within your account, making it easier to organize, discover, and manage related resources.

### Basic Resource Group Configuration

You can create resource groups using the `var.resource_groups` variable. The recommended approach is to use the `query` object which provides a simpler, more intuitive way to define resource queries.

```hcl
module "account" {
  resource_groups = {
    "production-ec2-instances" = {
      description = "All EC2 instances in production environment"
      query = {
        resource_type_filters = ["AWS::EC2::Instance"]
        tag_filters           = {
          "Environment" = ["production"]
        }
      }
    }
  }
}
```

### Resource Group with Tag-Based Filtering

Resource groups are commonly used to organize resources by tags, making it easier to manage resources across different environments or applications:

```hcl
module "account" {
  resource_groups = {
    "production-resources" = {
      description = "All production resources"
      query = {
        resource_type_filters = ["AWS::AllSupported"]
        tag_filters = {
          "Environment" = ["production"]
          "Product"     = ["my-product"]
        }
      }
    }
    "development-resources" = {
      description = "All development resources"
      query = {
        resource_type_filters = ["AWS::AllSupported"]
        tag_filters = {
          "Environment" = ["development"]
        }
      }
    }
  }
}
```

### Resource Group with Resource Type Filtering

You can create resource groups that include only specific resource types. If no `tag_filters` are specified, the resource group will include all resources of the specified types:

```hcl
module "account" {
  resource_groups = {
    "s3-buckets" = {
      description = "All S3 buckets in the account"
      query = {
        resource_type_filters = ["AWS::S3::Bucket"]
      }
    }
    "lambda-functions" = {
      description = "All Lambda functions"
      query = {
        resource_type_filters = ["AWS::Lambda::Function"]
      }
    }
    "rds-instances" = {
      description = "All RDS database instances"
      query = {
        resource_type_filters = ["AWS::RDS::DBInstance"]
      }
    }
  }
}
```

### Resource Group with Configuration

Resource groups can include configuration settings for specific use cases, such as AWS Systems Manager maintenance windows or other group-based operations:

```hcl
module "account" {
  resource_groups = {
    "maintenance-window-targets" = {
      description = "EC2 instances for maintenance windows"
      query = {
        resource_type_filters = ["AWS::EC2::Instance"]
        tag_filters = {
          "MaintenanceWindow" = ["enabled"]
        }
      }
      configuration = {
        type = "AWS::SSM::MaintenanceWindowTarget"
        parameters = [
          {
            name   = "WindowTargetId"
            values = ["target-123456"]
          }
        ]
      }
    }
  }
}
```

### Resource Group Configuration Options

The resource group configuration supports the following options:

- **description**: (Required) A description of the resource group
- **query**: (Optional) An object that defines the query used to select resources for the group. This is the recommended approach:
  - **resource_type_filters**: (Optional) A list of AWS resource types (e.g., `["AWS::EC2::Instance"]`, `["AWS::S3::Bucket"]`, or `["AWS::AllSupported"]`). Defaults to `["AWS::AllSupported"]` if not specified.
  - **tag_filters**: (Optional) A map where keys are tag names and values are lists of tag values. For example: `{ "Environment" = ["production"], "Product" = ["my-app"] }`
- **resource_query**: (Optional) A JSON string that defines the query used to select resources for the group. This is an alternative to the `query` object for advanced use cases or backward compatibility. The query must follow AWS Resource Groups query syntax.
- **type**: (Optional) The type of resource query. Defaults to `"TAG_FILTERS_1_0"` if not specified.
- **configuration**: (Optional) Configuration settings for the resource group:
  - **type**: The type of group configuration (e.g., `"AWS::SSM::MaintenanceWindowTarget"`)
  - **parameters**: (Optional) A list of parameters for the configuration:
    - **name**: The parameter name
    - **values**: A list of parameter values

### Using the Query Object (Recommended)

The `query` object provides a simpler and more intuitive way to define resource group queries:

```hcl
query = {
  resource_type_filters = ["AWS::EC2::Instance"]  # List of resource types
  tag_filters = {                                  # Map of tag keys to values
    "Environment" = ["production", "staging"]     # Tag key with multiple values
    "Product"     = ["my-app"]                     # Additional tag filter
  }
}
```

### Using Resource Query String (Advanced)

For advanced use cases or backward compatibility, you can provide a raw JSON string:

```hcl
resource_query = jsonencode({
  ResourceTypeFilters = ["AWS::EC2::Instance"]
  TagFilters = [
    {
      Key    = "Environment"
      Values = ["production", "staging"]
    }
  ]
})
```

### Use Cases

Resource groups are useful for:

- **Environment Management**: Group resources by environment (production, staging, development)
- **Application Organization**: Group resources belonging to a specific application or service
- **Cost Management**: Organize resources for cost allocation and budgeting
- **Security Management**: Group resources for security scanning and compliance checks
- **Maintenance Windows**: Organize resources for scheduled maintenance operations
- **Resource Discovery**: Quickly find and list related resources across your account

### Example: Multi-Environment Resource Organization

This example shows how to organize resources across multiple environments using the `query` object:

```hcl
module "account" {
  resource_groups = {
    "production-app-resources" = {
      description = "All resources for the production application"
      query = {
        resource_type_filters = ["AWS::AllSupported"]
        tag_filters = {
          "Environment" = ["production"]
          "Application" = ["my-app"]
        }
      }
    }
    "staging-app-resources" = {
      description = "All resources for the staging application"
      query = {
        resource_type_filters = ["AWS::AllSupported"]
        tag_filters = {
          "Environment" = ["staging"]
          "Application" = ["my-app"]
        }
      }
    }
  }
}
```

### Example: Multiple Tag Values

You can specify multiple values for a single tag key to match resources with any of those values:

```hcl
module "account" {
  resource_groups = {
    "production-and-staging" = {
      description = "All resources in production or staging environments"
      query = {
        resource_type_filters = ["AWS::AllSupported"]
        tag_filters = {
          "Environment" = ["production", "staging"]
        }
      }
    }
  }
}
```

**Note**: Resource groups are dynamic and automatically update as resources are created, modified, or deleted based on the resource query criteria. Ensure your resources are properly tagged to be included in the appropriate resource groups. When using the `query` object, if `resource_type_filters` is not specified, it defaults to `["AWS::AllSupported"]`.

## GitHub Repository Management

This module includes comprehensive GitHub repository management capabilities through the `modules/github_repository` module. This allows tenants to create and manage GitHub repositories with enterprise-grade security and compliance features.

### GitHub Repository Features

- **Repository Creation**: Create GitHub repositories with customizable names, descriptions, and visibility
- **Security & Compliance**: Branch protection, required reviews, status checks, vulnerability alerts
- **Collaboration Management**: User and team access control, environment protection
- **Automation**: Repository templates, merge strategies, and automated workflows

### Basic GitHub Repository Usage

```hcl
module "my_repository" {
  source = "./modules/github_repository"

  repository  = "my-project"
  description = "My awesome project"
  visibility  = "private"
}
```

### Advanced GitHub Repository Configuration

```hcl
module "enterprise_repository" {
  source = "./modules/github_repository"

  repository  = "enterprise-critical-system"
  description = "Enterprise critical system with strict controls"
  
  # Security settings
  visibility = "private"
  
  # Branch protection
  enforce_branch_protection_for_admins = true
  required_approving_review_count      = 3
  dismiss_stale_reviews                = true
  prevent_self_review                  = true
  
  # Status checks
  required_status_checks = [
    "CI / Build and Test",
    "Security / Security Scan",
    "Compliance / Compliance Check"
  ]
  
  # Environments
  repository_environments          = ["staging", "production"]
  default_environment_review_users = ["senior-dev1", "senior-dev2"]
  
  # Collaborators
  repository_collaborators = [
    {
      username   = "senior-dev1"
      permission = "admin"
    }
  ]
  
  # Topics
  repository_topics = ["enterprise", "terraform", "aws", "critical"]
}
```

For complete GitHub repository management examples, see the `examples/github_repository/` directory.

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

## CloudWatch Cross-Account Observability

CloudWatch Cross-Account Observability allows you to centralize monitoring and observability data from multiple AWS accounts. This feature supports two configurations:

- **Observability Sink**: Configure an account to receive observability data from other accounts
- **Observability Source**: Configure an account to send its observability data to a central sink account

### Observability Sink Configuration

An observability sink is typically configured in a central monitoring or security account that aggregates observability data from multiple source accounts. The sink allows specified accounts to link their CloudWatch resources.

```hcl
module "monitoring_account" {
  cloudwatch = {
    observability_sink = {
      enable = true
      identifiers = [
        "123456789012",  # Source account 1
        "234567890123",  # Source account 2
      ]
      resource_types = [
        "AWS::CloudWatch::Metric",
        "AWS::CloudWatch::Dashboard",
        "AWS::CloudWatch::Alarm",
        "AWS::CloudWatch::LogGroup",
        "AWS::CloudWatch::LogStream",
      ]
    }
  }
}
```

#### Observability Sink Configuration Options

- **enable**: (Required) A flag indicating if the observability sink should be enabled
- **identifiers**: (Required) A list of AWS account IDs that are allowed to link their resources to this sink
- **resource_types**: (Optional) A list of CloudWatch resource types that can be linked to the sink. Defaults to:
  - `AWS::CloudWatch::Metric`
  - `AWS::CloudWatch::Dashboard`
  - `AWS::CloudWatch::Alarm`
  - `AWS::CloudWatch::LogGroup`
  - `AWS::CloudWatch::LogStream`

### Observability Source Configuration

An observability source is configured in accounts that need to send their CloudWatch data to a central sink account. This allows centralized monitoring and analysis of observability data across multiple accounts.

```hcl
module "source_account" {
  cloudwatch = {
    observability_source = {
      enable = true
      account_id = "123456789012"  # The monitoring account ID
      sink_identifier = "arn:aws:oam:us-east-1:123456789012:sink/observability-sink"
      resource_types = [
        "AWS::CloudWatch::Metric",
        "AWS::CloudWatch::Dashboard",
        "AWS::CloudWatch::Alarm",
        "AWS::CloudWatch::LogGroup",
        "AWS::CloudWatch::LogStream",
      ]
    }
  }
}
```

#### Observability Source Configuration Options

- **enable**: (Required) A flag indicating if the observability source should be enabled
- **account_id**: (Required) The AWS account ID of the sink account that will receive the observability data
- **sink_identifier**: (Required) The ARN of the OAM sink in the monitoring account (format: `arn:aws:oam:region:account-id:sink/sink-id`)
- **resource_types**: (Optional) A list of CloudWatch resource types to link to the observability sink. Defaults to:
  - `AWS::CloudWatch::Metric`
  - `AWS::CloudWatch::Dashboard`
  - `AWS::CloudWatch::Alarm`
  - `AWS::CloudWatch::LogGroup`
  - `AWS::CloudWatch::LogStream`

### Complete Example: Centralized Monitoring Setup

This example shows how to set up centralized monitoring with a monitoring account and multiple source accounts:

**Monitoring Account (Sink):**

```hcl
module "monitoring_account" {
  cloudwatch = {
    observability_sink = {
      enable = true
      identifiers = [
        "111111111111",  # Production account
        "222222222222",  # Development account
        "333333333333",  # Staging account
      ]
    }
  }
}
```

**Source Account (Production):**

```hcl
module "production_account" {
  cloudwatch = {
    observability_source = {
      enable = true
      account_id = "999999999999"  # Monitoring account ID
      sink_identifier = "arn:aws:oam:us-east-1:999999999999:sink/observability-sink"
    }
  }
}
```

**Note**: The sink must be created first in the monitoring account. Once the sink is created, you can obtain its ARN from the AWS Console or Terraform outputs, and use that ARN in the `sink_identifier` field for all source accounts.

### Benefits of CloudWatch Cross-Account Observability

- **Centralized Monitoring**: Aggregate metrics, logs, and alarms from multiple accounts in a single location
- **Unified Dashboards**: Create dashboards that span multiple accounts without switching contexts
- **Cost Optimization**: Reduce duplicate monitoring infrastructure across accounts
- **Security**: Centralize security monitoring and alerting in a dedicated security account
- **Compliance**: Simplify compliance reporting by centralizing observability data

### Account Subscription Filter Policy

CloudWatch Logs Account Subscription Filter Policies allow you to control which log groups can have subscription filters created and what destinations those subscription filters can send logs to. This provides account-level governance for log forwarding and helps ensure compliance with organizational policies.

#### Basic Account Subscription Filter Policy Configuration

```hcl
module "account" {
  cloudwatch = {
    account_subscriptions = {
      "lambda-forwarding" = {
        # https://docs.aws.amazon.com/cli/latest/reference/logs/put-account-policy.html
        policy = jsonencode({
          DestinationArn = aws_lambda_function.test.arn
          FilterPattern  = "test"
        })
        selection_criteria = "LogGroupName NOT IN [\"excluded_log_group_name\"]"
      }
    }
  }
}
```

#### Account Subscription Filter Policy with Selection Criteria

You can use selection criteria to apply the policy only to specific log groups based on resource attributes:

```hcl
module "account" {
  cloudwatch = {
    account_subscriptions = {
      "lambda-forwarding" = {
        policy = jsonencode({
          DestinationArn = aws_lambda_function.test.arn
          FilterPattern  = "test"
        })
        selection_criteria = "LogGroupName NOT IN [\"excluded_log_group_name\"]"
      }
    }
  }
}
```

#### Multiple Account Subscription Filter Policies

You can configure multiple subscription filter policies for different destinations or log groups:

```hcl
module "account" {
  cloudwatch = {
    account_subscriptions = {
      "kinesis-streams" = {
        policy = jsonencode({
          Statement = [
            {
              Action = [
                "logs:CreateLogDelivery",
                "logs:GetLogDelivery",
                "logs:UpdateLogDelivery",
                "logs:DeleteLogDelivery",
                "logs:ListLogDeliveries"
              ]
              Effect = "Allow"
              Principal = {
                Service = "logs.amazonaws.com"
              }
              Resource = "arn:aws:logs:*:*:log-delivery:*"
              Condition = {
                StringEquals = {
                  "logs:destinationType" = "KinesisStream"
                }
              }
            }
          ]
          Version = "2012-10-17"
        })
        selection_criteria = "ALL"
      }
      "firehose-delivery" = {
        policy = jsonencode({
          Statement = [
            {
              Action = [
                "logs:CreateLogDelivery",
                "logs:GetLogDelivery",
                "logs:UpdateLogDelivery",
                "logs:DeleteLogDelivery",
                "logs:ListLogDeliveries"
              ]
              Effect = "Allow"
              Principal = {
                Service = "logs.amazonaws.com"
              }
              Resource = "arn:aws:logs:*:*:log-delivery:*"
              Condition = {
                StringEquals = {
                  "logs:destinationType" = "Firehose"
                }
              }
            }
          ]
          Version = "2012-10-17"
        })
        selection_criteria = jsonencode({
          LogGroupName = "/aws/application/*"
        })
      }
    }
  }
}
```

#### Account Subscription Filter Policy Configuration Options

- **policy**: (Required) The IAM policy document (as JSON string) that defines what actions are allowed for subscription filters. The policy must allow `logs:CreateLogDelivery`, `logs:GetLogDelivery`, `logs:UpdateLogDelivery`, `logs:DeleteLogDelivery`, and `logs:ListLogDeliveries` actions.
- **selection_criteria**: (Optional) A JSON string that specifies which log groups the policy applies to. Use `"ALL"` to apply the policy to all log groups, or provide a JSON object with selection criteria such as:
  - `LogGroupName`: Filter by log group name pattern (e.g., `"/aws/lambda/*"`)
  - `ResourceArn`: Filter by log group ARN pattern

#### Supported Destination Types

The subscription filter policy can control access to the following destination types:

- **KinesisStream**: Forward logs to Amazon Kinesis Data Streams
- **Firehose**: Forward logs to Amazon Kinesis Data Firehose
- **Lambda**: Forward logs to AWS Lambda functions

#### Use Cases

- **Compliance**: Ensure only approved destinations can receive log data
- **Security**: Control which log groups can forward logs to external systems
- **Cost Management**: Restrict log forwarding to specific destinations to control costs
- **Governance**: Enforce organizational policies on log data handling

**Note**: Account subscription filter policies are account-level policies that apply to all log groups in the account (or those matching the selection criteria). They work in conjunction with resource-based policies on individual log groups.

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
2. Fetch the `terraform-docs` binary (<https://terraform-docs.io/user-guide/installation/>)
3. Run `terraform-docs markdown table --output-file ${PWD}/README.md --output-mode inject .`

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.0.0 |
| <a name="provider_aws.identity"></a> [aws.identity](#provider\_aws.identity) | >= 6.0.0 |
| <a name="provider_aws.management"></a> [aws.management](#provider\_aws.management) | >= 6.0.0 |
| <a name="provider_aws.network"></a> [aws.network](#provider\_aws.network) | >= 6.0.0 |
| <a name="provider_aws.tenant"></a> [aws.tenant](#provider\_aws.tenant) | >= 6.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | The environment in which to provision resources | `string` | n/a | yes |
| <a name="input_git_repository"></a> [git\_repository](#input\_git\_repository) | The git repository to use for the account | `string` | n/a | yes |
| <a name="input_home_region"></a> [home\_region](#input\_home\_region) | The home region in which to provision global resources | `string` | n/a | yes |
| <a name="input_owner"></a> [owner](#input\_owner) | The owner of the product, and injected into all resource tags | `string` | n/a | yes |
| <a name="input_product"></a> [product](#input\_product) | The name of the product to provision resources and inject into all resource tags | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A collection of tags to apply to resources | `map(string)` | n/a | yes |
| <a name="input_account_alias"></a> [account\_alias](#input\_account\_alias) | The account alias to apply to the account | `string` | `null` | no |
| <a name="input_aws_config"></a> [aws\_config](#input\_aws\_config) | Account specific configuration for AWS Config | <pre>object({<br/>    # A flag indicating if AWS Config should be enabled<br/>    enable = optional(bool, false)<br/>    # A list of compliance packs to provision in the account<br/>    compliance_packs = optional(map(object({<br/>      # A map of parameter overrides to apply to the compliance pack<br/>      parameter_overrides = optional(map(string), {})<br/>      # The URL of the compliance pack<br/>      template_url = optional(string, "")<br/>      # The body of the compliance pack<br/>      template_body = optional(string, "")<br/>    })), {})<br/>    # A list of managed rules to provision in the account<br/>    rules = optional(map(object({<br/>      # The list of resource types to scope the rule<br/>      resource_types = list(string)<br/>      # The description of the rule<br/>      description = string<br/>      # The identifier of the rule  <br/>      identifier = string<br/>      # The inputs of the rule<br/>      inputs = optional(map(string), {})<br/>      # The maximum execution frequency of the rule<br/>      max_execution_frequency = optional(string, null)<br/>      # The scope of the rule<br/>      scope = optional(object({<br/>        # The list of resource types to scope the rule<br/>        compliance_resource_types = optional(list(string), [])<br/>        # The key of the tag to scope the rule<br/>        tag_key = optional(string, null)<br/>        # The value of the tag to scope the rule<br/>        tag_value = optional(string, null)<br/>      }), null)<br/>    })), {})<br/>  })</pre> | <pre>{<br/>  "compliance_packs": {},<br/>  "enable": false,<br/>  "input_parameters": {},<br/>  "rules": {},<br/>  "scope": null<br/>}</pre> | no |
| <a name="input_budgets"></a> [budgets](#input\_budgets) | A collection of budgets to provision | <pre>list(object({<br/>    name         = string<br/>    budget_type  = optional(string, "COST")<br/>    limit_amount = optional(string, "100.0")<br/>    limit_unit   = optional(string, "PERCENTAGE")<br/>    time_unit    = optional(string, "MONTHLY")<br/><br/>    notifications = optional(map(object({<br/>      comparison_operator = string<br/>      notification_type   = string<br/>      threshold           = number<br/>      threshold_type      = string<br/>    })), null)<br/><br/>    auto_adjust_data = optional(list(object({<br/>      auto_adjust_type = string<br/>    })), [])<br/><br/>    cost_filter = optional(map(object({<br/>      values = list(string)<br/>    })), {})<br/><br/>    cost_types = optional(object({<br/>      include_credit             = optional(bool, false)<br/>      include_discount           = optional(bool, false)<br/>      include_other_subscription = optional(bool, false)<br/>      include_recurring          = optional(bool, false)<br/>      include_refund             = optional(bool, false)<br/>      include_subscription       = optional(bool, false)<br/>      include_support            = optional(bool, false)<br/>      include_tax                = optional(bool, false)<br/>      include_upfront            = optional(bool, false)<br/>      use_blended                = optional(bool, false)<br/>      }), {<br/>      include_credit             = false<br/>      include_discount           = false<br/>      include_other_subscription = false<br/>      include_recurring          = false<br/>      include_refund             = false<br/>      include_subscription       = true<br/>      include_support            = false<br/>      include_tax                = false<br/>      include_upfront            = false<br/>      use_blended                = false<br/>    })<br/><br/>    tags = optional(map(string), {})<br/>  }))</pre> | `[]` | no |
| <a name="input_central_dns"></a> [central\_dns](#input\_central\_dns) | Configuration for the hub used to centrally resolved dns requests | <pre>object({<br/>    enable = optional(bool, false)<br/>    # The domain name to use for the central DNS<br/>    vpc_id = optional(string, null)<br/>  })</pre> | <pre>{<br/>  "enable": false,<br/>  "vpc_id": null<br/>}</pre> | no |
| <a name="input_cloudwatch"></a> [cloudwatch](#input\_cloudwatch) | Configuration for the CloudWatch service | <pre>object({<br/>    # The observability sink configuration<br/>    observability_sink = optional(object({<br/>      # A flag indicating if cloudwatch cross-account observability should be enabled<br/>      enable = optional(bool, false)<br/>      # The AWS Identifier of the accounts that are allowed to access the observability sink<br/>      identifiers = optional(list(string), null)<br/>      # The AWS resource types that are allowed to be linked to the observability sink<br/>      resource_types = optional(list(string), [<br/>        "AWS::CloudWatch::Metric",<br/>        "AWS::CloudWatch::Dashboard",<br/>        "AWS::CloudWatch::Alarm",<br/>        "AWS::CloudWatch::LogGroup",<br/>        "AWS::CloudWatch::LogStream",<br/>      ])<br/>    }), null)<br/>    observability_source = optional(object({<br/>      # A flag indicating if cloudwatch cross-account observability should be enabled<br/>      enable = optional(bool, false)<br/>      # The name of the cloudwatch cross-account observability<br/>      account_id = optional(string, null)<br/>      # The OAM sink identifier i.e. arn:aws:oam:region:account-id:sink/sink-id<br/>      sink_identifier = optional(string, null)<br/>      # The resource types to link to the observability source<br/>      resource_types = optional(list(string), [<br/>        "AWS::CloudWatch::Metric",<br/>        "AWS::CloudWatch::Dashboard",<br/>        "AWS::CloudWatch::Alarm",<br/>        "AWS::CloudWatch::LogGroup",<br/>        "AWS::CloudWatch::LogStream",<br/>      ])<br/>    }), null)<br/>    ## Collection of account subscriptions to provision <br/>    account_subscriptions = optional(map(object({<br/>      # The policy document to apply to the subscription<br/>      policy = optional(string, null)<br/>      # The selection criteria to apply to the subscription<br/>      selection_criteria = optional(string, null)<br/>    })), {})<br/>  })</pre> | <pre>{<br/>  "account_subscriptions": {},<br/>  "observability_sink": null,<br/>  "observability_source": null<br/>}</pre> | no |
| <a name="input_cost_anomaly_detection"></a> [cost\_anomaly\_detection](#input\_cost\_anomaly\_detection) | A collection of cost anomaly detection monitors to apply to the account | <pre>object({<br/>    enable = optional(bool, true)<br/>    # A flag indicating if the default monitors should be enabled<br/>    monitors = optional(list(object({<br/>      name = string<br/>      # The name of the anomaly detection rule<br/>      frequency = optional(string, "IMMEDIATE")<br/>      # The dimension of the anomaly detection rule, either SERVICE or DIMENSIONAL<br/>      threshold_expression = optional(list(object({<br/>        and = object({<br/>          dimension = object({<br/>            key = string<br/>            # The key of the dimension<br/>            match_options = list(string)<br/>            # The match options of the dimension<br/>            values = list(string)<br/>            # The values of the dimension<br/>          })<br/>        })<br/>        # The expression to apply to the cost anomaly detection monitor<br/>      })), [])<br/>      # The expression to apply to the anomaly detection rule<br/>      # see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ce_anomaly_monitor<br/>      specification = optional(string, "")<br/>      # The specification to anomaly detection monitor<br/>      # see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ce_anomaly_monitor<br/>    })), [])<br/>  })</pre> | <pre>{<br/>  "enable": true,<br/>  "monitors": []<br/>}</pre> | no |
| <a name="input_cost_center"></a> [cost\_center](#input\_cost\_center) | The cost center of the product, and injected into all resource tags | `string` | `null` | no |
| <a name="input_dns"></a> [dns](#input\_dns) | A collection of DNS zones to provision and associate with networks | <pre>map(object({<br/>    comment = optional(string, "Managed by zone created by terraform")<br/>    # A comment associated with the DNS zone<br/>    network = string<br/>    # A list of network names to associate with the DNS zone<br/>    private = optional(bool, true)<br/>    # A flag indicating if the DNS zone is private or public<br/>  }))</pre> | `{}` | no |
| <a name="input_ebs_encryption"></a> [ebs\_encryption](#input\_ebs\_encryption) | A collection of EBS encryption settings to apply to the account | <pre>object({<br/>    enable = optional(bool, false)<br/>    # A flag indicating if EBS encryption should be enabled<br/>    create_kms_key = optional(bool, true)<br/>    # A flag indicating if an EBS encryption key should be created<br/>    key_deletion_window_in_days = optional(number, 10)<br/>    # The number of days to retain the key before deletion when the key is removed<br/>    key_alias = optional(string, "lza/ebs/default")<br/>    # The alias of the EBS encryption key when provisioning a new key<br/>    key_arn = optional(string, null)<br/>    # The ARN of an existing EBS encryption key to use for EBS encryption<br/>  })</pre> | `null` | no |
| <a name="input_guardduty"></a> [guardduty](#input\_guardduty) | A collection of GuardDuty settings to apply to the account | <pre>object({<br/>    # A flag indicating if GuardDuty should be created<br/>    finding_publishing_frequency = optional(string, "FIFTEEN_MINUTES")<br/>    # The frequency of finding publishing<br/>    detectors = optional(list(object({<br/>      name = string<br/>      # The name of the detector<br/>      enable = optional(bool, true)<br/>      # The frequency of finding publishing<br/>      additional_configuration = optional(list(object({<br/>        name = string<br/>        # The name of the additional configuration<br/>        enable = optional(bool, true)<br/>        # The status of the additional configuration<br/>      })), [])<br/>    })), [])<br/>    # Configuration for the detector<br/>    filters = optional(map(object({<br/>      # The name of the filter<br/>      action = string<br/>      # The action of the filter<br/>      rank = number<br/>      # The rank of the filter<br/>      description = string<br/>      # The description of the filter<br/>      criterion = list(object({<br/>        field = string<br/>        # The field of the criterion<br/>        equals = optional(string, null)<br/>        # The equals of the criterion<br/>        not_equals = optional(string, null)<br/>        # The not equals of the criterion<br/>        greater_than = optional(string, null)<br/>        # The greater than of the criterion<br/>        greater_than_or_equal = optional(string, null)<br/>        # The greater than or equal of the criterion<br/>        less_than = optional(string, null)<br/>        # The less than of the criterion<br/>        less_than_or_equal = optional(string, null)<br/>        # The less than or equal of the criterion<br/>      }))<br/>      # The criterion of the filter<br/>    })), {})<br/>  })</pre> | `null` | no |
| <a name="input_iam_access_analyzer"></a> [iam\_access\_analyzer](#input\_iam\_access\_analyzer) | The IAM access analyzer configuration to apply to the account | <pre>object({<br/>    enable = optional(bool, false)<br/>    # A flag indicating if IAM access analyzer should be enabled<br/>    analyzer_name = optional(string, "lza-iam-access-analyzer")<br/>    # The name of the IAM access analyzer<br/>    analyzer_type = optional(string, "ORGANIZATION")<br/>    # The type of the IAM access analyzer<br/>  })</pre> | <pre>{<br/>  "analyzer_name": "lza-iam-access-analyzer",<br/>  "analyzer_type": "ORGANIZATION",<br/>  "enable": true<br/>}</pre> | no |
| <a name="input_iam_groups"></a> [iam\_groups](#input\_iam\_groups) | A collection of IAM groups to apply to the account | <pre>list(object({<br/>    enforce_mfa = optional(bool, true)<br/>    # A flag indicating if MFA should be enforced<br/>    name = optional(string, null)<br/>    # The name prefix of the IAM group<br/>    path = optional(string, "/")<br/>    # The path of the IAM group<br/>    policies = optional(list(string), [])<br/>    # A list of policies to apply to the IAM group<br/>    users = optional(list(string), [])<br/>    # A list of users to apply to the IAM group<br/>  }))</pre> | `[]` | no |
| <a name="input_iam_instance_profiles"></a> [iam\_instance\_profiles](#input\_iam\_instance\_profiles) | A collection of IAM instance profiles to apply to the account | <pre>map(object({<br/>    name = optional(string, null)<br/>    # The name prefix of the IAM instance profile<br/>    path = optional(string, "/")<br/>    # The path of the IAM instance profile<br/>    permission_arns = optional(list(string), [])<br/>    # A list of roles to apply to the IAM instance profile<br/>  }))</pre> | `{}` | no |
| <a name="input_iam_password_policy"></a> [iam\_password\_policy](#input\_iam\_password\_policy) | The IAM password policy to apply to the account | <pre>object({<br/>    enable = optional(bool, false)<br/>    # A flag indicating if IAM password policy should be enabled<br/>    allow_users_to_change_password = optional(bool, true)<br/>    # A flag indicating if users can change their password<br/>    hard_expiry = optional(bool, false)<br/>    # A flag indicating if a hard expiry should be enforced<br/>    max_password_age = optional(number, 90)<br/>    # The maximum password age<br/>    minimum_password_length = optional(number, 16)<br/>    # The minimum password length<br/>    password_reuse_prevention = optional(number, 24)<br/>    # The number of passwords to prevent reuse<br/>    require_lowercase_characters = optional(bool, true)<br/>    # A flag indicating if lowercase characters are required<br/>    require_numbers = optional(bool, true)<br/>    # A flag indicating if numbers are required<br/>    require_symbols = optional(bool, true)<br/>    # A flag indicating if symbols are required<br/>    require_uppercase_characters = optional(bool, true)<br/>    # A flag indicating if uppercase characters are required<br/>  })</pre> | `{}` | no |
| <a name="input_iam_policies"></a> [iam\_policies](#input\_iam\_policies) | A collection of IAM policies to apply to the account | <pre>map(object({<br/>    name = optional(string, null)<br/>    # The name of the IAM policy<br/>    name_prefix = optional(string, null)<br/>    # The name prefix of the IAM policy<br/>    description = string<br/>    # The description of the IAM policy<br/>    path = optional(string, "/")<br/>    # The path of the IAM policy<br/>    policy = string<br/>    # The policy document to apply to the IAM policy<br/>  }))</pre> | `{}` | no |
| <a name="input_iam_roles"></a> [iam\_roles](#input\_iam\_roles) | A collection of IAM roles to apply to the account | <pre>map(object({<br/>    name = optional(string, null)<br/>    # The name of the IAM role<br/>    name_prefix = optional(string, null)<br/>    # The name prefix of the IAM role<br/>    assume_accounts = optional(list(string), [])<br/>    # List of accounts to assume the role<br/>    assume_roles = optional(list(string), [])<br/>    # List of principals to assume the role<br/>    assume_services = optional(list(string), [])<br/>    # List of services to assume the role<br/>    description = string<br/>    # The description of the IAM role<br/>    path = optional(string, "/")<br/>    # The path of the IAM role<br/>    permission_boundary_arn = optional(string, "")<br/>    # A collection of tags to apply to the IAM role<br/>    permission_arns = optional(list(string), [])<br/>    # A list of additional permissions to apply to the IAM role<br/>    policies = optional(any, [])<br/>  }))</pre> | `{}` | no |
| <a name="input_iam_service_linked_roles"></a> [iam\_service\_linked\_roles](#input\_iam\_service\_linked\_roles) | A collection of service linked roles to apply to the account | `list(string)` | <pre>[<br/>  "autoscaling.amazonaws.com",<br/>  "spot.amazonaws.com",<br/>  "spotfleet.amazonaws.com"<br/>]</pre> | no |
| <a name="input_iam_users"></a> [iam\_users](#input\_iam\_users) | A collection of IAM users to apply to the account | <pre>list(object({<br/>    name = optional(string, null)<br/>    # The name of the IAM user<br/>    name_prefix = optional(string, null)<br/>    # The name prefix of the IAM user<br/>    path = optional(string, "/")<br/>    # The path of the IAM user<br/>    permission_boundary_name = optional(string, null)<br/>    # A list of additional permissions to apply to the IAM user<br/>    policy_arns = optional(list(string), [])<br/>  }))</pre> | `[]` | no |
| <a name="input_identity_center_permitted_roles"></a> [identity\_center\_permitted\_roles](#input\_identity\_center\_permitted\_roles) | A map of permitted SSO roles, with the name of the permitted SSO role as the key, and value the permissionset | `map(string)` | <pre>{<br/>  "network_viewer": "NetworkViewer",<br/>  "security_auditor": "SecurityAuditor"<br/>}</pre> | no |
| <a name="input_include_iam_roles"></a> [include\_iam\_roles](#input\_include\_iam\_roles) | Collection of IAM roles to include in the account | <pre>object({<br/>    security_auditor = optional(object({<br/>      enable = optional(bool, false)<br/>      name   = optional(string, "lza-security-auditor")<br/>    }), {})<br/>    ssm_instance = optional(object({<br/>      enable = optional(bool, false)<br/>      name   = optional(string, "lza-ssm-instance")<br/>    }), {})<br/>  })</pre> | <pre>{<br/>  "security_auditor": {<br/>    "enable": false,<br/>    "name": "lza-security-auditor"<br/>  },<br/>  "ssm_instance": {<br/>    "enable": false,<br/>    "name": "lza-ssm-instance"<br/>  }<br/>}</pre> | no |
| <a name="input_infrastructure_repository"></a> [infrastructure\_repository](#input\_infrastructure\_repository) | The infrastructure repository provisions and configures a pipeline repository for the landing zone | <pre>object({<br/>    name = optional(string, null)<br/>    # The name prefix of the repository<br/>    create = optional(bool, true)<br/>    # A flag indicating if the repository should be created<br/>    visibility = optional(string, "private")<br/>    # The visibility of the repository<br/>    default_branch = optional(string, "main")<br/>    # home page url of the repository<br/>    homepage_url = optional(string, null)<br/>    # The home page url of the repository<br/>    enable_archived = optional(bool, false)<br/>    # A flag indicating if the repository should be archived<br/>    enable_discussions = optional(bool, false)<br/>    # A flag indicating if the repository should enable discussions<br/>    enable_downloads = optional(bool, false)<br/>    # A flag indicating if the repository should enable downloads<br/>    enable_issues = optional(bool, true)<br/>    # A flag indicating if the repository should enable issues<br/>    enable_projects = optional(bool, false)<br/>    # A flag indicating if the repository should enable projects<br/>    enable_wiki = optional(bool, false)<br/>    # A flag indicating if the repository should enable wiki<br/>    enable_vulnerability_alerts = optional(bool, null)<br/>    # A flag indicating if the repository should enable vulnerability alerts<br/>    topics = optional(list(string), ["aws", "terraform", "landing-zone"])<br/>    # The topics of the repository<br/>    collaborators = optional(list(object({<br/>      # The username of the collaborator<br/>      username = string<br/>      # The permission of the collaborator<br/>      permission = optional(string, "write")<br/>    })), [])<br/>    # The collaborators of the repository<br/>    template = optional(object({<br/>      # The owner of the repository template<br/>      owner = string<br/>      # The repository template to use for the repository<br/>      repository = string<br/>      # Include all branches<br/>      include_all_branches = optional(bool, false)<br/>    }), null)<br/>    # Configure webhooks for the repository<br/>    webhooks = optional(list(object({<br/>      # The content type of the webhook<br/>      content_type = optional(string, "json")<br/>      # The enable flag of the webhook<br/>      enable = optional(bool, true)<br/>      # The events of the webhook<br/>      events = optional(list(string), ["push", "pull_request"])<br/>      # The insecure SSL flag of the webhook<br/>      insecure_ssl = optional(bool, false)<br/>      # The secret of the webhook<br/>      secret = optional(string, null)<br/>      # The URL of the webhook<br/>      url = string<br/>    })), null)<br/>    # The branch protection to use for the repository<br/>    branch_protection = optional(map(object({<br/>      allows_force_pushes             = optional(bool, false)<br/>      allows_deletions                = optional(bool, false)<br/>      dismiss_stale_reviews           = optional(bool, true)<br/>      enforce_admins                  = optional(bool, true)<br/>      lock_branch                     = optional(bool, false)<br/>      require_conversation_resolution = optional(bool, false)<br/>      require_last_push_approval      = optional(bool, false)<br/>      require_signed_commits          = optional(bool, true)<br/>      required_linear_history         = optional(bool, false)<br/><br/>      required_status_checks = optional(object({<br/>        strict   = optional(bool, true)<br/>        contexts = optional(list(string), null)<br/>      }), null)<br/><br/>      required_pull_request_reviews = optional(object({<br/>        dismiss_stale_reviews           = optional(bool, true)<br/>        dismissal_restrictions          = optional(list(string), null)<br/>        pull_request_bypassers          = optional(list(string), null)<br/>        require_code_owner_reviews      = optional(bool, true)<br/>        require_last_push_approval      = optional(bool, false)<br/>        required_approving_review_count = optional(number, 1)<br/>        restrict_dismissals             = optional(bool, false)<br/>      }), null)<br/>      })), {<br/>      main = {<br/>        allows_force_pushes             = false<br/>        allows_deletions                = false<br/>        dismiss_stale_reviews           = true<br/>        enforce_admins                  = true<br/>        require_conversation_resolution = true<br/>        require_signed_commits          = true<br/>        required_approving_review_count = 2<br/><br/>        required_status_checks = {<br/>          strict   = true<br/>          contexts = null<br/>        }<br/>      }<br/>    })<br/><br/>    # The branch protection to use for the repository<br/>    permissions = optional(object({<br/>      read_only_policy_arns = list(string)<br/>      # The policy ARNs to associate with the repository<br/>      read_write_policy_arns = list(string)<br/>      # The policy ARNs to associate with the repository<br/>      }), {<br/>      read_only_policy_arns  = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]<br/>      read_write_policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]<br/>    })<br/><br/>    # The permissions to use for the repository<br/>    permissions_boundary = optional(object({<br/>      arn = optional(string, null)<br/>      # The ARN of the permissions boundary to use for the repository<br/>      policy = optional(string, null)<br/>      # The policy of the permissions boundary to use for the repository<br/>    }), null)<br/>    # The permissions boundary to use for the repository<br/>  })</pre> | `null` | no |
| <a name="input_inspector"></a> [inspector](#input\_inspector) | Configuration for the AWS Inspector service | <pre>object({<br/>    enable = optional(bool, false)<br/>    # A flag indicating if AWS Inspector should be enabled<br/>    delegate_account_id = optional(string, null)<br/>    # The account ID we should associate the service to<br/>  })</pre> | `null` | no |
| <a name="input_kms_administrator"></a> [kms\_administrator](#input\_kms\_administrator) | Configuration for the default kms administrator role to use for the account | <pre>object({<br/>    # The domain name to use for the central DNS<br/>    assume_accounts = optional(list(string), [])<br/>    # A list of roles to assume the kms administrator role<br/>    assume_roles = optional(list(string), [])<br/>    # A list of roles to assume the kms administrator role<br/>    assume_services = optional(list(string), [])<br/>    # A list of services to assume the kms administrator role<br/>    description = optional(string, "Provides access to administer the KMS keys for the account")<br/>    # The description of the default kms administrator role<br/>    enable = optional(bool, false)<br/>    # A flag indicating if the default kms administrator role should be enabled<br/>    enable_account_root = optional(bool, false)<br/>    # A flag indicating if the account root should be enabled<br/>    name = optional(string, "lza-kms-adminstrator")<br/>    # The name of the default kms administrator role<br/>  })</pre> | <pre>{<br/>  "assume_accounts": [],<br/>  "assume_roles": [],<br/>  "assume_services": [],<br/>  "description": "Provides access to administer the KMS keys for the account",<br/>  "enable": false,<br/>  "enable_account_root": false,<br/>  "name": "lza-kms-adminstrator"<br/>}</pre> | no |
| <a name="input_kms_key"></a> [kms\_key](#input\_kms\_key) | Configuration for the default kms encryption key to use for the account (per region) | <pre>object({<br/>    enable = optional(bool, false)<br/>    # A flag indicating if account encryption should be enabled<br/>    key_deletion_window_in_days = optional(number, 7)<br/>    # The number of days to retain the key before deletion when the key is removed<br/>    key_alias = optional(string, null)<br/>    # The alias of the account encryption key when provisioning a new key<br/>    key_administrators = optional(list(string), [])<br/>    # A list of ARN of the key administrators<br/>    key_owners = optional(list(string), [])<br/>    # A list of ARN of the key owners<br/>    key_users = optional(list(string), [])<br/>    # A list of ARN of the key users - if unset, it will default to the account<br/>  })</pre> | <pre>{<br/>  "enable": false,<br/>  "key_administrators": [],<br/>  "key_alias": "lza/account/default",<br/>  "key_deletion_window_in_days": 7,<br/>  "key_owners": [],<br/>  "key_users": []<br/>}</pre> | no |
| <a name="input_macie"></a> [macie](#input\_macie) | A collection of Macie settings to apply to the account | <pre>object({<br/>    enable = optional(bool, false)<br/>    # A flag indicating if Macie should be enabled<br/>    frequency = optional(string, "FIFTEEN_MINUTES")<br/>    # The frequency of Macie findings<br/>    admin_account_id = optional(string, null)<br/>    # Is defined the member account will accept any invitations from the management account<br/>  })</pre> | `null` | no |
| <a name="input_networks"></a> [networks](#input\_networks) | A collection of networks to provision within the designated region | <pre>map(object({<br/>    firewall = optional(object({<br/>      capacity = number<br/>      # The capacity of the firewall rule group<br/>      rules_source = string<br/>      # The content of the suracata rules<br/>      ip_sets = map(list(string))<br/>      # A map of IP sets to apply to the firewall rule ie. WEBSERVERS = ["100.0.0.0/16"]<br/>      port_sets = map(list(number))<br/>      # A map of port sets to apply to the firewall rule ie. WEBSERVERS = [80, 443]<br/>      domains_whitelist = list(string)<br/>    }), null)<br/><br/>    private_subnet_tags = optional(map(string), {})<br/>    # Additional tags to apply to the private subnet<br/>    public_subnet_tags = optional(map(string), {})<br/>    # Additional tags to apply to the public subnet<br/><br/>    subnets = map(object({<br/>      cidr = optional(string, null)<br/>      # The CIDR block of the subnet<br/>      netmask = optional(number, 0)<br/>      # Additional tags to apply to the subnet<br/>      tags = optional(map(string), {})<br/>    }))<br/><br/>    tags = optional(map(string), {})<br/>    # A collection of tags to apply to the network - these will be merged with the global tags<br/><br/>    transit_gateway = optional(object({<br/>      gateway_id = optional(string, null)<br/>      # The transit gateway ID to associate with the network<br/>      gateway_route_table_id = optional(string, null)<br/>      ## Optional id of the transit gateway route table to associate with the network<br/>      gateway_routes = optional(map(string), null)<br/>      # A map used to associate routes with subnets provisioned by the module - i.e ensure<br/>      # all private subnets push<br/>      }), {<br/>      gateway_id             = null<br/>      gateway_route_table_id = null<br/>      gateway_routes         = null<br/>    })<br/>    ## Configuration for the transit gateway for this network<br/><br/>    vpc = object({<br/>      availability_zones = optional(string, 2)<br/>      # The availability zone in which to provision the network, defaults to 2<br/>      cidr = optional(string, null)<br/>      # The CIDR block of the VPC network if not using IPAM<br/>      enable_private_endpoints = optional(list(string), [])<br/>      # An optional list of private endpoints to associate with the network i.e ["s3", "dynamodb"]<br/>      enable_shared_endpoints = optional(bool, true)<br/>      # Indicates if the network should accept shared endpoints<br/>      enable_transit_gateway = optional(bool, true)<br/>      # A flag indicating if the network should be associated with the transit gateway<br/>      enable_transit_gateway_appliance_mode = optional(bool, false)<br/>      # A flag indicating if the transit gateway should be in appliance mode<br/>      enable_default_route_table_association = optional(bool, true)<br/>      # A flag indicating if the default route table should be associated with the network<br/>      enable_default_route_table_propagation = optional(bool, true)<br/>      # A flag indicating if the default route table should be propagated to the network<br/>      flow_logs = optional(object({<br/>        destination_type = optional(string, "none")<br/>        # The destination type of the flow logs <br/>        destination_arn = optional(string, null)<br/>        # The ARN of the destination of the flow logs<br/>        log_format = optional(string, "plain-text")<br/>        # The format of the flow logs<br/>        traffic_type = optional(string, "ALL")<br/>        # The type of traffic to capture<br/>        destination_options = optional(object({<br/>          file_format = optional(string, "plain-text")<br/>          # The format of the flow logs<br/>          hive_compatible_partitions = optional(bool, false)<br/>          # Whether to use hive compatible partitions<br/>          per_hour_partition = optional(bool, false)<br/>          # Whether to partition the flow logs per hour<br/>        }), null)<br/>        # The destination options of the flow logs<br/>      }), null)<br/>      ipam_pool_name = optional(string, null)<br/>      # The name of the IPAM pool to use for the network<br/>      nat_gateway_mode = optional(string, "none")<br/>      # The NAT gateway mode to use for the network, defaults to none<br/>      netmask = optional(number, null)<br/>      # The netmask of the VPC network if using IPAM<br/>      transit_gateway_routes = optional(map(string), null)<br/>    })<br/>  }))</pre> | `{}` | no |
| <a name="input_notifications"></a> [notifications](#input\_notifications) | Configuration for the notifications to the owner of the account | <pre>object({<br/>    email = optional(object({<br/>      addresses = optional(list(string), [])<br/>      # A list of email addresses to send notifications to<br/>      }), {<br/>      addresses = []<br/>    })<br/><br/>    slack = optional(object({<br/>      webhook_url = optional(string, "")<br/>      # The slack webhook_url to send notifications to<br/>      }), {<br/>      webhook_url = null<br/>    })<br/><br/>    teams = optional(object({<br/>      webhook_url = optional(string, "")<br/>      # The teams webhook_url to send notifications to<br/>      }), {<br/>      webhook_url = null<br/>    })<br/><br/>    services = optional(object({<br/>      securityhub = object({<br/>        enable = optional(bool, false)<br/>        # A flag indicating if security hub notifications should be enabled<br/>        eventbridge_rule_name = optional(string, "lza-securityhub-eventbridge")<br/>        # The sns topic name which is created per region in the account,<br/>        # this is used to receive notifications, and forward them on via email or other means.<br/>        lambda_name = optional(string, "lza-securityhub-slack-forwarder")<br/>        # The name of the lambda which will be used to forward the security hub events to slack<br/>        lambda_role_name = optional(string, "lza-securityhub-slack-forwarder")<br/>        # The name of the eventbridge rule which is used to forward the security hub events to the lambda<br/>        severity = optional(list(string), ["CRITICAL"])<br/>      })<br/>      }), {<br/>      securityhub = {<br/>        enable = false<br/>      }<br/>    })<br/>  })</pre> | <pre>{<br/>  "email": {<br/>    "addresses": []<br/>  },<br/>  "services": {<br/>    "securityhub": {<br/>      "enable": false,<br/>      "eventbridge_rule_name": "lza-securityhub-eventbridge",<br/>      "lambda_name": "lza-securityhub-slack-forwarder",<br/>      "lambda_role_name": "lza-securityhub-slack-forwarder",<br/>      "severity": [<br/>        "CRITICAL"<br/>      ]<br/>    }<br/>  },<br/>  "slack": {<br/>    "webhook_url": null<br/>  },<br/>  "teams": {<br/>    "webhook_url": null<br/>  }<br/>}</pre> | no |
| <a name="input_rbac"></a> [rbac](#input\_rbac) | Provides the ability to associate one of more groups with a sso role in the account | <pre>map(object({<br/>    users = optional(list(string), [])<br/>    # A list of users to associate with the developer role<br/>    groups = optional(list(string), [])<br/>    # A list of groups to associate with the developer role<br/>  }))</pre> | `{}` | no |
| <a name="input_resource_groups"></a> [resource\_groups](#input\_resource\_groups) | Configuration for the resource groups service | <pre>map(object({<br/>    # The name of the resource group<br/>    description = string<br/>    # The type of the of group configuration<br/>    type = optional(string, "TAG_FILTERS_1_0")<br/>    # An optional configuration for the resource group<br/>    configuration = optional(object({<br/>      # The type of the of group configuration<br/>      type = string<br/>      # The parameters of the group configuration<br/>      parameters = optional(list(object({<br/>        # The name of the parameter<br/>        name = string<br/>        # The list of values for the parameter<br/>        values = list(string)<br/>      })), [])<br/>    }), null)<br/>    # The resource query to configure the resource group<br/>    query = optional(object({<br/>      # A collection of resource types to scope the resource query<br/>      resource_type_filters = optional(list(string), ["AWS::AllSupported"])<br/>      # A collection of tag filters to scope the resource query<br/>      tag_filters = optional(map(list(string)), {})<br/>    }), null)<br/>    # The resource query in json format https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/resourcegroups_group<br/>    resource_query = optional(string, null)<br/>  }))</pre> | `{}` | no |
| <a name="input_s3_block_public_access"></a> [s3\_block\_public\_access](#input\_s3\_block\_public\_access) | A collection of S3 public block access settings to apply to the account | <pre>object({<br/>    enable = optional(bool, false)<br/>    # A flag indicating if S3 block public access should be enabled<br/>    enable_block_public_policy = optional(bool, true)<br/>    # A flag indicating if S3 block public policy should be enabled<br/>    enable_block_public_acls = optional(bool, true)<br/>    # A flag indicating if S3 block public ACLs should be enabled<br/>    enable_ignore_public_acls = optional(bool, true)<br/>    # A flag indicating if S3 ignore public ACLs should be enabled<br/>    enable_restrict_public_buckets = optional(bool, true)<br/>    # A flag indicating if S3 restrict public buckets should be enabled<br/>  })</pre> | <pre>{<br/>  "enable": false,<br/>  "enable_block_public_acls": true,<br/>  "enable_block_public_policy": true,<br/>  "enable_ignore_public_acls": true,<br/>  "enable_restrict_public_buckets": true<br/>}</pre> | no |
| <a name="input_service_control_policies"></a> [service\_control\_policies](#input\_service\_control\_policies) | Provides the ability to associate one of more service control policies with an account | <pre>map(object({<br/>    name = string<br/>    # The policy name to associate with the account<br/>    policy = string<br/>    # The policy document to associate with the account<br/>  }))</pre> | `{}` | no |
| <a name="input_ssm"></a> [ssm](#input\_ssm) | Configuration for the SSM service | <pre>object({<br/>    enable_block_public_sharing = optional(bool, true)<br/>    # A flag indicating if SSM public sharing should be blocked<br/>  })</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_id"></a> [account\_id](#output\_account\_id) | The account id where the pipeline is running |
| <a name="output_auditor_account_id"></a> [auditor\_account\_id](#output\_auditor\_account\_id) | The account id for the audit account |
| <a name="output_environment"></a> [environment](#output\_environment) | The environment name for the tenant |
| <a name="output_infrastructure_repository_git_clone_url"></a> [infrastructure\_repository\_git\_clone\_url](#output\_infrastructure\_repository\_git\_clone\_url) | The URL of the infrastructure repository for the landing zone |
| <a name="output_infrastructure_repository_url"></a> [infrastructure\_repository\_url](#output\_infrastructure\_repository\_url) | The SSH URL of the infrastructure repository for the landing zone |
| <a name="output_ipam_pools_by_name"></a> [ipam\_pools\_by\_name](#output\_ipam\_pools\_by\_name) | A map of the ipam pool name to id |
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
