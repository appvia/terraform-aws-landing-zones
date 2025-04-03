
locals {
  ## The configuration for slack notifications
  notifications_slack = var.notifications.slack.webhook_url != null ? {
    lambda_name        = "lza-slack-notifications-${local.region}"
    lambda_description = "Lambda function to forward notifications to slack to an SNS topic"
    webhook_url        = var.notifications.slack.webhook_url
  } : null

  ## The configuration for ms team notifications
  notifications_teams = var.notifications.teams.webhook_url != null ? {
    lambda_name        = "lza-teams-notifications-${local.region}"
    lambda_description = "Lambda function to forward notifications to teams to an SNS topic"
    webhook_url        = var.notifications.teams.webhook_url
  } : null

  ## The configuration for email notifications
  notifications_email = var.notifications.email.addresses != null ? {
    addresses = var.notifications.email.addresses
  } : null

  ## The notifications sns topic name
  notifications_sns = {
    topic_arn = module.notifications.sns_topic_arn
  }

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
  source  = "appvia/notify/aws"
  version = "0.0.5"

  allowed_aws_services = [
    "budgets.amazonaws.com",
    "events.amazonaws.com",
    "lambda.amazonaws.com",
  ]
  create_sns_topic = true
  email            = local.notifications_email
  slack            = local.notifications_slack
  sns_topic_name   = local.notifications_sns_topic_name
  tags             = local.tags
  teams            = local.notifications_teams

  providers = {
    aws = aws.tenant
  }
}
