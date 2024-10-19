#
## Used to configure the default IAM account settings 
#

locals {
  ## Indicates if we should enable the default IAM account settings
  enable_iam_password_policy = var.iam_password_policy.enable_iam_password_policy
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
}

## Configure the IAM Access Analyzer for the account 
resource "aws_accessanalyzer_analyzer" "iam_access_analyzer" {
  count = var.iam_access_analyzer.enabled ? 1 : 0

  analyzer_name = var.iam_access_analyzer.analyzer_name
  tags          = var.tags
  type          = var.iam_access_analyzer.analyzer_type
}
