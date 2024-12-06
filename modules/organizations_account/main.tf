
## Provision the account in the organization
resource "aws_organizations_account" "account" {
  close_on_deletion          = var.close_on_deletion
  email                      = var.account_email
  iam_user_access_to_billing = var.enable_iam_billing_access ? "ALLOW" : "DENY"
  name                       = var.account_name
  parent_id                  = var.organizational_unit_id
  tags                       = var.tags
}
