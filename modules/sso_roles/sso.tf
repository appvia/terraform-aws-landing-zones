
## Assign the permissionset to the account 
module "sso_assignments_users" {
  for_each = { for k, v in var.rbac : k => v if contains(keys(local.sso_permitted_permission_sets), k) }

  source = "./modules/sso_assignment"

  identity_store_id = local.sso_identity_store_id
  instance_arn      = local.sso_instance_arn
  permissionset     = each.key
  target            = local.account_id
  users             = each.value.users

  providers = {
    aws = aws.identity
  }
}

## Assign the permissionset to the groups
module "sso_assignments_groups" {
  for_each = { for k, v in var.rbac : k => v if contains(keys(local.sso_permitted_permission_sets), k) }

  source = "./modules/sso_assignment"

  identity_store_id = local.sso_identity_store_id
  instance_arn      = local.sso_instance_arn
  permissionset     = each.key
  target            = local.account_id
  groups            = each.value.groups

  providers = {
    aws = aws.identity
  }
}
