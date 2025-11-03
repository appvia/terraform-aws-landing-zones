#
## Used to configure the default IAM account settings
#

locals {
  ## Indicates if we should enable the default IAM account settings
  enable_iam_password_policy = local.home_region && var.iam_password_policy.enable
  ## Collection users to be created within the account
  iam_users = local.home_region ? { for user in var.iam_users : user.name => user } : {}
  ## Collection of iam groups to be created within the account
  iam_groups = local.home_region ? { for group in var.iam_groups : group.name => group } : {}
  ## The account root assume
  iam_account_root = {
    sid     = "AllowAccountRoot"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals = [
      {
        type        = "AWS"
        identifiers = [format("arn:aws:iam::%s:root", local.account_id)]
      }
    ]
  }
}


## Configure any IAM customer managed policies within the account
resource "aws_iam_policy" "iam_policies" {
  for_each = local.home_region ? var.iam_policies : {}

  description = each.value.description
  name        = each.value.policy_name
  name_prefix = each.value.policy_name_prefix
  path        = each.value.path
  policy      = each.value.policy
  tags        = local.tags

  provider = aws.tenant
}

## Provision any IAM users required within the account
module "iam_users" {
  for_each = local.iam_users
  source   = "terraform-aws-modules/iam/aws//modules/iam-user"
  version  = "6.2.3"

  create_access_key    = false
  create_login_profile = false
  force_destroy        = true
  name                 = each.value.name
  path                 = each.value.path
  permissions_boundary = each.value.permissions_boundary_name != null ? format("arn:aws:iam::%s:policy/%s", local.account_id, each.value.permissions_boundary_name) : ""
  policies             = { for policy in try(each.value.permission_arns, []) : policy => policy }
  tags                 = local.tags

  providers = {
    aws = aws.tenant
  }
}

## Provision any IAM user policies required within the account
module "iam_groups" {
  for_each = local.iam_groups
  source   = "terraform-aws-modules/iam/aws//modules/iam-group"
  version  = "6.2.3"

  enable_mfa_enforcement             = each.value.enforce_mfa
  enable_self_management_permissions = true
  name                               = each.value.name
  path                               = each.value.path
  tags                               = local.tags
  users                              = each.value.users
  users_account_id                   = local.account_id

  depends_on = [
    module.iam_users,
    aws_iam_policy.iam_policies,
  ]

  providers = {
    aws = aws.tenant
  }
}

## Configure the service linked role for autoscaling
resource "aws_iam_service_linked_role" "service_linked_roles" {
  for_each = local.home_region ? toset(var.iam_service_linked_roles) : toset([])

  aws_service_name = each.key
  description      = "Enabling the service linked role for ${each.key}"
  tags             = local.tags

  provider = aws.tenant
}

## Configure the default IAM password policy for the account
resource "aws_iam_account_password_policy" "iam_account_password_policy" {
  count = local.enable_iam_password_policy ? 1 : 0

  allow_users_to_change_password = var.iam_password_policy.allow_users_to_change_password
  hard_expiry                    = var.iam_password_policy.hard_expiry
  max_password_age               = var.iam_password_policy.max_password_age
  minimum_password_length        = var.iam_password_policy.minimum_password_length
  password_reuse_prevention      = var.iam_password_policy.password_reuse_prevention
  require_lowercase_characters   = var.iam_password_policy.require_lowercase_characters
  require_numbers                = var.iam_password_policy.require_numbers
  require_symbols                = var.iam_password_policy.require_symbols
  require_uppercase_characters   = var.iam_password_policy.require_uppercase_characters

  provider = aws.tenant
}

## Configure the IAM Access Analyzer for the account
resource "aws_accessanalyzer_analyzer" "iam_access_analyzer" {
  count = var.iam_access_analyzer.enable ? 1 : 0

  analyzer_name = var.iam_access_analyzer.analyzer_name
  tags          = local.tags
  type          = var.iam_access_analyzer.analyzer_type

  provider = aws.tenant
}

## Configure any IAM roles required within the iam_account_password_policy
module "iam_roles" {
  for_each = local.home_region ? var.iam_roles : {}
  source   = "terraform-aws-modules/iam/aws//modules/iam-role"
  version  = "6.2.3"

  create_inline_policy           = length(each.value.policies) > 0 ? true : false
  description                    = each.value.description
  name                           = each.value.name
  path                           = each.value.path
  permissions_boundary           = each.value.permission_boundary_arn
  source_inline_policy_documents = each.value.policies
  tags                           = local.tags
  use_name_prefix                = each.value.name_prefix != null ? true : false

  policies = merge(
    try(toset(each.value.permission_arns), {}),
  )

  ## Build out the trust policy permissions
  trust_policy_permissions = merge(
    ## Allow the account
    { "root" : local.iam_account_root },
    {
      for service in each.value.assume_services : service => {
        sid     = "AllowServiceAssumeRole${replace(service, ".", "")}"
        effect  = "Allow"
        actions = ["sts:AssumeRole"]
        principals = {
          type        = "Service"
          identifiers = [service]
        }
      }
    }
  )

  providers = {
    aws = aws.tenant
  }

  depends_on = [
    aws_iam_policy.iam_policies,
    aws_iam_service_linked_role.service_linked_roles,
  ]
}

## Provision a security auditor role if required
module "security_auditor_iam_role" {
  count   = local.home_region && try(var.include_iam_roles.security_auditor.enable, false) ? 1 : 0
  source  = "terraform-aws-modules/iam/aws//modules/iam-role"
  version = "6.2.3"

  description = "Used by the security team to audit the accounts"
  name        = var.include_iam_roles.security_auditor.name

  policies = {
    "SecurityAudit" = "arn:aws:iam::aws:policy/SecurityAudit"
  }

  trust_policy_permissions = {
    "root" : local.iam_account_root
  }

  providers = {
    aws = aws.tenant
  }
}

## Provision a ssm automation role if required
module "ssm_automation_iam_role" {
  count   = local.home_region && try(var.include_iam_roles.ssm_instance.enable, false) ? 1 : 0
  source  = "terraform-aws-modules/iam/aws//modules/iam-role"
  version = "6.2.3"

  description = "Used by instances to access the ssm service"
  name        = var.include_iam_roles.ssm_instance.name

  trust_policy_permissions = {
    "ec2" : {
      sid     = "AllowServiceAssumeRoleEC2"
      effect  = "Allow"
      actions = ["sts:AssumeRole"]
      principals = [
        {
          type        = "Service"
          identifiers = ["ec2.amazonaws.com"]
        }
      ]
    }
  }

  policies = {
    "AmazonSSMDirectoryServiceAccess" = "arn:aws:iam::aws:policy/AmazonSSMDirectoryServiceAccess"
    "AmazonSSMManagedInstanceCore"    = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    "CloudWatchAgentServerPolicy"     = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  }

  providers = {
    aws = aws.tenant
  }
}
