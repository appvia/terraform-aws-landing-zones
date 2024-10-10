
locals {
  ## The name of the development environment 
  environment_dev = "Development"
  ## The name of the production environment
  environment_prod = "Production"
  ## The name of the staging environment 
  environment_staging = "Staging"
  ## The name of the testing environment 
  environment_test = "Testing"

  ## The git repository to store the terraform code 
  git_repo = "https://github.com/appvia/terraform-aws-landing-zones"

  ## The permitted permission sets that can be assigned to the account, and their corresponding permission set 
  ## in identity center; unless the permissionset is mentioned here, it cannot be assigned to the account 
  sso_permitted_permission_sets = {
    "administrator"     = "Administrator"
    "backup_admin"      = "BackupAdmin"
    "backup_operator"   = "BackupOperator"
    "billing_admin"     = "BillingAdmin"
    "billing_viewer"    = "BillingViewer"
    "devops_engineer"   = "DevOpsEngineer"
    "finops_engineer"   = "FinOpsEngineer"
    "network_engineer"  = "NetworkEngineer"
    "network_viewer"    = "NetworkViewer"
    "platform_engineer" = "PlatformEngineer"
    "security_auditor"  = "SecurityAuditor"
  }
}
