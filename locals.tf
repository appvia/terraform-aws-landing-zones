##
## Note, the user facing locals can be found in the settings.<feature>.tf files, these are these
## are the locals which are used to internally and should not be changed by the tenant.
##

locals {
  ## The account id for the tenant we are provisioning resources for
  account_id = data.aws_caller_identity.current.account_id

  ## The ARN for the account root
  account_root_arn = format("arn:aws:iam::%s:root", local.account_id)

  ## The account role arn - this is the ARN in the TENANT we are using
  tenant_role_arn = data.aws_caller_identity.current.arn

  ## Autoscale service linked role name
  autoscale_service_linked_role_arn = format("arn:aws:iam::%s:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling", local.account_id)

  ## The current region
  region = data.aws_region.current.region

  ## is_home_region is true if the current region is the home region for the tenant
  home_region = local.region == var.home_region

  ## The owner in lower case
  owner = lower(var.owner)

  ## The current environment in lower case
  environment = lower(var.environment)

  ## The current product in lower case
  product = lower(var.product)

  ## The tags associated with all resources within the account
  tags = merge(var.tags, module.tagging.tags, var.landing_zone_tags)

  ## The ipam pools found in the account
  ipam_pools = data.aws_vpc_ipam_pools.current.ipam_pools

  ## Create a map of the ipam pools, using the Name tag as the key
  ipam_pools_by_name = {
    for pool in try(local.ipam_pools, {}) : pool.description => pool.id if try(pool.description, null) != null
  }

  ## A map the network and the corresponding vpc id
  vpc_id_by_network_name = { for k, v in var.networks : k => module.networks[k].vpc_id }
}
