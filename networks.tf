
locals {
  ## A map of transit gateway asssociations which should be made
  transit_gateway_associations = {
    for k, v in var.networks : k => v.transit_gateway.gateway_route_table_id if v.vpc.enable_transit_gateway && v.transit_gateway.gateway_id != null && v.transit_gateway.gateway_route_table_id != null
  }
}

## Provision the networks within the account
module "networks" {
  for_each = var.networks
  source   = "appvia/network/aws"
  version  = "0.6.11"

  availability_zones                     = each.value.vpc.availability_zones
  enable_default_route_table_association = each.value.vpc.enable_default_route_table_association
  enable_default_route_table_propagation = each.value.vpc.enable_default_route_table_propagation
  enable_private_endpoints               = each.value.vpc.enable_private_endpoints
  enable_route53_resolver_rules          = each.value.vpc.enable_shared_endpoints
  enable_transit_gateway_appliance_mode  = each.value.vpc.enable_transit_gateway_appliance_mode
  ipam_pool_id                           = each.value.vpc.ipam_pool_name != null ? local.ipam_pools_by_name[each.value.vpc.ipam_pool_name] : null
  name                                   = each.key
  nat_gateway_mode                       = each.value.vpc.nat_gateway_mode
  private_subnet_netmask                 = coalesce(try(each.value.subnets["private"].netmask, null), 0)
  private_subnet_tags                    = each.value.private_subnet_tags
  public_subnet_netmask                  = coalesce(try(each.value.subnets["public"].netmask, null), 0)
  public_subnet_tags                     = each.value.public_subnet_tags
  subnets                                = { for k, v in each.value.subnets : k => v if !contains(["public", "private"], k) }
  tags                                   = merge(local.tags, each.value.tags)
  transit_gateway_id                     = each.value.vpc.enable_transit_gateway ? each.value.transit_gateway.gateway_id : null
  transit_gateway_routes                 = each.value.vpc.enable_transit_gateway ? each.value.transit_gateway.gateway_routes : {}
  vpc_cidr                               = each.value.vpc.cidr
  vpc_netmask                            = each.value.vpc.netmask

  providers = {
    aws = aws.tenant
  }
}

## For each of the networks, attach them to the appropriate transit gateway routing
## table if required
resource "aws_ec2_transit_gateway_route_table_association" "asssociation" {
  for_each = local.transit_gateway_associations

  transit_gateway_attachment_id  = module.networks[each.key].transit_gateway_attachment_id
  transit_gateway_route_table_id = each.value

  depends_on = [
    module.networks
  ]
}
