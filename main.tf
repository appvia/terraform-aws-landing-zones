
## Generate the tagging required for the resources
module "tagging" {
  source  = "appvia/tagging/null"
  version = "0.0.3"

  cost_center = var.cost_center
  environment = var.environment
  git_repo    = local.git_repo
  owner       = var.owner
  product     = var.product
}

## Provision the notifications sns topics and destinations
module "notifications" {
  source  = "appvia/notifications/aws"
  version = "0.1.6"

  allowed_aws_services = ["budgets.amazonaws.com", "lambda.amazonaws.com"]
  create_sns_topic     = true
  email                = local.notifications_email
  slack                = local.notifications_slack
  sns_topic_name       = local.notifications_sns_topic_name
  tags                 = local.tags
}
