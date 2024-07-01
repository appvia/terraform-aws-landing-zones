
module "sso_assignment" {
  for_each = local.sso_assignments
  source   = "./modules/sso_assignment"

  account_id          = local.account_id
  groups              = each.value.groups
  instance_arn        = local.sso_instance_arn
  identity_store_id   = local.sso_identity_store_id
  permission_set_name = local.sso_permitted_permission_sets[each.value.key]
  users               = each.value.users

  providers = {
    aws          = aws
    aws.identity = aws.identity
  }
}
