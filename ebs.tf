#
## Used to provision and ensure EBS encryption is enabled for all EBS volumes
#

locals {
  ## Indicates if we should provision a default kms key for the account (per region)
  ebs_create_kms_key = var.ebs_encryption.enabled && var.ebs_encryption.create_kms_key

  ## The ARN for the default EBS encryption key 
  ebs_encryption_key_arn = local.ebs_create_kms_key ? module.ebs_kms[0].key_arn : var.ebs_encryption.key_arn

  ## Indicates if EBS encryption is enabled 
  enable_ebs_encryption = var.ebs_encryption.enabled && local.ebs_encryption_key_arn != null
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
    sid       = "AllowAutoscalingToCreateGrant"
    effect    = "Allow"
    actions   = ["kms:CreateGrant"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = [local.autoscale_service_linked_role_name]
    }

    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
    }
  }

  statement {
    sid       = "AllowCloud9ToCreateGrant"
    effect    = "Allow"
    actions   = ["kms:CreateGrant"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = [local.cloud9_service_linked_role_name]
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
  count = local.ebs_create_kms_key ? 1 : 0

  source  = "terraform-aws-modules/kms/aws"
  version = "3.1.1"

  aliases                 = [var.ebs_encryption.key_alias]
  deletion_window_in_days = var.ebs_encryption.key_deletion_window_in_days
  description             = format("Used as the default key for EBS encryption in the %s region", local.region)
  enable_key_rotation     = true
  is_enabled              = true
  key_administrators      = [local.kms_key_administrator_role_name]
  key_owners              = coalesce(concat([local.account_root_arn], [local.kms_key_administrator_role_arn]))
  key_usage               = "ENCRYPT_DECRYPT"
  multi_region            = false
  source_policy_documents = [data.aws_iam_policy_document.ebs_encryption_key.json]
  tags                    = local.tags

  providers = {
    aws = aws.tenant
  }
}

## Ensure all EBS volumes are encrypted 
resource "aws_ebs_encryption_by_default" "default" {
  enabled = local.enable_ebs_encryption

  provider = aws.tenant
}

## Configure the key to be the default key for EBS encryption
resource "aws_ebs_default_kms_key" "default" {
  count = local.enable_ebs_encryption ? 1 : 0

  key_arn = local.ebs_encryption_key_arn

  provider = aws.tenant
}
