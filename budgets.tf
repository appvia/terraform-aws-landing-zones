
## Provision one or more budgets within the account region
module "budgets" {
  count   = length(var.budgets) > 0 ? 1 : 0
  source  = "appvia/budgets/aws//modules/budgets"
  version = "0.1.11"

  budgets          = var.budgets
  create_sns_topic = false
  sns_topic_name   = local.notifications_sns_topic_name
  tags             = local.tags

  notifications = {
    email = local.notifications_email
    slack = local.notifications_slack
    teams = local.notifications_teams
  }

  providers = {
    aws = aws.tenant
  }

  depends_on = [
    module.notifications,
  ]
}
