
## Provision one or more budgets within the account region
module "budgets" {
  count   = length(var.budgets) > 0 ? 1 : 0
  source  = "appvia/budgets/aws//modules/budgets"
  version = "0.1.12"

  budgets          = var.budgets
  create_sns_topic = false
  sns_topic_name   = local.notifications_sns_topic_name
  tags             = local.tags

  notifications = {
    email = local.notifications_email
    slack = var.notifications.slack.webhook_url != null ? {
      lambda_name        = "lza-slack-notifications-budgets-${local.region}"
      lambda_description = "Lambda function to send notifications via Slack"
      webhook_url        = var.notifications.slack.webhook_url
    } : null
    teams = var.notifications.teams.webhook_url != null ? {
      lambda_name        = "lza-teams-notifications-budgets-${local.region}"
      lambda_description = "Lambda function to send notifications via Microsoft Teams"
      webhook_url        = var.notifications.teams.webhook_url
    } : null
  }

  providers = {
    aws = aws.tenant
  }

  depends_on = [
    module.notifications,
  ]
}
