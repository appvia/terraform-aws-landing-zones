##
## Note, the user facing locals can be found in the settings.<feature>.tf files, these are these
## are the locals which are used to internally and should not be changed by the tenant. 
##

locals {
  ## The account id for the tenant we are provisioning resources for
  account_id = data.aws_caller_identity.tenant.account_id

  ## The ARN for the account root 
  account_root_arn = format("arn:aws:iam::%s:root", local.account_id)

  ## Autoscale service linked role name 
  autoscale_service_linked_role_name = format("arn:aws:iam::%s:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling", local.account_id)

  ## Cloud9 service linked role name 
  cloud9_service_linked_role_name = format("arn:aws:iam::%s:role/aws-service-role/cloud9.amazonaws.com/AWSServiceRoleForAWSCloud9", local.account_id)

  ## The current region 
  region = var.region

  ## The owner in lower case
  owner = lower(var.owner)

  ## The current environment in lower case 
  environment = lower(var.environment)

  ## The current product in lower case 
  product = lower(var.product)

  ## Is the resource suffix to be used for the resources 
  resource_suffix = lower("${var.environment}-${var.product}-${local.region}")

  ## The tags associated with all resources within the account 
  tags = merge(var.tags, module.tagging.tags)

  ## Indicates if slack is enabled and slack channel has been configured by the tenant. 
  enable_slack_notifications = local.enable_slack

  ## Indicates if email notifications are enabled 
  enable_email_notifications = length(var.notifications.email.addresses) > 0

  ## The configuration for email notifications.
  notifications_email = var.notifications.email

  ## If enabled, this is the webhook_url for the slack notifications 
  notifications_slack_webhook_url = var.notifications.slack.webhook_url != "" ? var.notifications.slack.webhook_url : try(data.aws_secretsmanager_secret_version.slack[0].secret_string, "")

  ## The configuration for slack notifications 
  notifications_slack = local.enable_slack_notifications ? {
    lambda_name        = "lza-slack-notifications"
    lambda_description = "Lambda function to send slack notifications"
    webhook_url        = local.notifications_slack_webhook_url
  } : null

  ## Create a map of the ipam pools, using the Name tag as the key 
  ipam_pools_by_name = { for pool in data.aws_vpc_ipam_pools.current.ipam_pools : pool.tags.Name => pool.id }
  #  ## This is a merge list of all the ip sets from the firewall rules 
  #  firewall_merged_ipsets = merge(local.firewall_default_ipsets, local.enable_firewall_rules ? var.firewall_rules.ip_sets : {})
  #  ## A merged list of all the port sets from the firewall rules 
  #  firewall_merged_portsets = merge(local.firewall_default_portsets, local.enable_firewall_rules ? var.firewall_rules.port_sets : {})
  #  ## Is the name of the suracata ruleset generated from the tenant configuration 
  #  firewall_suracata_rule_name = "lza-${var.product}-${var.environment}-suracata-rules"
  #  ## Is the name of the domains whitelist generated from the tenant configuration 
  #  firewall_domain_whitelist_rule_name = "lza-${var.product}-${var.environment}-domain-whitelist"

  ## A map the network and the corresponding vpc id 
  vpc_id_by_network_name = { for k, v in var.networks : k => module.networks[k].vpc_id }
}
