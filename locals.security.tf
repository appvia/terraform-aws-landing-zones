locals {
  ## Indicates if the tenant should provision a default kms key within the region and account 
  enable_account_kms_key = local.enable_kms && var.kms.enable_default_kms

  ## The expiration window for the default kms key which will be used for the regional account key.
  kms_key_expiration_window_in_days = try(local.kms_key_expiration_windows_by_environment[var.environment], local.kms_default_key_deletion_window_in_days)

  ## Indicates if we have email addresses to send notifications on security hub events 
  enable_security_hub_email_notifications = local.enable_email_notifications

  ## Indicates if we have a slack channel to send notifications on security hub events 
  enable_security_hub_slack_notifications = local.enable_slack_notifications

  ## Indicates if we should provision notiications for security hub events 
  enable_security_hub_events = local.security_hub_notifications.enable && (local.enable_security_hub_email_notifications || local.enable_security_hub_slack_notifications)

  ## The name of the sns topic which if enabled will be used to absorb the security hub events 
  security_hub_sns_topic_name = local.enable_security_hub_events ? local.security_hub_notifications.sns_topic_name : "lza-securityhub-${local.region}"

  ## The name of the lambda which will be used to forward the security hub events to slack 
  security_hub_lambda_name = "lza-securityhub-slack-forwarder-${local.region}"

  ## The email addresses which should receive the security hub notifications 
  security_hub_email_addresses = local.notifications_email

  ## The slack channel which should receive the security hub notifications if nebaled 
  security_hub_slack = local.enable_slack_notifications ? {
    lambda_name = "lza-slack-securityhub-${local.resource_suffix}"
    webhook_url = local.notifications_slack_webhook_url
  } : null

  ## The name of the eventbridge rule which will be used to forward the security hub events to the lambda 
  security_hub_eventbridge_rule_name = "lza-securityhub-eventbridge-${local.region}"

  ## The name of the iam role the lambda will assume to forward the security hub events 
  security_hub_lambda_role_name = "lza-securityhub-lambda-${local.region}"

  ## The severity we should notify on for security hub events 
  security_hub_severity = local.security_hub_notifications.severity
}
