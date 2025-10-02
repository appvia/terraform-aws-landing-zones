
variable "home_region" {
  description = "The home region in which to provision global resources"
  type        = string

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.home_region))
    error_message = "The home region must be in the format of a valid AWS region"
  }
}

variable "aws_config" {
  description = "Account specific configuration for AWS Config"
  type = object({
    enable = optional(bool, false)
    # A flag indicating if AWS Config should be enabled
    compliance_packs = map(object({
      parameter_overrides = optional(map(string), {})
      # A map of parameter overrides to apply to the compliance pack
      template_url = optional(string, "")
      # The URL of the compliance pack
      template_body = optional(string, "")
    }))
    ## A list of compliance packs to provision in the account
  })
  default = {
    enable           = false
    compliance_packs = {}
  }
}

variable "inspector" {
  description = "Configuration for the AWS Inspector service"
  type = object({
    enable = optional(bool, false)
    # A flag indicating if AWS Inspector should be enabled
    delegate_account_id = optional(string, null)
    # The account ID we should associate the service to
  })
  default = null
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

variable "cost_anomaly_detection" {
  description = "A collection of cost anomaly detection monitors to apply to the account"
  type = object({
    enable = optional(bool, true)
    # A flag indicating if the default monitors should be enabled
    monitors = optional(list(object({
      name = string
      # The name of the anomaly detection rule
      frequency = optional(string, "IMMEDIATE")
      # The dimension of the anomaly detection rule, either SERVICE or DIMENSIONAL
      threshold_expression = optional(list(object({
        and = object({
          dimension = object({
            key = string
            # The key of the dimension
            match_options = list(string)
            # The match options of the dimension
            values = list(string)
            # The values of the dimension
          })
        })
        # The expression to apply to the cost anomaly detection monitor
      })), [])
      # The expression to apply to the anomaly detection rule
      # see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ce_anomaly_monitor
      specification = optional(string, "")
      # The specification to anomaly detection monitor
      # see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ce_anomaly_monitor
    })), [])
  })
  default = {
    enable   = true
    monitors = []
  }
}

variable "central_dns" {
  description = "Configuration for the hub used to centrally resolved dns requests"
  type = object({
    enable = optional(bool, false)
    # The domain name to use for the central DNS
    vpc_id = optional(string, null)
  })
  default = {
    enable = false
    vpc_id = null
  }
}

variable "kms_administrator" {
  description = "Configuration for the default kms administrator role to use for the account"
  type = object({
    # The domain name to use for the central DNS
    assume_accounts = optional(list(string), [])
    # A list of roles to assume the kms administrator role
    assume_roles = optional(list(string), [])
    # A list of roles to assume the kms administrator role
    assume_services = optional(list(string), [])
    # A list of services to assume the kms administrator role
    description = optional(string, "Provides access to administer the KMS keys for the account")
    # The description of the default kms administrator role
    enable = optional(bool, false)
    # A flag indicating if the default kms administrator role should be enabled
    enable_account_root = optional(bool, false)
    # A flag indicating if the account root should be enabled
    name = optional(string, "lza-kms-adminstrator")
    # The name of the default kms administrator role
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
    enable = optional(bool, false)
    # A flag indicating if account encryption should be enabled
    key_deletion_window_in_days = optional(number, 7)
    # The number of days to retain the key before deletion when the key is removed
    key_alias = optional(string, null)
    # The alias of the account encryption key when provisioning a new key
    key_administrators = optional(list(string), [])
    # A list of ARN of the key administrators
    key_owners = optional(list(string), [])
    # A list of ARN of the key owners
    key_users = optional(list(string), [])
    # A list of ARN of the key users - if unset, it will default to the account
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

variable "account_alias" {
  description = "The account alias to apply to the account"
  type        = string
  default     = null
}

variable "dns" {
  description = "A collection of DNS zones to provision and associate with networks"
  type = map(object({
    comment = optional(string, "Managed by zone created by terraform")
    # A comment associated with the DNS zone
    network = string
    # A list of network names to associate with the DNS zone
    private = optional(bool, true)
    # A flag indicating if the DNS zone is private or public
  }))
  default = {}

  ## Domain name (map key) must end with aws.appvia.local
  validation {
    condition     = alltrue([for domain in keys(var.dns) : can(regex(".*aws.appvia.local$", domain))])
    error_message = "The domain name must end with aws.appvia.local"
  }
}

variable "iam_groups" {
  description = "A collection of IAM groups to apply to the account"
  type = list(object({
    enforce_mfa = optional(bool, true)
    # A flag indicating if MFA should be enforced
    name = optional(string, null)
    # The name prefix of the IAM group
    path = optional(string, "/")
    # The path of the IAM group
    policies = optional(list(string), [])
    # A list of policies to apply to the IAM group
    users = optional(list(string), [])
    # A list of users to apply to the IAM group
  }))
  default = []
}

variable "iam_users" {
  description = "A collection of IAM users to apply to the account"
  type = list(object({
    name = optional(string, null)
    # The name of the IAM user
    name_prefix = optional(string, null)
    # The name prefix of the IAM user
    path = optional(string, "/")
    # The path of the IAM user
    permission_boundary_name = optional(string, null)
    # A list of additional permissions to apply to the IAM user
    policy_arns = optional(list(string), [])
  }))
  default = []
}

variable "iam_password_policy" {
  description = "The IAM password policy to apply to the account"
  type = object({
    enable = optional(bool, false)
    # A flag indicating if IAM password policy should be enabled
    allow_users_to_change_password = optional(bool, true)
    # A flag indicating if users can change their password
    hard_expiry = optional(bool, false)
    # A flag indicating if a hard expiry should be enforced
    max_password_age = optional(number, 90)
    # The maximum password age
    minimum_password_length = optional(number, 16)
    # The minimum password length
    password_reuse_prevention = optional(number, 24)
    # The number of passwords to prevent reuse
    require_lowercase_characters = optional(bool, true)
    # A flag indicating if lowercase characters are required
    require_numbers = optional(bool, true)
    # A flag indicating if numbers are required
    require_symbols = optional(bool, true)
    # A flag indicating if symbols are required
    require_uppercase_characters = optional(bool, true)
    # A flag indicating if uppercase characters are required
  })
  default = {}
}

variable "iam_instance_profiles" {
  description = "A collection of IAM instance profiles to apply to the account"
  type = map(object({
    name = optional(string, null)
    # The name prefix of the IAM instance profile
    path = optional(string, "/")
    # The path of the IAM instance profile
    permission_arns = optional(list(string), [])
    # A list of roles to apply to the IAM instance profile
  }))
  default = {}
}

variable "iam_roles" {
  description = "A collection of IAM roles to apply to the account"
  type = map(object({
    name = optional(string, null)
    # The name of the IAM role
    name_prefix = optional(string, null)
    # The name prefix of the IAM role
    assume_accounts = optional(list(string), [])
    # List of accounts to assume the role
    assume_roles = optional(list(string), [])
    # List of principals to assume the role
    assume_services = optional(list(string), [])
    # List of services to assume the role
    description = string
    # The description of the IAM role
    path = optional(string, "/")
    # The path of the IAM role
    permission_boundary_arn = optional(string, "")
    # A collection of tags to apply to the IAM role
    permission_arns = optional(list(string), [])
    # A list of additional permissions to apply to the IAM role
    policies = optional(any, [])
  }))
  default = {}

  validation {
    condition     = alltrue([for role in values(var.iam_roles) : role.name != null || role.name_prefix != null])
    error_message = "The name or name prefix must be greater than 0"
  }
}

variable "iam_policies" {
  description = "A collection of IAM policies to apply to the account"
  type = map(object({
    name = optional(string, null)
    # The name of the IAM policy
    name_prefix = optional(string, null)
    # The name prefix of the IAM policy
    description = string
    # The description of the IAM policy
    path = optional(string, "/")
    # The path of the IAM policy
    policy = string
    # The policy document to apply to the IAM policy
  }))
  default = {}

  validation {
    condition     = alltrue([for policy in values(var.iam_policies) : length(policy.name) > 0 || length(policy.name_prefix) > 0])
    error_message = "The name or name prefix must be greater than 0"
  }
}

variable "iam_access_analyzer" {
  description = "The IAM access analyzer configuration to apply to the account"
  type = object({
    enable = optional(bool, false)
    # A flag indicating if IAM access analyzer should be enabled
    analyzer_name = optional(string, "lza-iam-access-analyzer")
    # The name of the IAM access analyzer
    analyzer_type = optional(string, "ORGANIZATION")
    # The type of the IAM access analyzer
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

variable "macie" {
  description = "A collection of Macie settings to apply to the account"
  type = object({
    enable = optional(bool, false)
    # A flag indicating if Macie should be enabled
    frequency = optional(string, "FIFTEEN_MINUTES")
    # The frequency of Macie findings
    admin_account_id = optional(string, null)
    # Is defined the member account will accept any invitations from the management account
  })
  default = null
}

variable "git_repository" {
  description = "The git repository to use for the account"
  type        = string
}

variable "identity_center_permitted_roles" {
  description = "A map of permitted SSO roles, with the name of the permitted SSO role as the key, and value the permissionset"
  type        = map(string)
  default = {
    "network_viewer"   = "NetworkViewer"
    "security_auditor" = "SecurityAuditor"
  }
}

variable "guardduty" {
  description = "A collection of GuardDuty settings to apply to the account"
  type = object({
    # A flag indicating if GuardDuty should be created
    finding_publishing_frequency = optional(string, "FIFTEEN_MINUTES")
    # The frequency of finding publishing
    detectors = optional(list(object({
      name = string
      # The name of the detector
      enable = optional(bool, true)
      # The frequency of finding publishing
      additional_configuration = optional(list(object({
        name = string
        # The name of the additional configuration
        enable = optional(bool, true)
        # The status of the additional configuration
      })), [])
    })), [])
    # Configuration for the detector
    filters = optional(map(object({
      # The name of the filter
      action = string
      # The action of the filter
      rank = number
      # The rank of the filter
      description = string
      # The description of the filter
      criterion = list(object({
        field = string
        # The field of the criterion
        equals = optional(string, null)
        # The equals of the criterion
        not_equals = optional(string, null)
        # The not equals of the criterion
        greater_than = optional(string, null)
        # The greater than of the criterion
        greater_than_or_equal = optional(string, null)
        # The greater than or equal of the criterion
        less_than = optional(string, null)
        # The less than of the criterion
        less_than_or_equal = optional(string, null)
        # The less than or equal of the criterion
      }))
      # The criterion of the filter
    })), {})
  })
  default = null
}

variable "s3_block_public_access" {
  description = "A collection of S3 public block access settings to apply to the account"
  type = object({
    enable = optional(bool, false)
    # A flag indicating if S3 block public access should be enabled
    enable_block_public_policy = optional(bool, true)
    # A flag indicating if S3 block public policy should be enabled
    enable_block_public_acls = optional(bool, true)
    # A flag indicating if S3 block public ACLs should be enabled
    enable_ignore_public_acls = optional(bool, true)
    # A flag indicating if S3 ignore public ACLs should be enabled
    enable_restrict_public_buckets = optional(bool, true)
    # A flag indicating if S3 restrict public buckets should be enabled
  })
  default = {
    enable                         = false
    enable_block_public_policy     = true
    enable_block_public_acls       = true
    enable_ignore_public_acls      = true
    enable_restrict_public_buckets = true
  }
}

variable "ebs_encryption" {
  description = "A collection of EBS encryption settings to apply to the account"
  type = object({
    enable = optional(bool, false)
    # A flag indicating if EBS encryption should be enabled
    create_kms_key = optional(bool, true)
    # A flag indicating if an EBS encryption key should be created
    key_deletion_window_in_days = optional(number, 10)
    # The number of days to retain the key before deletion when the key is removed
    key_alias = optional(string, "lza/ebs/default")
    # The alias of the EBS encryption key when provisioning a new key
    key_arn = optional(string, null)
    # The ARN of an existing EBS encryption key to use for EBS encryption
  })
  default = null
}

variable "service_control_policies" {
  description = "Provides the ability to associate one of more service control policies with an account"
  type = map(object({
    name = string
    # The policy name to associate with the account
    policy = string
    # The policy document to associate with the account
  }))
  default = {}

  ## The name must be less than or equal to 12 characters
  validation {
    condition     = alltrue([for policy in values(var.service_control_policies) : length(policy.name) <= 12])
    error_message = "The name must be less than or equal to 12 characters"
  }

  ## The policy must be less than or equal to 6,144 characters
  validation {
    condition     = alltrue([for policy in values(var.service_control_policies) : length(policy.policy) <= 6144])
    error_message = "The policy must be less than or equal to 6,144 characters"
  }
}

variable "environment" {
  description = "The environment in which to provision resources"
  type        = string
}

variable "rbac" {
  description = "Provides the ability to associate one of more groups with a sso role in the account"
  type = map(object({
    users = optional(list(string), [])
    # A list of users to associate with the developer role
    groups = optional(list(string), [])
    # A list of groups to associate with the developer role
  }))
  default = {}
}

variable "notifications" {
  description = "Configuration for the notifications to the owner of the account"
  type = object({
    email = optional(object({
      addresses = optional(list(string), [])
      # A list of email addresses to send notifications to
      }), {
      addresses = []
    })

    slack = optional(object({
      webhook_url = optional(string, "")
      # The slack webhook_url to send notifications to
      }), {
      webhook_url = null
    })

    teams = optional(object({
      webhook_url = optional(string, "")
      # The teams webhook_url to send notifications to
      }), {
      webhook_url = null
    })

    services = optional(object({
      securityhub = object({
        enable = optional(bool, false)
        # A flag indicating if security hub notifications should be enabled
        eventbridge_rule_name = optional(string, "lza-securityhub-eventbridge")
        # The sns topic name which is created per region in the account,
        # this is used to receive notifications, and forward them on via email or other means.
        lambda_name = optional(string, "lza-securityhub-slack-forwarder")
        # The name of the lambda which will be used to forward the security hub events to slack
        lambda_role_name = optional(string, "lza-securityhub-slack-forwarder")
        # The name of the eventbridge rule which is used to forward the security hub events to the lambda
        severity = optional(list(string), ["CRITICAL"])
      })
      }), {
      securityhub = {
        enable = false
      }
    })
  })
  default = {
    email = {
      addresses = []
    }
    slack = {
      webhook_url = null
    }
    teams = {
      webhook_url = null
    }
    services = {
      securityhub = {
        enable                = false
        eventbridge_rule_name = "lza-securityhub-eventbridge"
        lambda_name           = "lza-securityhub-slack-forwarder"
        lambda_role_name      = "lza-securityhub-slack-forwarder"
        severity              = ["CRITICAL"]
      }
    }
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

variable "cost_center" {
  description = "The cost center of the product, and injected into all resource tags"
  type        = string
  default     = null
}

#variable "firewall_rules" {
#  description = "A collection of firewall rules to apply to networks"
#  type = object({
#    capacity = optional(number, 100)
#    # The name of the firewall rule
#    rules_source = optional(string, null)
#    # The content of the suracata rules
#    ip_sets = optional(map(list(string)), null)
#    # A map of IP sets to apply to the firewall rule, optional ie. WEBSERVERS = ["10.0.0.0/16"]
#    port_sets = optional(map(list(number)), null)
#    # A map of port sets to apply to the firewall rule, optional ie. WEBSERVERS = [80, 443]
#    domains_whitelist = optional(list(string), [])
#  })
#  default = null
#}

variable "iam_service_linked_roles" {
  description = "A collection of service linked roles to apply to the account"
  type        = list(string)
  default = [
    "autoscaling.amazonaws.com",
    "spot.amazonaws.com",
    "spotfleet.amazonaws.com",
  ]
}

variable "networks" {
  description = "A collection of networks to provision within the designated region"
  type = map(object({
    firewall = optional(object({
      capacity = number
      # The capacity of the firewall rule group
      rules_source = string
      # The content of the suracata rules
      ip_sets = map(list(string))
      # A map of IP sets to apply to the firewall rule ie. WEBSERVERS = ["100.0.0.0/16"]
      port_sets = map(list(number))
      # A map of port sets to apply to the firewall rule ie. WEBSERVERS = [80, 443]
      domains_whitelist = list(string)
    }), null)

    subnets = map(object({
      cidr = optional(string, null)
      # The CIDR block of the subnet
      netmask = optional(number, 0)
    }))

    tags = optional(map(string), {})
    # A collection of tags to apply to the network - these will be merged with the global tags

    transit_gateway = optional(object({
      gateway_id = optional(string, null)
      # The transit gateway ID to associate with the network
      gateway_route_table_id = optional(string, null)
      ## Optional id of the transit gateway route table to associate with the network
      gateway_routes = optional(map(string), null)
      # A map used to associate routes with subnets provisioned by the module - i.e ensure
      # all private subnets push
      }), {
      gateway_id             = null
      gateway_route_table_id = null
      gateway_routes         = null
    })
    ## Configuration for the transit gateway for this network

    vpc = object({
      availability_zones = optional(string, 2)
      # The availability zone in which to provision the network, defaults to 2
      cidr = optional(string, null)
      # The CIDR block of the VPC network if not using IPAM
      enable_private_endpoints = optional(list(string), [])
      # An optional list of private endpoints to associate with the network i.e ["s3", "dynamodb"]
      enable_shared_endpoints = optional(bool, true)
      # Indicates if the network should accept shared endpoints
      enable_transit_gateway = optional(bool, true)
      # A flag indicating if the network should be associated with the transit gateway
      enable_transit_gateway_appliance_mode = optional(bool, false)
      # A flag indicating if the transit gateway should be in appliance mode
      enable_default_route_table_association = optional(bool, true)
      # A flag indicating if the default route table should be associated with the network
      enable_default_route_table_propagation = optional(bool, true)
      # A flag indicating if the default route table should be propagated to the network
      ipam_pool_name = optional(string, null)
      # The name of the IPAM pool to use for the network
      nat_gateway_mode = optional(string, "none")
      # The NAT gateway mode to use for the network, defaults to none
      netmask = optional(number, null)
      # The netmask of the VPC network if using IPAM
      transit_gateway_routes = optional(map(string), null)
      # A list of routes to associate with the transit gateway, optional
    })
  }))
  default = {}

  ## The availability zone must be greater than 0
  validation {
    condition     = alltrue([for network in var.networks : network.vpc.availability_zones > 0])
    error_message = "The availability zone must be greater than 0"
  }

  ## We must have a private subnet defined in subnets
  validation {
    condition     = alltrue([for network in var.networks : contains(keys(network.subnets), "private")])
    error_message = "We must have a 'private' subnet defined in subnets"
  }

  ## The private subnet netmask must be between 0 and 32
  validation {
    condition     = alltrue([for network in var.networks : network.subnets["private"].netmask >= 0 && network.subnets["private"].netmask <= 32])
    error_message = "The private subnet netmask must be between 0 and 32"
  }

  ## The nat mode can only be none, single or all_azs
  validation {
    condition     = alltrue([for network in var.networks : contains(["none", "single_az", "all_azs"], network.vpc.nat_gateway_mode)])
    error_message = "The nat mode can only be none, single_az or all_azs"
  }
}

variable "tags" {
  description = "A collection of tags to apply to resources"
  type        = map(string)
}
