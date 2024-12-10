
locals {
  ## Enable private hosted zone association - any private hosted zones declared will be automatically
  ## associated with the central private dns solution
  central_dns_enable = var.central_dns.enable && var.central_dns.vpc_id != null && var.central_dns.vpc_id != ""

  ## This is the vpc which contains the central dns solution. Private hosted zones within the tenants
  ## account will be associated with this vpc, permitting dns resolution
  central_dns_vpc_id = var.central_dns.vpc_id

  ## A collection of private hosted zones which are automatically associated with the central dns solution
  private_hosted_zones = { for k, v in var.dns : k => v if v.private }

  ## A map of the private hosted zones created
  private_hosted_zones_by_id = { for k, v in var.dns : k => aws_route53_zone.zones[k].zone_id }
}

## Provision the hosted zones if required
resource "aws_route53_zone" "zones" {
  for_each = var.dns

  name          = each.key
  comment       = try(each.value.comment, "Managed by zone created by terraform")
  force_destroy = true
  tags          = local.tags

  dynamic "vpc" {
    for_each = try(each.value.private, false) ? [each.value.network] : []

    content {
      vpc_id     = module.networks[vpc.value].vpc_id
      vpc_region = var.region
    }
  }

  ## Ignore changes to the vpc association as there is a bug which try to
  ## remove the association from the central vpc
  lifecycle {
    ignore_changes = [
      vpc,
    ]
  }

  depends_on = [
    module.networks
  ]

  provider = aws.tenant
}

## Authorize the spoke vpc to associate with the central dns solution if required 
resource "aws_route53_vpc_association_authorization" "central_dns_authorization" {
  for_each = local.central_dns_enable ? { for key, zone in var.dns : key => zone if zone.private } : {}

  vpc_id     = local.central_dns_vpc_id
  vpc_region = var.region
  zone_id    = aws_route53_zone.zones[each.key].zone_id

  depends_on = [
    aws_route53_zone.zones,
    module.networks,
  ]

  provider = aws.tenant
}

## Associate the hosted zone with the central dns solution if required
resource "aws_route53_zone_association" "central_dns_association" {
  for_each = local.central_dns_enable ? { for key, zone in var.dns : key => zone if zone.private } : {}

  vpc_id     = local.central_dns_vpc_id
  vpc_region = var.region
  zone_id    = aws_route53_zone.zones[each.key].zone_id

  depends_on = [
    aws_route53_zone.zones,
    aws_route53_vpc_association_authorization.central_dns_authorization,
    module.networks,
  ]

  provider = aws.network
}
