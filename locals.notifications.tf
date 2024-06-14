##
## Note, the user facing locals can be found in the settings.<feature>.tf files, these are these
## are the locals which are used to internally and should not be changed by the tenant. 
##

locals {
  ## Indicates if slack is enabled and slack channel has been configured by the tenant. 
  enable_slack_notifications = (local.enable_slack && var.notifications.slack.channel != "")
  ## Indicates if email notifications are enabled 
  enable_email_notifications = length(var.notifications.email.addresses) > 0

  ## The configuration for email notifications.
  notifications_email = var.notifications.email

  ## If enabled, this is the webhook_url for the slack notifications 
  notifications_slack_webhook_url = local.enable_slack_notifications ? try(data.aws_secretsmanager_secret_version.slack[0].secret_string, "") : ""

  ## The configuration for slack notifications 
  notifications_slack = local.enable_slack_notifications ? {
    channel     = var.notifications.slack.channel
    lambda_name = "lza-slack-notifications"
    username    = ":aws: LZA Notifications"
    webhook_url = local.notifications_slack_webhook_url
  } : null
}
