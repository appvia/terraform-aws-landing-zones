
## Provision one or more budgets within the account region
module "budgets" {
  count   = length(var.budgets) > 0 ? 1 : 0
  source  = "appvia/budgets/aws//modules/budgets"
  version = "3.0.1"

  budgets = var.budgets
  tags    = local.tags

  notifications = {
    email = local.notifications_email
    sns   = local.notifications_sns
  }

  providers = {
    aws = aws.tenant
  }

  depends_on = [
    module.notifications,
  ]
}
