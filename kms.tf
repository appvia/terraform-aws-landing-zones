
locals {
  ## Indicates if we should provision a default kms key for the account (per region)
  enable_kms_key = var.kms_key.enable

  ## Indicates we if should create a IAM role in the account used for KMS key administration,
  ## additional options allow external services and or accounts to assume this role. The role
  ## is scopes to adminsitrator actions only, and has no access to perform encryption actions.
  enable_kms_key_administrator = var.kms_administrator.enable

  ## Is a list of roles and or accounts whom should have a assume trust into the kms
  ## key administrator role.
  kms_key_administrator_roles = concat(
    var.kms_administrator.enable_account_root ? [format("arn:aws:iam::%s:root", local.account_id)] : [],
    var.kms_key.key_administrators,
    [for x in var.kms_administrator.assume_accounts : format("arn:aws:iam::%s:root", x)],
  )

  ## If we are using the kms key administrator role, this WOULD be the ARN for the provisioned
  kms_key_administrator_role_arn = format("arn:aws:iam::%s:role/%s", local.account_id, var.kms_administrator.name)

  ## A list of KMS key owners - i.e. those whom can perform all actions on the key. This will be
  ## a combination of the CI/CD role and any additional roles specified by the consumer.
  kms_key_owners = compact(
    concat(
      [local.tenant_role_arn],
      var.kms_key.key_owners,
    )
  )

  ## A list of ARN whom should be administrators for the KMS key - this will be a combination of the
  ## of the key administrator (if enabled) and any additional roles specified by the consumer.
  kms_key_administrators = compact(
    concat(
      [local.kms_key_administrator_role_arn],
      var.kms_key.key_administrators,
    )
  )

  ## The arns who wil be users for the kms key
  kms_key_users = length(var.kms_key.key_users) > 0 ? var.kms_key.key_users : [format("arn:aws:iam::%s:root", local.account_id)]
}

## Provision the key administrator role for the account if required
module "kms_key_administrator" {
  count   = local.enable_kms_key_administrator && local.home_region ? 1 : 0
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "5.60.0"

  allow_self_assume_role = true
  create_role            = true
  force_detach_policies  = true
  role_description       = var.kms_administrator.description
  role_name              = var.kms_administrator.name
  role_requires_mfa      = false
  tags                   = local.tags
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
  version = "4.0.0"

  aliases                 = [var.kms_key.key_alias]
  deletion_window_in_days = var.kms_key.key_deletion_window_in_days
  description             = "Default regional KMS key which can be used by the tenant"
  enable_key_rotation     = true
  is_enabled              = true
  key_administrators      = local.kms_key_administrators
  key_owners              = local.kms_key_owners
  key_users               = local.kms_key_users
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
