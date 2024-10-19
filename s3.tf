#
## Used to configure the s3 account settings 
#

locals {
  ## Indicates if we should enable the s3 account settings
  enable_s3_block_public_access = var.enable_s3_block_public_access
}

## Configure public access block settings for the account 
resource "aws_s3_account_public_access_block" "s3_account_public_access_block" {
  count = local.enable_s3_block_public_access ? 1 : 0

  account_id              = local.account_id
  block_public_acls       = var.enable_s3_block_public_acls
  block_public_policy     = var.enable_s3_block_public_policy
  ignore_public_acls      = var.enable_s3_ignore_public_acls
  restrict_public_buckets = var.enable_s3_restrict_public_buckets
}
