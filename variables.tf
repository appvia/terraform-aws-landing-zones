variable "account_alias" {
  description = "The account alias to apply to the account"
  type        = string
  default     = null
}

variable "aws_config" {
  description = "Account specific configuration for AWS Config"
  type = object({
    # A flag indicating if AWS Config should be enabled
    enable = optional(bool, false)
    # A list of compliance packs to provision in the account
    compliance_packs = optional(map(object({
      # A map of parameter overrides to apply to the compliance pack
      parameter_overrides = optional(map(string), {})
      # The URL of the compliance pack
      template_url = optional(string, "")
      # The body of the compliance pack
      template_body = optional(string, "")
    })), {})
    # A list of managed rules to provision in the account
    rules = optional(map(object({
      # The list of resource types to scope the rule
      resource_types = list(string)
      # The description of the rule
      description = string
      # The identifier of the rule
      identifier = string
      # The inputs of the rule
      inputs = optional(map(string), {})
      # The maximum execution frequency of the rule
      max_execution_frequency = optional(string, null)
      # The scope of the rule
      scope = optional(object({
        # The list of resource types to scope the rule
        compliance_resource_types = optional(list(string), [])
        # The key of the tag to scope the rule
        tag_key = optional(string, null)
        # The value of the tag to scope the rule
        tag_value = optional(string, null)
      }), null)
    })), {})
  })
  default = {
    compliance_packs = {}
    enable           = false
    input_parameters = {}
    rules            = {}
    scope            = null
  }
}

variable "budgets" {
  description = "A collection of budgets to provision"
  type = list(object({
    name         = string
    budget_type  = optional(string, "COST")
    limit_amount = optional(string, "100.0")
    limit_unit   = optional(string, "PERCENTAGE")
    time_unit    = optional(string, "MONTHLY")

    notifications = optional(map(object({
      comparison_operator = string
      notification_type   = string
      threshold           = number
      threshold_type      = string
    })), null)

    auto_adjust_data = optional(list(object({
      auto_adjust_type = string
    })), [])

    cost_filter = optional(map(object({
      values = list(string)
    })), {})

    cost_types = optional(object({
      include_credit             = optional(bool, false)
      include_discount           = optional(bool, false)
      include_other_subscription = optional(bool, false)
      include_recurring          = optional(bool, false)
      include_refund             = optional(bool, false)
      include_subscription       = optional(bool, false)
      include_support            = optional(bool, false)
      include_tax                = optional(bool, false)
      include_upfront            = optional(bool, false)
      use_blended                = optional(bool, false)
      }), {
      include_credit             = false
      include_discount           = false
      include_other_subscription = false
      include_recurring          = false
      include_refund             = false
      include_subscription       = true
      include_support            = false
      include_tax                = false
      include_upfront            = false
      use_blended                = false
    })

    tags = optional(map(string), {})
  }))
  default = []
}

variable "central_dns" {
  description = "Configuration for the hub used to centrally resolved dns requests"
  type = object({
    enable = optional(bool, false)
    # The VPC ID to use for central DNS resolution
    vpc_id = optional(string, null)
  })
  default = {
    enable = false
    vpc_id = null
  }
}

variable "cloudwatch" {
  description = "Configuration for the CloudWatch service"
  type = object({
    # Indicates if CloudWatch cross-account observability should be enabled (sink and source configuration below)
    # The observability sink configuration
    observability_sink = optional(object({
      # A flag indicating if cloudwatch cross-account observability should be enabled
      enable = optional(bool, false)
      # The AWS Identifier of the accounts that are allowed to access the observability sink
      identifiers = optional(list(string), null)
      # The AWS resource types that are allowed to be linked to the observability sink
      resource_types = optional(list(string), [
        "AWS::CloudWatch::Metric",
        "AWS::Logs::LogGroup",
        "AWS::XRay::Trace",
      ])
    }), null)
    observability_source = optional(object({
      # A flag indicating if cloudwatch cross-account observability should be enabled
      enable = optional(bool, false)
      # The name of the cloudwatch cross-account observability
      account_id = optional(string, null)
      # The OAM sink identifier i.e. arn:aws:oam:region:account-id:sink/sink-id
      sink_identifier = optional(string, null)
      # The resource types to link to the observability source
      resource_types = optional(list(string), [
        "AWS::CloudWatch::Metric",
        "AWS::Logs::LogGroup",
        "AWS::XRay::Trace",
      ])
    }), null)
    # Collection of account subscriptions to provision
    account_subscriptions = optional(map(object({
      # The policy document to apply to the subscription
      policy = optional(string, null)
      # The selection criteria to apply to the subscription
      selection_criteria = optional(string, null)
    })), {})
  })
  default = {
    account_subscriptions = {}
    observability_sink    = null
    observability_source  = null
  }
}

variable "cost_anomaly_detection" {
  description = "A collection of cost anomaly detection monitors to apply to the account"
  type = object({
    enable = optional(bool, true)
    # Cost anomaly detection monitors to apply to the account
    monitors = optional(list(object({
      # The name of the anomaly detection rule
      name = string
      # How often the monitor is evaluated
      frequency = optional(string, "IMMEDIATE")
      # The dimension of the anomaly detection rule, either SERVICE or DIMENSIONAL
      threshold_expression = optional(list(object({
        # The expression to apply to the cost anomaly detection monitor
        and = object({
          dimension = object({
            # The key of the dimension
            key = string
            # The match options of the dimension
            match_options = list(string)
            # The values of the dimension
            values = list(string)
          })
        })
      })), [])
      # The specification of the anomaly detection monitor
      # see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ce_anomaly_monitor
      specification = optional(string, "")
    })), [])
  })
  default = {
    enable   = true
    monitors = []
  }
}

variable "cost_center" {
  description = "The cost center of the product, and injected into all resource tags"
  type        = string
  default     = null
}

variable "dns" {
  description = "A collection of DNS zones to provision and associate with networks"
  type = map(object({
    # A comment associated with the DNS zone
    comment = optional(string, "Managed by zone created by terraform")
    # A list of network names to associate with the DNS zone
    network = string
    # A flag indicating if the DNS zone is private or public
    private = optional(bool, true)
  }))
  default = {}

  # Domain name (map key) must end with aws.appvia.local
  validation {
    condition     = alltrue([for domain in keys(var.dns) : can(regex(".*aws.appvia.local$", domain))])
    error_message = "The domain name must end with aws.appvia.local"
  }
}

variable "ebs_encryption" {
  description = "A collection of EBS encryption settings to apply to the account"
  type = object({
    # A flag indicating if EBS encryption should be enabled
    enable = optional(bool, false)
    # A flag indicating if an EBS encryption key should be created
    create_kms_key = optional(bool, true)
    # The number of days to retain the key before deletion when the key is removed
    key_deletion_window_in_days = optional(number, 10)
    # The alias of the EBS encryption key when provisioning a new key
    key_alias = optional(string, "lza/ebs/default")
    # The ARN of an existing EBS encryption key to use for EBS encryption
    key_arn = optional(string, null)
  })
  default = null
}

variable "ebs_snapshots_block" {
  description = "Configuration for blocking EBS snapshots in the account, either block for all volumes, only new volumes, or allow snapshots as normal"
  type = object({
    # The state of the EBS snapshot block — if enabled, all EBS volumes will have snapshot creation blocked (block-all-sharing, block-new-sharing or unblocked)
    state = optional(string, "block-all-sharing")
  })
  default = null
}

variable "environment" {
  description = "The environment in which to provision resources"
  type        = string
}

variable "git_repository" {
  description = "The git repository to use for the account"
  type        = string
}

variable "guardduty" {
  description = "A collection of GuardDuty settings to apply to the account"
  type = object({
    # A flag indicating if GuardDuty should be created
    create = optional(bool, false)
    # The frequency of finding publishing
    finding_publishing_frequency = optional(string, "FIFTEEN_MINUTES")
    # Configuration for each GuardDuty detector
    detectors = optional(list(object({
      # The name of the detector
      name = string
      # A flag indicating if the detector is enabled
      enable = optional(bool, true)
      additional_configuration = optional(list(object({
        # The name of the additional configuration
        name = string
        # A flag indicating if the additional configuration is enabled
        enable = optional(bool, true)
      })), [])
    })), [])
    # GuardDuty filters (map key is the filter name)
    filters = optional(map(object({
      # The action of the filter
      action = string
      # The rank of the filter
      rank = number
      # The description of the filter
      description = string
      # The criterion of the filter
      criterion = list(object({
        # The field of the criterion
        field = string
        # The equals of the criterion
        equals = optional(string, null)
        # The not equals of the criterion
        not_equals = optional(string, null)
        # The greater than of the criterion
        greater_than = optional(string, null)
        # The greater than or equal of the criterion
        greater_than_or_equal = optional(string, null)
        # The less than of the criterion
        less_than = optional(string, null)
        # The less than or equal of the criterion
        less_than_or_equal = optional(string, null)
      }))
    })), {})
  })
  default = null
}

variable "home_region" {
  description = "The home region in which to provision global resources"
  type        = string

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.home_region))
    error_message = "The home region must be in the format of a valid AWS region"
  }
}

variable "iam_access_analyzer" {
  description = "The IAM access analyzer configuration to apply to the account"
  type = object({
    # A flag indicating if IAM access analyzer should be enabled
    enable = optional(bool, false)
    # The name of the IAM access analyzer
    analyzer_name = optional(string, "lza-iam-access-analyzer")
    # The type of the IAM access analyzer
    analyzer_type = optional(string, "ORGANIZATION")
  })
  default = {
    analyzer_name = "lza-iam-access-analyzer"
    analyzer_type = "ORGANIZATION"
    enable        = true
  }

  validation {
    condition     = var.iam_access_analyzer.analyzer_type == "ORGANIZATION" || var.iam_access_analyzer.analyzer_type == "ACCOUNT"
    error_message = "The analyzer type must be ORGANIZATION or ACCOUNT"
  }

  validation {
    condition     = length(var.iam_access_analyzer.analyzer_name) > 0
    error_message = "The analyzer name must be greater than 0"
  }

  validation {
    condition     = length(var.iam_access_analyzer.analyzer_name) <= 32
    error_message = "The analyzer name must be less than or equal to 32"
  }
}

variable "iam_groups" {
  description = "A collection of IAM groups to apply to the account"
  type = list(object({
    # A flag indicating if MFA should be enforced
    enforce_mfa = optional(bool, true)
    # The name prefix of the IAM group
    name = optional(string, null)
    # The path of the IAM group
    path = optional(string, "/")
    # A list of policies to apply to the IAM group
    policies = optional(list(string), [])
    # A list of users to apply to the IAM group
    users = optional(list(string), [])
  }))
  default = []
}

variable "iam_instance_profiles" {
  description = "A collection of IAM instance profiles to apply to the account"
  type = map(object({
    # The name prefix of the IAM instance profile
    name = optional(string, null)
    # The path of the IAM instance profile
    path = optional(string, "/")
    # A list of roles to apply to the IAM instance profile
    permission_arns = optional(list(string), [])
  }))
  default = {}
}

variable "iam_password_policy" {
  description = "The IAM password policy to apply to the account"
  type = object({
    # A flag indicating if IAM password policy should be enabled
    enable = optional(bool, false)
    # A flag indicating if users can change their password
    allow_users_to_change_password = optional(bool, true)
    # A flag indicating if a hard expiry should be enforced
    hard_expiry = optional(bool, false)
    # The maximum password age
    max_password_age = optional(number, 90)
    # The minimum password length
    minimum_password_length = optional(number, 16)
    # The number of passwords to prevent reuse
    password_reuse_prevention = optional(number, 24)
    # A flag indicating if lowercase characters are required
    require_lowercase_characters = optional(bool, true)
    # A flag indicating if numbers are required
    require_numbers = optional(bool, true)
    # A flag indicating if symbols are required
    require_symbols = optional(bool, true)
    # A flag indicating if uppercase characters are required
    require_uppercase_characters = optional(bool, true)
  })
  default = {}
}

variable "iam_policies" {
  description = "A collection of IAM policies to apply to the account"
  type = map(object({
    # The name of the IAM policy
    name = optional(string, null)
    # The name prefix of the IAM policy
    name_prefix = optional(string, null)
    # The description of the IAM policy
    description = string
    # The path of the IAM policy
    path = optional(string, "/")
    # The policy document to apply to the IAM policy
    policy = string
  }))
  default = {}

  validation {
    condition     = alltrue([for policy in values(var.iam_policies) : length(policy.name) > 0 || length(policy.name_prefix) > 0])
    error_message = "The name or name prefix must be greater than 0"
  }
}

variable "iam_roles" {
  description = "A collection of IAM roles to apply to the account"
  type = map(object({
    # The name of the IAM role
    name = optional(string, null)
    # The name prefix of the IAM role
    name_prefix = optional(string, null)
    # List of accounts to assume the role
    assume_accounts = optional(list(string), [])
    # List of principals to assume the role
    assume_roles = optional(list(string), [])
    # List of services to assume the role
    assume_services = optional(list(string), [])
    # The description of the IAM role
    description = string
    # The path of the IAM role
    path = optional(string, "/")
    # The ARN of the permissions boundary to apply to the IAM role
    permission_boundary_arn = optional(string, "")
    # A list of additional permissions to apply to the IAM role
    permission_arns = optional(list(string), [])
    policies        = optional(any, [])
  }))
  default = {}

  validation {
    condition     = alltrue([for role in values(var.iam_roles) : role.name != null || role.name_prefix != null])
    error_message = "The name or name prefix must be greater than 0"
  }
}

variable "iam_service_linked_roles" {
  description = "A collection of service linked roles to apply to the account"
  type        = list(string)
  default = [
    "autoscaling.amazonaws.com",
    "spot.amazonaws.com",
    "spotfleet.amazonaws.com",
  ]
}

variable "iam_users" {
  description = "A collection of IAM users to apply to the account"
  type = list(object({
    # The name of the IAM user
    name = optional(string, null)
    # The name prefix of the IAM user
    name_prefix = optional(string, null)
    # The path of the IAM user
    path = optional(string, "/")
    # The name of the permissions boundary to apply to the IAM user
    permission_boundary_name = optional(string, null)
    # A list of additional permissions to apply to the IAM user
    policy_arns = optional(list(string), [])
  }))
  default = []
}

variable "include_iam_roles" {
  description = "Collection of IAM roles to include in the account"
  type = object({
    security_auditor = optional(object({
      enable = optional(bool, false)
      name   = optional(string, "lza-security-auditor")
    }), {})
    ssm_instance = optional(object({
      enable = optional(bool, false)
      name   = optional(string, "lza-ssm-instance")
    }), {})
  })
  default = {
    security_auditor = {
      enable = false
      name   = "lza-security-auditor"
    }
    ssm_instance = {
      enable = false
      name   = "lza-ssm-instance"
    }
  }
}

variable "infrastructure_repository" {
  description = "The infrastructure repository provisions and configures a pipeline repository for the landing zone"
  type = object({
    # The name prefix of the repository
    name = optional(string, null)
    # A flag indicating if the repository should be created
    create = optional(bool, true)
    # The visibility of the repository
    visibility = optional(string, "private")
    # The default branch of the repository
    default_branch = optional(string, "main")
    # The home page URL of the repository
    homepage_url = optional(string, null)
    # A flag indicating if the repository should be archived
    enable_archived = optional(bool, false)
    # A flag indicating if the repository should enable discussions
    enable_discussions = optional(bool, false)
    # A flag indicating if the repository should enable issues
    enable_issues = optional(bool, true)
    # A flag indicating if the repository should enable projects
    enable_projects = optional(bool, false)
    # A flag indicating if the repository should enable wiki
    enable_wiki = optional(bool, false)
    # A flag indicating if the repository should enable vulnerability alerts
    enable_vulnerability_alerts = optional(bool, null)
    # The topics of the repository
    topics = optional(list(string), ["aws", "terraform", "landing-zone"])
    # The collaborators of the repository
    collaborators = optional(list(object({
      # The username of the collaborator
      username = string
      # The permission of the collaborator
      permission = optional(string, "write")
    })), [])
    # The repository template to create the repository from
    template = optional(object({
      # The owner of the repository template
      owner = string
      # The repository template to use for the repository
      repository = string
      # Include all branches
      include_all_branches = optional(bool, false)
    }), null)
    # Webhooks to configure for the repository
    webhooks = optional(list(object({
      # The content type of the webhook
      content_type = optional(string, "json")
      # A flag indicating if the webhook is enabled
      enable = optional(bool, true)
      # The events of the webhook
      events = optional(list(string), ["push", "pull_request"])
      # A flag indicating if insecure SSL is allowed for the webhook
      insecure_ssl = optional(bool, false)
      # The secret of the webhook
      secret = optional(string, null)
      # The URL of the webhook
      url = string
    })), null)
    # Branch protection rules for the repository (map key is the branch name)
    branch_protection = optional(map(object({
      allows_force_pushes             = optional(bool, false)
      allows_deletions                = optional(bool, false)
      dismiss_stale_reviews           = optional(bool, true)
      enforce_admins                  = optional(bool, true)
      lock_branch                     = optional(bool, false)
      require_conversation_resolution = optional(bool, false)
      require_last_push_approval      = optional(bool, false)
      require_signed_commits          = optional(bool, true)
      required_linear_history         = optional(bool, false)

      required_status_checks = optional(object({
        strict   = optional(bool, true)
        contexts = optional(list(string), null)
      }), null)

      required_pull_request_reviews = optional(object({
        dismiss_stale_reviews           = optional(bool, true)
        dismissal_restrictions          = optional(list(string), null)
        pull_request_bypassers          = optional(list(string), null)
        require_code_owner_reviews      = optional(bool, true)
        require_last_push_approval      = optional(bool, false)
        required_approving_review_count = optional(number, 1)
        restrict_dismissals             = optional(bool, false)
      }), null)
      })), {
      main = {
        allows_force_pushes             = false
        allows_deletions                = false
        dismiss_stale_reviews           = true
        enforce_admins                  = true
        require_conversation_resolution = true
        require_signed_commits          = true
        required_approving_review_count = 2

        required_status_checks = {
          strict   = true
          contexts = null
        }
      }
    })

    # IAM policy ARNs to attach for repository access (read-only and read-write)
    permissions = optional(object({
      # The policy ARNs to associate for read-only access
      read_only_policy_arns = list(string)
      # The policy ARNs to associate for read-write access
      read_write_policy_arns = list(string)
      }), {
      read_only_policy_arns  = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
      read_write_policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
    })

    # The permissions boundary to use for the repository
    permissions_boundary = optional(object({
      # The ARN of the permissions boundary to use for the repository
      arn = optional(string, null)
      # The policy of the permissions boundary to use for the repository
      policy = optional(string, null)
    }), null)
  })
  default = null
}

variable "inspector" {
  description = "Configuration for the AWS Inspector service"
  type = object({
    # A flag indicating if AWS Inspector should be enabled
    enable = optional(bool, false)
    # The account ID we should associate the service to
    delegate_account_id = optional(string, null)
  })
  default = null
}

variable "kms_administrator" {
  description = "Configuration for the default kms administrator role to use for the account"
  type = object({
    # A list of account IDs that can assume the KMS administrator role
    assume_accounts = optional(list(string), [])
    # A list of IAM role ARNs that can assume the KMS administrator role
    assume_roles = optional(list(string), [])
    # A list of services that can assume the KMS administrator role
    assume_services = optional(list(string), [])
    # The description of the default KMS administrator role
    description = optional(string, "Provides access to administer the KMS keys for the account")
    # A flag indicating if the default KMS administrator role should be enabled
    enable = optional(bool, false)
    # A flag indicating if the account root can administer KMS keys
    enable_account_root = optional(bool, false)
    # The name of the default KMS administrator role
    name = optional(string, "lza-kms-adminstrator")
  })
  default = {
    assume_accounts     = []
    assume_roles        = []
    assume_services     = []
    description         = "Provides access to administer the KMS keys for the account"
    enable              = false
    enable_account_root = false
    name                = "lza-kms-adminstrator"
  }
}

variable "kms_key" {
  description = "Configuration for the default kms encryption key to use for the account (per region)"
  type = object({
    # A flag indicating if account encryption should be enabled
    enable = optional(bool, false)
    # The number of days to retain the key before deletion when the key is removed
    key_deletion_window_in_days = optional(number, 7)
    # The alias of the account encryption key when provisioning a new key
    key_alias = optional(string, null)
    # A list of ARNs of the key administrators
    key_administrators = optional(list(string), [])
    # A list of ARNs of the key owners
    key_owners = optional(list(string), [])
    # A list of ARNs of the key users — if unset, it will default to the account
    key_users = optional(list(string), [])
  })
  default = {
    enable                      = false
    key_administrators          = []
    key_alias                   = "lza/account/default"
    key_deletion_window_in_days = 7
    key_owners                  = []
    key_users                   = []
  }
}

variable "macie" {
  description = "A collection of Macie settings to apply to the account"
  type = object({
    # A flag indicating if Macie should be enabled
    enable = optional(bool, false)
    # The frequency of Macie findings publication
    frequency = optional(string, "FIFTEEN_MINUTES")
    # When set, the member account will accept invitations from the management account
    admin_account_id = optional(string, null)
  })
  default = null
}

variable "networks" {
  description = "A collection of networks to provision within the designated region"
  type = map(object({
    firewall = optional(object({
      # The capacity of the firewall rule group
      capacity = number
      # The content of the suricata rules
      rules_source = string
      # A map of IP sets to apply to the firewall rule ie. WEBSERVERS = ["100.0.0.0/16"]
      ip_sets = map(list(string))
      # A map of port sets to apply to the firewall rule ie. WEBSERVERS = [80, 443]
      port_sets         = map(list(number))
      domains_whitelist = list(string)
    }), null)

    # Additional tags to apply to the private subnet
    private_subnet_tags = optional(map(string), {})
    # Additional tags to apply to the public subnet
    public_subnet_tags = optional(map(string), {})

    subnets = map(object({
      # The CIDR block of the subnet
      cidr = optional(string, null)
      # The netmask length of the subnet
      netmask = optional(number, 0)
      # Additional tags to apply to the subnet
      tags = optional(map(string), {})
    }))

    # A collection of tags to apply to the network — these will be merged with the global tags
    tags = optional(map(string), {})

    # Configuration for the transit gateway for this network
    transit_gateway = optional(object({
      # The transit gateway ID to associate with the network
      gateway_id = optional(string, null)
      # Optional ID of the transit gateway route table to associate with the network
      gateway_route_table_id = optional(string, null)
      # A map used to associate routes with subnets provisioned by the module — e.g. ensure
      # all private subnets push traffic via the transit gateway
      gateway_routes = optional(map(string), null)
      }), {
      gateway_id             = null
      gateway_route_table_id = null
      gateway_routes         = null
    })

    vpc = object({
      # The number of availability zones in which to provision the network (defaults to 2)
      availability_zones = optional(string, 2)
      # The CIDR block of the VPC network if not using IPAM
      cidr = optional(string, null)
      # An optional list of private endpoints to associate with the network i.e ["s3", "dynamodb"]
      enable_private_endpoints = optional(list(string), [])
      # Indicates if the network should accept shared endpoints
      enable_shared_endpoints = optional(bool, true)
      # A flag indicating if the network should be associated with the transit gateway
      enable_transit_gateway = optional(bool, true)
      # A flag indicating if the transit gateway should be in appliance mode
      enable_transit_gateway_appliance_mode = optional(bool, false)
      # A flag indicating if the default route table should be associated with the network
      enable_default_route_table_association = optional(bool, true)
      # A flag indicating if the default route table should be propagated to the network
      enable_default_route_table_propagation = optional(bool, true)
      flow_logs = optional(object({
        # The destination type of the flow logs
        destination_type = optional(string, "none")
        # The ARN of the destination of the flow logs
        destination_arn = optional(string, null)
        # The format of the flow logs
        log_format = optional(string, "plain-text")
        # The type of traffic to capture
        traffic_type = optional(string, "ALL")
        # The destination options of the flow logs
        destination_options = optional(object({
          # The format of the flow logs
          file_format = optional(string, "plain-text")
          # Whether to use hive compatible partitions
          hive_compatible_partitions = optional(bool, false)
          # Whether to partition the flow logs per hour
          per_hour_partition = optional(bool, false)
        }), null)
      }), null)
      # The name of the IPAM pool to use for the network
      ipam_pool_name = optional(string, null)
      # The NAT gateway mode to use for the network, defaults to none
      nat_gateway_mode = optional(string, "none")
      # The netmask of the VPC network if using IPAM
      netmask = optional(number, null)
      # Routes to associate with the transit gateway for this VPC
      transit_gateway_routes = optional(map(string), null)
    })
  }))
  default = {}

  # The availability zone must be greater than 0
  validation {
    condition     = alltrue([for network in var.networks : network.vpc.availability_zones > 0])
    error_message = "The availability zone must be greater than 0"
  }

  # We must have a private subnet defined in subnets
  validation {
    condition     = alltrue([for network in var.networks : contains(keys(network.subnets), "private")])
    error_message = "We must have a 'private' subnet defined in subnets"
  }

  # The private subnet netmask must be between 0 and 32
  validation {
    condition     = alltrue([for network in var.networks : network.subnets["private"].netmask >= 0 && network.subnets["private"].netmask <= 32])
    error_message = "The private subnet netmask must be between 0 and 32"
  }

  # The nat mode can only be none, single or all_azs
  validation {
    condition     = alltrue([for network in var.networks : contains(["none", "single_az", "all_azs"], network.vpc.nat_gateway_mode)])
    error_message = "The nat mode can only be none, single_az or all_azs"
  }
}

variable "notifications" {
  description = "Configuration for the notifications to the owner of the account"
  type = object({
    email = optional(object({
      # A list of email addresses to send notifications to
      addresses = optional(list(string), [])
      }), {
      addresses = []
    })

    slack = optional(object({
      # The Slack webhook_arn to a secret in Secrets Manager containing the webhook_url
      webhook_arn = optional(string, null)
      # The Slack webhook_url to send notifications to
      webhook_url = optional(string, null)
    }), null)

    teams = optional(object({
      # The Teams webhook_arn to a secret in Secrets Manager containing the webhook_url
      webhook_arn = optional(string, null)
      # The Teams webhook_url to send notifications to
      webhook_url = optional(string, null)
    }), null)

    # The services to configure for notifications
    services = optional(object({
      securityhub = object({
        # A flag indicating if Security Hub notifications should be enabled
        enable = optional(bool, false)
        # The SNS topic name created per region in the account to receive notifications and forward them via email or other means
        eventbridge_rule_name = optional(string, "lza-securityhub-eventbridge")
        # The severity of the Security Hub events to forward
        severity = optional(list(string), ["CRITICAL"])
      })
      }), {
      securityhub = {
        enable                = false
        eventbridge_rule_name = "lza-securityhub-eventbridge"
        severity              = ["CRITICAL"]
      }
    })
  })
  default = {
    email = {
      addresses = []
    }
    slack = null
    teams = null
  }
}

variable "owner" {
  description = "The owner of the product, and injected into all resource tags"
  type        = string

  validation {
    condition     = length(var.owner) > 0
    error_message = "The owner must be greater than 0"
  }

  validation {
    condition     = length(var.owner) <= 64
    error_message = "The owner must be less than or equal to 64"
  }

  validation {
    condition     = can(regex("^[a-zA-Z0-9-_]+$", var.owner))
    error_message = "The owner must be alphanumeric and contain only hyphens and underscores"
  }
}

variable "product" {
  description = "The name of the product to provision resources and inject into all resource tags"
  type        = string

  validation {
    condition     = length(var.product) > 0
    error_message = "The product name must be greater than 0"
  }

  validation {
    condition     = length(var.product) <= 16
    error_message = "The product name must be less than or equal to 16"
  }

  validation {
    condition     = can(regex("^[a-zA-Z0-9-_]+$", var.product))
    error_message = "The product name must be alphanumeric and contain only hyphens and underscores"
  }
}

variable "resilience_hub" {
  description = "Configuration for the resilience hub service"
  type = object({
    # Enable the service within the account, creating the IAM role
    enable = optional(bool, false)
    # A collection of policies to apply to the resilience hub
    policies = optional(map(object({
      # The name of the policy, else we use the map key
      name = optional(string, null)
      # The description of the policy
      description = string
      # The tier associated with the policy (MissionCritical, Critical, Important, CoreServices, NonCritical, and NotApplicable)
      tier = optional(string, "Important")
      # The policy document to apply to the policy
      policy = optional(object({
        # Availability zone recovery point objectives
        az = optional(object({
          # The RPO or recommended recovery point objective
          rpo = optional(string, "1h")
          # The RTO or recommended recovery time
          rto = optional(string, "1h")
        }), {})
        # The policy associated with hardware recovery
        hardware = optional(object({
          # The RPO or recommended recovery point objective
          rpo = optional(string, "1h")
          # The RTO or recommended recovery time
          rto = optional(string, "1h")
        }), {})
        # The policy associated with software recovery
        software = optional(object({
          # The RPO or recommended recovery point objective
          rpo = optional(string, "1h")
          # The RTO or recommended recovery time
          rto = optional(string, "1h")
        }), {})
        # The policy associated with regional recovery
        region = optional(object({
          # The RPO or recommended recovery point objective
          rpo = optional(string, "1 hour")
          # The RTO or recommended recovery time
          rto = optional(string, "1 hour")
        }), {})
      }), {})
    })), {})
  })
  default = {
    enable = false
  }
}

variable "resource_groups" {
  description = "Configuration for the resource groups service"
  type = map(object({
    # The description of the resource group
    description = string
    # The type of the group configuration
    type = optional(string, "TAG_FILTERS_1_0")
    # An optional configuration for the resource group
    configuration = optional(object({
      # The type of the group configuration
      type = string
      # The parameters of the group configuration
      parameters = optional(list(object({
        # The name of the parameter
        name = string
        # The list of values for the parameter
        values = list(string)
      })), [])
    }), null)
    # The resource query to configure the resource group
    query = optional(object({
      # A collection of resource types to scope the resource query
      resource_type_filters = optional(list(string), ["AWS::AllSupported"])
      # A collection of tag filters to scope the resource query
      tag_filters = optional(map(list(string)), {})
    }), null)
    # The resource query in JSON format https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/resourcegroups_group
    resource_query = optional(string, null)
  }))
  default = {}
}

variable "s3_block_public_access" {
  description = "A collection of S3 public block access settings to apply to the account"
  type = object({
    # A flag indicating if S3 Block Public Access should be enabled for the account
    enable = optional(bool, false)
    # A flag indicating if S3 block public bucket policies should be enabled
    enable_block_public_policy = optional(bool, true)
    # A flag indicating if S3 block public ACLs should be enabled
    enable_block_public_acls = optional(bool, true)
    # A flag indicating if S3 ignore public ACLs should be enabled
    enable_ignore_public_acls = optional(bool, true)
    # A flag indicating if S3 restrict public buckets should be enabled
    enable_restrict_public_buckets = optional(bool, true)
  })
  default = {
    enable                         = false
    enable_block_public_policy     = true
    enable_block_public_acls       = true
    enable_ignore_public_acls      = true
    enable_restrict_public_buckets = true
  }
}

variable "service_quotas" {
  description = "Configuration for the service quotas service"
  type = list(object({
    # The service code of the service quota
    service_code = string
    # The quota code of the service quota
    quota_code = string
    # The desired value of the service quota
    value = number
  }))
  default = []
}

variable "ssm" {
  description = "Configuration for the SSM service"
  type = object({
    # A flag indicating if SSM public sharing should be blocked
    enable_block_public_sharing = optional(bool, true)
  })
  default = {}
}

variable "tags" {
  description = "A collection of tags to apply to resources"
  type        = map(string)
}
