
locals {
  ## Indicates if we should provision a default kms key for the account (per region)
  enable_kms = false
  ## Is the alias of the default kms key to be created 
  kms_default_kms_key_alias = var.kms.key_alias != null ? var.kms.key_alias : "landing-zone/default"
  ## Is the name of the key administrator iam role within the account
  kms_key_administrator_role_name = "lza-kms-admin"
  ## The default deletion window for kms keys - this is used when the environment does not match 
  kms_default_key_deletion_window_in_days = 30
  ## The expiration windows based on the environment, if the var.environment is not found in the map, 
  ## the default deletion window is used above
  kms_key_expiration_windows_by_environment = {
    (local.environment_dev)     = 7
    (local.environment_prod)    = 30
    (local.environment_staging) = 7
    (local.environment_test)    = 7
  }
}
