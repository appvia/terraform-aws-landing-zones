
locals {
  ## Indicates if we should provision a default kms key for the account (per region)
  enable_kms_key = var.kms_key.enable

  ## Indicates we if should create a IAM role in the account used for KMS key administration,
  ## additional options allow external services and or accounts to assume this role. The role
  ## is scopes to administrators actions only, and has no access to perform encryption actions.
  enable_kms_key_administrator = var.kms_administrator.enable

  ## Is a list of roles and or accounts whom should have a assume trust into the kms
  ## key administrator role. Note this is deliberately distinct from
  ## var.kms_key.key_administrators, which controls who is named in the key policy - being
  ## a principal in the key policy does not imply permission to assume the administrator role.
  kms_key_administrator_roles = concat(
    var.kms_administrator.enable_account_root ? [format("arn:aws:iam::%s:root", local.account_id)] : [],
    var.kms_administrator.assume_roles,
    [for x in var.kms_administrator.assume_accounts : format("arn:aws:iam::%s:root", x)],
  )

  ## The administrative actions permitted to the kms key administrator role. Note this list
  ## deliberately excludes kms:PutKeyPolicy (and the kms:Put* wildcard which would cover it),
  ## so that a key administrator cannot rewrite the key policy to grant themselves the ability
  ## to perform cryptographic operations with the key.
  kms_key_administrator_actions = [
    "kms:Create*",
    "kms:Delete*",
    "kms:Describe*",
    "kms:Disable*",
    "kms:Enable*",
    "kms:Get*",
    "kms:List*",
    "kms:Revoke*",
    "kms:ScheduleKeyDeletion",
    "kms:TagResource",
    "kms:UntagResource",
    "kms:UpdateAlias",
    "kms:UpdateKeyDescription",
    "kms:UpdatePrimaryRegion",
  ]

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
      local.enable_kms_key_administrator ? [local.kms_key_administrator_role_arn] : [],
      var.kms_key.key_administrators,
    )
  )

  ## The arns who wil be users for the kms key
  kms_key_users = try(var.kms_key.key_users, null)

  ## The organization guardrail statement. This is always appended to the key policy, even when
  ## the tenant supplies their own key_statements, so the guardrail cannot be removed by input.
  kms_key_organization_statement = {
    sid    = "DenyAccessOutsideOrg"
    effect = "Deny"
    principals = [
      {
        type        = "AWS"
        identifiers = ["*"]
      }
    ]
    actions   = ["kms:*"]
    resources = ["*"]
    condition = [
      {
        test     = "StringNotEquals"
        variable = "aws:PrincipalOrgID"
        values   = [local.organization_id]
      },
      {
        test     = "Bool"
        variable = "aws:PrincipalIsAWSService"
        values   = ["false"]
      }
    ]
  }
}

## Provision the key administrator role for the account if required
module "kms_key_administrator" {
  count   = local.enable_kms_key_administrator && local.home_region ? 1 : 0
  source  = "terraform-aws-modules/iam/aws//modules/iam-role"
  version = "6.6.1"

  description          = var.kms_administrator.description
  create_inline_policy = true
  name                 = var.kms_administrator.name
  tags                 = merge(local.tags, { "Name" = var.kms_administrator.name })
  use_name_prefix      = false

  trust_policy_permissions = merge(
    ## Allow the KMS administrators
    {
      "kms_admin" = {
        sid    = "AllowKMSAdminAssumeRole"
        effect = "Allow"
        actions = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        principals = [
          {
            type        = "AWS"
            identifiers = local.kms_key_administrator_roles
          }
        ]
      }
    },
    {
      for service in var.kms_administrator.assume_services : service => {
        sid    = "AllowServiceAssumeRole${replace(service, ".", "")}"
        effect = "Allow"
        actions = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        principals = [
          {
            type        = "Service"
            identifiers = [service]
          }
        ]
      }
    }
  )

  # Permissions for the key administrator role
  inline_policy_permissions = {
    "kms" : {
      sid     = "AllowKMSKeyActions"
      effect  = "Allow"
      actions = local.kms_key_administrator_actions
      resources = [
        "arn:aws:kms:${local.region}:${local.account_id}:key/*"
      ]
    }
  }
}

## Provision a regional account kms key for use by the tenant
module "kms_key" {
  count   = local.enable_kms_key ? 1 : 0
  source  = "terraform-aws-modules/kms/aws"
  version = "4.2.0"

  aliases                 = [var.kms_key.key_alias]
  deletion_window_in_days = var.kms_key.key_deletion_window_in_days
  description             = format("Default regional KMS key which can be used by the tenant in the %s region", local.region)
  enable_key_rotation     = true
  is_enabled              = true
  key_administrators      = local.kms_key_administrators
  key_owners              = local.kms_key_owners
  key_users               = local.kms_key_users
  key_usage               = "ENCRYPT_DECRYPT"
  multi_region            = false
  tags                    = merge(local.tags, { "Name" = var.kms_key.key_alias })

  ## The organization guardrail is appended unconditionally - a tenant supplying key_statements
  ## replaces the default statements, but can never remove the deny outside the organization.
  key_statements = concat(
    var.kms_key.key_statements != null ? var.kms_key.key_statements : compact([
      local.enable_kms_key_administrator ? {
        sid    = "AllowKeyAdministration"
        effect = "Allow"
        principals = [
          {
            type        = "AWS"
            identifiers = [local.kms_key_administrator_role_arn]
          }
        ]
        actions   = local.kms_key_administrator_actions
        resources = ["*"]
      } : null,
      {
        sid    = "AllowUseViaAWSServices"
        effect = "Allow"
        actions = [
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:Encrypt",
          "kms:GenerateDataKey*",
          "kms:ReEncrypt*",
        ]
        resources = ["*"]
        condition = [
          {
            test     = "StringEquals"
            variable = "kms:CallerAccount"
            values   = [local.account_id]
          },
          {
            test     = "StringLike"
            variable = "kms:ViaService"
            values   = ["*.${local.region}.amazonaws.com"]
          }
        ]
      },
      {
        sid    = "AllowGrantsForAWSResources"
        effect = "Allow"
        actions = [
          "kms:CreateGrant",
          "kms:ListGrants",
          "kms:RevokeGrant"
        ]
        resources = ["*"]
        condition = [
          {
            test     = "StringEquals"
            variable = "kms:CallerAccount"
            values   = [local.account_id]
          },
          {
            test     = "Bool"
            variable = "kms:GrantIsForAWSResource"
            values   = ["true"]
          }
        ]
      },
    ]),
    [local.kms_key_organization_statement],
  )

  depends_on = [
    module.kms_key_administrator,
    module.iam_roles,
  ]
}
