
locals {
  ## The configuration for slack notifications 
  notifications_slack = var.notifications.slack.webhook_url != null ? {
    lambda_name        = "lza-slack-notifications"
    lambda_description = "Lambda function to forward notifications to slack to an SNS topic"
    webhook_url        = var.notifications.slack.webhook_url
  } : null

  ## The configuration for email notifications 
  notifications_email = var.notifications.email.addresses != null ? {
    addresses = var.notifications.email.addresses
  } : null

  ## Name of the sns topic for notifications for budget and cost alerts 
  notifications_sns_topic_name = "lza-general-notifications"
}

## Generate the tagging required for the resources
module "tagging" {
  source  = "appvia/tagging/null"
  version = "0.0.5"

  cost_center = var.cost_center
  environment = var.environment
  git_repo    = var.git_repository
  owner       = var.owner
  product     = var.product
}

## Provision the notifications sns topics and destinations
#trivy:ignore:AVD-AWS-0057 - (https://avd.aquasec.com/misconfig/aws/iam/avd-aws-0057)
#trivy:ignore:AVD-DS-0002
#trivy:ignore:AVD-DS-0013
#trivy:ignore:AVD-DS-0015
#trivy:ignore:AVD-DS-0026
module "notifications" {
  source  = "appvia/notifications/aws"
  version = "1.0.6"

  allowed_aws_services = ["budgets.amazonaws.com", "lambda.amazonaws.com", "events.amazonaws.com"]
  create_sns_topic     = true
  email                = local.notifications_email
  enable_slack         = local.notifications_slack != null
  slack                = local.notifications_slack
  sns_topic_name       = local.notifications_sns_topic_name
  tags                 = local.tags

  providers = {
    aws = aws.tenant
  }
}
