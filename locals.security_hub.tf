##
## Note, the user facing locals can be found in the settings.<feature>.tf files, these are these
## are the locals which are used to internally and should not be changed by the tenant. 
##

locals {
  ## Indicates if we have email addresses to send notifications on security hub events 
  enable_security_hub_email_notifications = local.enable_email_notifications

  ## Indicates if we have a slack channel to send notifications on security hub events 
  enable_security_hub_slack_notifications = local.enable_slack_notifications

  ## Indicates if we should provision notiications for security hub events 
  enable_security_hub_events = local.security_hub_notifications.enable && (local.enable_security_hub_email_notifications || local.enable_security_hub_slack_notifications)

  ## The name of the sns topic which if enabled will be used to absorb the security hub events 
  security_hub_sns_topic_name = local.enable_security_hub_events ? local.security_hub_notifications.sns_topic_name : "lza-securityhub-notifications"

  ## The name of the lambda which will be used to forward the security hub events to slack 
  security_hub_lambda_name = "lza-securityhub-slack-forwarder"

  ## The email addresses which should receive the security hub notifications 
  security_hub_email_addresses = local.notifications_email

  ## The slack channel which should receive the security hub notifications if nebaled 
  security_hub_slack = local.enable_slack_notifications ? {
    channel     = var.notifications.slack.channel
    lambda_name = "lza-slack-securityhub"
    username    = ":aws: Security Event"
    webhook_url = local.notifications_slack_webhook_url
  } : null

  ## The name of the eventbridge rule which will be used to forward the security hub events to the lambda 
  security_hub_eventbridge_rule_name = "lza-securityhub-eventbridge-rule"

  ## The name of the iam role the lambda will assume to forward the security hub events 
  security_hub_lambda_role_name = "lza-securityhub-lambda-role"

  ## The severity we should notify on for security hub events 
  security_hub_severity = local.security_hub_notifications.severity
}
