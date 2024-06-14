##
## Note, the user facing locals can be found in the settings.<feature>.tf files, these are these
## are the locals which are used to internally and should not be changed by the tenant. 
##

locals {
  ## Indicates if we should associate any private hosted zones with the central dns solution 
  enable_private_hosted_zone_association = local.enable_central_dns_association && local.dns_central_vpc_id != ""

  ## A collection of private hosted zones which are automatically associated with the central dns solution 
  private_hosted_zones = { for k, v in var.dns : k => v if v.private }

  ## A map of the private hosted zones created 
  private_hosted_zones_by_id = { for k, v in var.dns : k => aws_route53_zone.zones[k].zone_id }
}
