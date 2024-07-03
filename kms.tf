
## Provision a regional account kms key for use by the tenant
module "kms" {
  count   = local.enable_account_kms_key ? 1 : 0
  source  = "terraform-aws-modules/kms/aws"
  version = "3.1.0"

  aliases                 = [local.kms_default_kms_key_alias]
  deletion_window_in_days = local.kms_key_expiration_window_in_days
  description             = "Default regional KMS key which can be used by the tenant, environment: ${local.environment}, product: ${local.product}"
  enable_key_rotation     = true
  is_enabled              = true
  key_administrators      = ["arn:aws:iam::${local.account_id}:role/${local.kms_key_administrator_role_name}"]
  key_owners              = ["arn:aws:iam::${local.account_id}:role/${local.kms_key_administrator_role_name}"]
  key_usage               = "ENCRYPT_DECRYPT"
  multi_region            = false
  tags                    = merge(local.tags, { "Name" = local.kms_default_kms_key_alias })

  providers = {
    aws = aws.tenant
  }
}
