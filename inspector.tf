
locals {
  ## Indicates if we should enable inspector service
  configure_inspector = var.inspector != null
  ## Indicates if we should enable inspector service
  enable_inspector = local.configure_inspector && try(var.inspector.enable, false)
}

## Enable the inspection service an associate to the delegation account
resource "aws_inspector2_member_association" "inspection" {
  count      = local.configure_inspector && local.enable_inspector ? 1 : 0
  account_id = var.inspector.delegate_account_id
}


