
## Assign the users to the account
resource "aws_ssoadmin_account_assignment" "users" {
  for_each = toset(var.users)

  instance_arn       = var.instance_arn
  permission_set_arn = data.aws_ssoadmin_permission_set.current.arn
  principal_id       = data.aws_identitystore_user.current[each.key].unique_id
  principal_type     = "USER"
  target_id          = var.account_id
  target_type        = "AWS_ACCOUNT"
}

## Assign the groups to the account
resource "aws_ssoadmin_account_assignment" "groups" {
  for_each = toset(var.groups)

  instance_arn       = var.instance_arn
  permission_set_arn = data.aws_ssoadmin_permission_set.current.arn
  principal_id       = data.aws_identitystore_group.current[each.key].group_id
  principal_type     = "GROUP"
  target_id          = var.account_id
  target_type        = "AWS_ACCOUNT"
}
