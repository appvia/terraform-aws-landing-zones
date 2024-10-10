
## Generate the tagging required for the resources
module "tagging" {
  source  = "appvia/tagging/null"
  version = "0.0.4"

  cost_center = var.cost_center
  environment = var.environment
  git_repo    = local.git_repo
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
  version = "1.0.4"

  allowed_aws_services = ["budgets.amazonaws.com", "lambda.amazonaws.com"]
  create_sns_topic     = true
  email                = local.notifications_email
  slack                = local.notifications_slack
  sns_topic_name       = local.notifications_sns_topic_name
  tags                 = local.tags

  providers = {
    aws = aws.tenant
  }
}
