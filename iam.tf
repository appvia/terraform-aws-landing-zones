#
## Used to configure the default IAM account settings 
#

locals {
  ## Indicates if we should enable the default IAM account settings
  enable_iam_password_policy = local.home_region && var.iam_password_policy.enable
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
  tags          = var.tags
  type          = var.iam_access_analyzer.analyzer_type

  provider = aws.tenant
}

## Configure any IAM customer managed policies within the account 
resource "aws_iam_policy" "iam_policies" {
  for_each = local.home_region ? var.iam_policies : {}

  description = each.value.description
  name        = each.value.policy_name
  name_prefix = each.value.policy_name_prefix
  path        = each.value.path
  policy      = each.value.policy
  tags        = var.tags

  provider = aws.tenant
}

## Configure any IAM roles required within the iam_account_password_policy
module "iam_roles" {
  for_each = local.home_region ? var.iam_roles : {}
  source   = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version  = "5.46.0"

  create_role                       = true
  custom_role_policy_arns           = each.value.permission_arns
  force_detach_policies             = true
  inline_policy_statements          = each.value.policies
  number_of_custom_role_policy_arns = length(each.value.permission_arns)
  role_description                  = each.value.description
  role_name                         = each.value.name
  role_name_prefix                  = each.value.name_prefix
  role_path                         = each.value.path
  role_permissions_boundary_arn     = each.value.permission_boundary_arn
  role_requires_mfa                 = false
  tags                              = var.tags
  trusted_role_arns                 = concat(each.value.assume_roles, [for x in each.value.assume_accounts : format("arn:aws:iam::%s:root", x)])
  trusted_role_services             = each.value.assume_services

  providers = {
    aws = aws.tenant
  }

  depends_on = [
    aws_iam_policy.iam_policies
  ]
}
