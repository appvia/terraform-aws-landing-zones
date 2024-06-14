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
