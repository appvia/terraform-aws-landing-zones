#
## Used to provision and ensure EBS encryption is enabled for all EBS volumes
#

locals {
  ## Indicates if EBS encryption is configured
  ebs_managed = var.ebs_encryption != null

  ## Indicates if we should provision a default kms key for the account (per region)
  ebs_create_kms_key = local.ebs_managed && try(var.ebs_encryption.enable, false) && try(var.ebs_encryption.create_kms_key, false) != false

  ## The ARN for the default EBS encryption key
  ebs_encryption_key_arn = local.ebs_managed && local.ebs_create_kms_key ? module.ebs_kms[0].key_arn : try(var.ebs_encryption.key_arn, null)

  ## Indicates if EBS encryption is enabled
  enable_ebs_encryption = local.ebs_managed ? try(var.ebs_encryption.enable, null) : null
}

## Additional IAM policy document for EBS encryption kms key
data "aws_iam_policy_document" "ebs_encryption_key" {
  statement {
    sid       = "AllowEC2"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["ec2.${local.region}.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = [local.account_id]
    }
  }

  statement {
    sid    = "AllowAutoscaling"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:GenerateDataKey*",
      "kms:ReEncrypt*"
    ]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = [local.autoscale_service_linked_role_arn]
    }
  }

  statement {
    sid       = "AllowAutoscalingToCreateGrant"
    effect    = "Allow"
    actions   = ["kms:CreateGrant"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = [local.autoscale_service_linked_role_arn]
    }

    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
    }
  }
}

## Provision am EBS encrytions key
module "ebs_kms" {
  count   = local.ebs_create_kms_key ? 1 : 0
  source  = "terraform-aws-modules/kms/aws"
  version = "4.2.0"

  aliases                 = [var.ebs_encryption.key_alias]
  deletion_window_in_days = var.ebs_encryption.key_deletion_window_in_days
  description             = format("Used as the default key for EBS encryption in the %s region", local.region)
  enable_key_rotation     = true
  is_enabled              = true
  key_administrators      = local.kms_key_administrators
  key_owners              = local.kms_key_owners
  key_usage               = "ENCRYPT_DECRYPT"
  key_users               = [local.account_root_arn]
  multi_region            = false
  source_policy_documents = [data.aws_iam_policy_document.ebs_encryption_key.json]
  tags                    = merge(local.tags, { "Name" = var.ebs_encryption.key_alias })

  providers = {
    aws = aws.tenant
  }

  depends_on = [
    aws_iam_service_linked_role.service_linked_roles,
    module.kms_key_administrator
  ]
}

## Ensure all EBS volumes are encrypted
resource "aws_ebs_encryption_by_default" "default" {
  count = local.enable_ebs_encryption != null ? 1 : 0

  enabled = local.enable_ebs_encryption

  provider = aws.tenant
}

## Configure the key to be the default key for EBS encryption
resource "aws_ebs_default_kms_key" "default" {
  count = local.enable_ebs_encryption != null ? 1 : 0

  key_arn = local.ebs_encryption_key_arn

  provider = aws.tenant
}
