locals {
  ## Indicates if the tenant should provision a default kms key within the region and account 
  enable_account_kms_key = local.enable_kms && var.kms.enable_default_kms

  ## The expiration window for the default kms key which will be used for the regional account key.
  kms_key_expiration_window_in_days = try(local.kms_key_expiration_windows_by_environment[var.environment], local.kms_default_key_deletion_window_in_days)
}
