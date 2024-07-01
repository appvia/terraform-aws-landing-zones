##
## Note, the user facing locals can be found in the settings.<feature>.tf files, these are these
## are the locals which are used to internally and should not be changed by the tenant. 
##

locals {
  ## The instance ARN and identity store ID are required to create the permission set 
  sso_instance_arn = tolist(data.aws_ssoadmin_instances.current.arns)[0]

  ## The identity store ID is required to create the permission set 
  sso_identity_store_id = tolist(data.aws_ssoadmin_instances.current.identity_store_ids)[0]

  ## Filter out the sso roles, by removing those not permitted by the tenant 
  sso_assignments = { for k, v in var.rbac : k => v if contains(keys(local.sso_permitted_permission_sets), k) }
}
