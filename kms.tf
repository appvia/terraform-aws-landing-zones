
locals {
  ## Indicates if we should provision a default kms key for the account (per region)
  enable_kms_key = var.kms_key.enable

  ## Should we create a default kms key administrator role for the account 
  enable_kms_key_administrator = var.kms_administrator.enable

  ## List of roles or accounts whom can assume the kms key administrator role 
  kms_key_administrator_roles = concat(
    var.kms_administrator.enable_account_root ? [format("arn:aws:iam::%s:root", local.account_id)] : [],
    var.kms_key.key_administrators,
    [for x in var.kms_administrator.assume_accounts : format("arn:aws:iam::%s:root", x)],
  )

  ## Is the name of the key administrator iam role within the account
  kms_key_administrator_role_name = var.kms_administrator.name

  ## The description added to the kms key administrator role 
  kms_key_administrator_role_description = var.kms_administrator.description != null ? var.kms_administrator.description : "Provides access to administer the KMS keys for the account"

  ## This will have the create_kms_key_administrator role arn if required, else it will be an empty list 
  kms_key_administrator_role_arn = local.enable_kms_key_administrator ? module.kms_key_administrator[0].iam_role_arn : null

  ## A list of roles who should be able to administer the kms key
  kms_key_owners = concat(var.kms_key.key_administrators, [local.kms_key_administrator_role_arn])
}

## Provision the key administrator role for the account if required 
module "kms_key_administrator" {
  count   = local.enable_kms_key_administrator && local.home_region ? 1 : 0
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "5.46.0"

  allow_self_assume_role = true
  create_role            = true
  force_detach_policies  = true
  role_description       = local.kms_key_administrator_role_description
  role_name              = local.kms_key_administrator_role_name
  role_requires_mfa      = false
  tags                   = var.tags
  trusted_role_arns      = local.kms_key_administrator_roles
  trusted_role_services  = var.kms_administrator.assume_services

  inline_policy_statements = [
    {
      sid       = "AllowKMSKeyActions"
      effect    = "Allow"
      actions   = ["kms:*"]
      resources = ["*"]
    }
  ]

  providers = {
    aws = aws.tenant
  }
}

## Provision a regional account kms key for use by the tenant
module "kms_key" {
  count   = local.enable_kms_key ? 1 : 0
  source  = "terraform-aws-modules/kms/aws"
  version = "3.1.1"

  aliases                 = [var.kms_key.key_alias]
  deletion_window_in_days = var.kms_key.key_deletion_window_in_days
  description             = "Default regional KMS key which can be used by the tenant"
  enable_key_rotation     = true
  is_enabled              = true
  key_administrators      = local.kms_key_owners
  key_owners              = local.kms_key_owners
  key_usage               = "ENCRYPT_DECRYPT"
  multi_region            = false
  tags                    = merge(local.tags, { "Name" = var.kms_key.key_alias })

  depends_on = [
    module.kms_key_administrator
  ]

  providers = {
    aws = aws.tenant
  }
}
