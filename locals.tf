##
## Note, the user facing locals can be found in the settings.<feature>.tf files, these are these
## are the locals which are used to internally and should not be changed by the tenant. 
##

locals {
  ## The current account id 
  account_id = data.aws_caller_identity.current.account_id
  ## The current region 
  region = var.region
  ## The tags associated with all resources within the account 
  tags = merge(var.tags, module.tagging.tags)

  ### Feature related locals 

  ## Indicates if cost anomaly detection is enabled 
  enable_anomaly_detection = local.enable_cost_anomaly_detection && length(var.anomaly_detection.monitors) > 0
  ## Indicate that slack is enabled and slack channel has been configured by the tenant. 
  enable_slack_notifications = (local.enable_slack && var.notifications.slack.channel != "")
  ## Indicates if the tenant should provision a default kms key within the region and account 
  enable_account_kms_key = local.enable_kms && var.kms.enable_default_kms
  ## Indicates if we should associate any private hosted zones with the central dns solution 
  enable_private_hosted_zone_association = local.enable_central_dns_association && local.dns_central_vpc_id != ""

  ### Notifications related locals 

  ## The configuration for email notifications 
  notifications_email = var.notifications.email
  ## The configuration for slack notifications 
  notifications_slack = local.enable_slack_notifications ? {
    channel     = var.notifications.slack.channel
    lambda_name = "lza-notifications-slack"
    username    = ":aws: LZA Notifications"
    webhook_url = data.aws_secretsmanager_secret_version.slack[0].secret_string
  } : null

  ### Cost and budgeting related locals 

  ## Here we construct the cost anomaly detection monitors from the configuration 
  costs_anomaly_monitors = [
    for monitor in var.anomaly_detection.monitors : {
      name              = monitor.name
      monitor_type      = "DIMENSIONAL"
      monitor_dimension = "SERVICE"
      specification     = monitor.specification
      notify = {
        frequency            = monitor.frequency
        threshold_expression = monitor.threshold_expression
      }
    }
  ]

  ## The default cost anomaly detection monitor which should be configured in all accounts 
  costs_anomaly_monitors_merged = concat(var.anomaly_detection.monitors,
  var.anomaly_detection.enable_default_monitors ? local.costs_default_anomaly_monitors : [])

  ### KMS and encryption related locals 

  ## The expiration window for the default kms key which will be used for the regional account key.
  kms_key_expiration_window_in_days = try(local.kms_key_expiration_windows_by_environment[var.environment], local.kms_default_key_deletion_window_in_days)

  ### IPAM and Connectivity related locals

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

  ### Identity and Access management related locals

  ## The instance ARN and identity store ID are required to create the permission set 
  sso_instance_arn = tolist(data.aws_ssoadmin_instances.current.arns)[0]
  ## The identity store ID is required to create the permission set 
  sso_identity_store_id = tolist(data.aws_ssoadmin_instances.current.identity_store_ids)[0]
  ## Create a map of all the sso groups, using the DisplayName as the key 
  ###sso_groups_by_name = { for group in data.aws_identitystore_groups.groups : group.display_name => group.id }
  ## Create a list of users from the rbac variable 
  ###sso_users_referenced = flatten([for role, data in var.rbac : data.users])

  ## The permitted permission sets that can be assigned to the account, and their corresponding permission set 
  ## in identity center; unless the permissionset is mentioned here, it cannot be assigned to the account 
  sso_permitted_permission_sets = {
    "devops_engineer"   = "DevOpsEngineer"
    "finops_engineer"   = "FinOpsEngineer"
    "network_engineer"  = "NetworkEngineer"
    "network_viewer"    = "NetworkViewer"
    "platform_engineer" = "PlatformEngineer"
    "security_auditor"  = "SecurityAuditor"
  }


  ### Output related locals 

  ## A map of the private hosted zones created 
  private_hosted_zones = { for k, v in var.dns : k => aws_route53_zone.zones[k].zone_id }
  ## A map the network and the corresponding vpc id 
  vpc_id_by_network_name = { for k, v in var.networks : k => module.networks[k].vpc_id }
}
