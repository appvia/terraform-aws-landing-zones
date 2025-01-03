
locals {
  ## The name of the account alias to be created
  account_alias = local.home_region && var.account_alias != null ? var.account_alias : null
}

## Provision an account alias for the account
resource "aws_iam_account_alias" "this" {
  count = local.account_alias != null ? 1 : 0

  account_alias = local.account_alias
}
