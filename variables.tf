
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

variable "iam_password_policy" {
  description = "The IAM password policy to apply to the account"
  type = object({
    enable_iam_password_policy = optional(bool, false)
    # A flag indicating if IAM password policy should be enabled
    allow_users_to_change_password = optional(bool, true)
    # A flag indicating if users can change their password 
    hard_expiry = optional(bool, false)
    # A flag indicating if a hard expiry should be enforced 
    max_password_age = optional(number, 90)
    # The maximum password age 
    minimum_password_length = optional(number, 8)
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
  default = {
    allow_users_to_change_password = true
    hard_expiry                    = false
    max_password_age               = 90
    minimum_password_length        = 8
    password_reuse_prevention      = 24
    require_lowercase_characters   = true
    require_numbers                = true
    require_symbols                = true
    require_uppercase_characters   = true
  }
}

variable "s3_block_public_access" {
  description = "A collection of S3 public block access settings to apply to the account"
  type = object({
    enabled = optional(bool, false)
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
    enabled                        = false
    enable_block_public_policy     = true
    enable_block_public_acls       = true
    enable_ignore_public_acls      = true
    enable_restrict_public_buckets = true
  }
}

variable "ebs_encryption" {
  description = "A collection of EBS encryption settings to apply to the account"
  type = object({
    enabled = optional(bool, false)
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
  default = {
    enabled                     = false
    create_kms_key              = true
    key_deletion_window_in_days = 10
    key_alias                   = "lza/ebs/default"
    key_arn                     = null
  }
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

  ## The environment must be one of the following 
  validation {
    condition     = var.environment == "Production" || var.environment == "Staging" || var.environment == "Development" || var.environment == "Sandbox"
    error_message = "The environment must be one of Production, Staging, Development or Sandbox"
  }
}

variable "kms" {
  description = "Configuration for the KMS key to use for encryption"
  type = object({
    enable_default_kms = optional(bool, true)
    # A flag indicating if the default KMS key should be enabled 
    key_alias = optional(string, "landing-zone/default")
  })
  default = {
    enable_default_kms = true
  }
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
  description = "A collection of notifications to send to users"
  type = object({
    email = optional(object({
      addresses = list(string)
      # A list of email addresses to send notifications to 
      }), {
      addresses = []
    })
    slack = optional(object({
      webhook_url = string
      # The slack webhook_url to send notifications to 
      }), {
      webhook_url = ""
    })
  })
  default = {
    email = {
      addresses = []
    }
    slack = {
      webhook_url = ""
    }
  }
}

variable "anomaly_detection" {
  description = "A collection of anomaly detection rules to apply to the environment"
  type = object({
    enable_default_monitors = optional(bool, true)
    # A flag indicating if the default monitors should be enabled 
    monitors = optional(list(object({
      name = string
      # The name of the anomaly detection rule 
      dimension = optional(string, "DIMENSIONAL")
      # The dimension of the anomaly detection rule, either SERVICE or DIMENSIONAL
      threshold_expression = optional(any, [
        {
          and = {
            dimension = {
              key           = "ANOMALY_TOTAL_IMPACT_PERCENTAGE"
              match_options = ["GREATER_THAN_OR_EQUAL"]
              values        = ["50"]
            }
          }
      }])
      # The expression to apply to the anomaly detection rule
      # see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ce_anomaly_monitor
      specification = optional(string, "")
      # The specification to anomaly detection monitor 
      # see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ce_anomaly_monitor
      frequency = optional(string, "DAILY")
      # The frequency of you want to receive notifications 
    })), [])
  })
  default = {}
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
    condition     = alltrue([for network in var.networks : contains(["none", "single", "all_azs"], network.vpc.nat_gateway_mode)])
    error_message = "The nat mode can only be none, single or all_azs"
  }
}

variable "region" {
  description = "The region we are provisioning the resources for the landing zone"
  type        = string

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.region))
    error_message = "The region must be in the format of a valid AWS region"
  }
}

variable "tags" {
  description = "A collection of tags to apply to resources"
  type        = map(string)

  # must not have a name tag 
  validation {
    condition     = !contains(keys(var.tags), "Name")
    error_message = "The tags must not have a name tag"
  }
}
