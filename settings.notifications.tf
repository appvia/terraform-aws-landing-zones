
locals {
  ## Indicates slack notifications are enabled, by default the notification 
  ## secret is kept in a central secret manager, with a policy to allow the 
  ## lambda to access it. 
  enable_slack = false

  ## The ARN for the secrets manager secret which contains the slack webhook 
  ## url. Note, this must be created beforehand. The secret must be 
  ## 
  ## - Using a CMK with a key policy that permits the organization to decrypt 
  ## - The secret must have a policy that allows the accounts access to GetSecretValue
  ##
  notifications_slack_secret_arn = "arn:aws:secretsmanager:eu-west-2:182532283617:secret:organizational/notification/slack-AJbIRb"

  ## The name of the sns topic which is create per region in the account, these are used 
  ## to receive notifications, and forward them on via email or other means. Used by the 
  ## cost and budgeting alarms. 
  notifications_sns_topic_name = lower("lza-notifications-${var.product}")
}