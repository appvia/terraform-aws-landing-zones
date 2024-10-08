
## Provision the networks within the account
module "networks" {
  for_each = var.networks
  source   = "appvia/network/aws"
  version  = "0.3.2"

  additional_subnets                     = { for k, v in each.value.subnets : k => v if !contains(["public", "private"], k) }
  availability_zones                     = each.value.vpc.availability_zones
  enable_default_route_table_association = each.value.vpc.enable_default_route_table_association
  enable_default_route_table_propagation = each.value.vpc.enable_default_route_table_propagation
  enable_ipam                            = each.value.vpc.ipam_pool_name != null ? true : false
  enable_private_endpoints               = each.value.vpc.enable_private_endpoints
  enable_route53_resolver_rules          = each.value.vpc.enable_shared_endpoints
  enable_transit_gateway                 = each.value.vpc.enable_transit_gateway
  enable_transit_gateway_appliance_mode  = each.value.vpc.enable_transit_gateway_appliance_mode
  ipam_pool_id                           = each.value.vpc.ipam_pool_name != null ? local.ipam_pools_by_name[each.value.vpc.ipam_pool_name] : null
  name                                   = each.key
  nat_gateway_mode                       = each.value.vpc.nat_gateway_mode
  private_subnet_netmask                 = coalesce(try(each.value.subnets["private"].netmask, null), 0)
  public_subnet_netmask                  = coalesce(try(each.value.subnets["public"].netmask, null), 0)
  tags                                   = merge(local.tags, each.value.tags)
  transit_gateway_id                     = local.transit_gateway_id
  transit_gateway_routes                 = coalesce(each.value.vpc.transit_gateway_routes, local.transit_gateway_default_routes)
  vpc_cidr                               = each.value.vpc.cidr
  vpc_netmask                            = each.value.vpc.netmask

  providers = {
    aws = aws.tenant
  }
}
