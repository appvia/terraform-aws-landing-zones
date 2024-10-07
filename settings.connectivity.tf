
locals {
  ## Enabled private hosted zone association - any private hosted zones declared will be automatically 
  ## associated with the central private dns solution 
  enable_central_dns_association = false

  ## This is the vpc which contains the central dns solution. Private hosted zones within the tenants 
  ## account will be associated with this vpc, permitting dns resolution 
  dns_central_vpc_id = "vpc-0daa451f2adc1902b"

  #  ## A collection of ipset which are automatically injected into all firewall rules 
  #  firewall_default_ipsets = {
  #    "HOME_NET" = ["10.0.0.0/8"]
  #  }
  #
  #  ## A collection of portsets which are automatically injected into all firewall rules 
  #  firewall_default_portsets = {
  #    "HTTP_PORTS" = [80, 443]
  #    "RDP_PORTS"  = [3389]
  #    "SSH_PORTS"  = [22]
  #  }

  ## The transit gateway id for a specific region - for now we use a transit gateway per region; Note, 
  ## the lookup here is a placeholder, you may be using a different gateway per environment (e.g. dev, prod) 
  #
  ## Please update the lookup table to reflect your configuration 
  #
  transit_gateway_by_region = {
    "af-south-1"     = ""
    "ap-east-1"      = ""
    "ap-northeast-1" = ""
    "ap-northeast-1" = ""
    "ap-northeast-2" = ""
    "ap-northeast-3" = ""
    "ap-south-1"     = ""
    "ap-southeast-1" = ""
    "ap-southeast-2" = ""
    "ap-southeast-3" = ""
    "ap-southeast-5" = ""
    "ca-central-1"   = ""
    "cn-north-1"     = ""
    "cn-northwest-1" = ""
    "eu-central-1"   = ""
    "eu-north-1"     = ""
    "eu-south-1"     = ""
    "eu-west-1"      = ""
    "eu-west-2"      = "tgw-04ad8f026be8b7eb6"
    "eu-west-3"      = ""
    "me-south-1"     = ""
    "mt-east-1"      = ""
    "sa-east-1"      = ""
    "us-east-1"      = ""
    "us-east-2"      = ""
    "us-gov-east-1"  = ""
    "us-gov-west-1"  = ""
    "us-west-1"      = ""
    "us-west-2"      = ""
  }

  ## We use the lookup table above to derive the transit gateway id to use 
  transit_gateway_id = local.transit_gateway_by_region[local.region]

  ## When the transit gateway routes are not defined in the tenant configuration, we use the default 
  ## below - routing all private traffic to the hub and spoke network
  transit_gateway_default_routes = {
    "private" : "10.0.0.0/8",
  }
}
