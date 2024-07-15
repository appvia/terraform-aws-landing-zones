
## Get the SSO Instance
data "aws_ssoadmin_instances" "current" {
  provider = aws.identity
}

## Get the current account id for the tenant account
data "aws_caller_identity" "tenant" {
  provider = aws.tenant
}

## Get the current account for the current account 
data "aws_caller_identity" "current" {
}

## Get all the ipam pools within the network account 
data "aws_vpc_ipam_pools" "current" {
  filter {
    name   = "address-family"
    values = ["ipv4"]
  }

  provider = aws.network
}

## Find the slack webhook url from the aws secrets manager if enabled 
data "aws_secretsmanager_secret" "slack" {
  count = local.enable_slack_notifications ? 1 : 0

  arn = local.notifications_slack_secret_arn

  provider = aws.tenant
}

## Find the latest version of the slack secret if required 
data "aws_secretsmanager_secret_version" "slack" {
  count = local.enable_slack_notifications ? 1 : 0

  secret_id = data.aws_secretsmanager_secret.slack[0].id

  provider = aws.tenant
}
