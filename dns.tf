
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
}

## Authorize the spoke vpc to associate with the central dns solution if required 
resource "aws_route53_vpc_association_authorization" "central_dns_authorization" {
  for_each = local.enable_private_hosted_zone_association ? { for key, zone in var.dns : key => zone if zone.private } : {}

  vpc_id     = local.dns_central_vpc_id
  vpc_region = var.region
  zone_id    = aws_route53_zone.zones[each.key].zone_id

  depends_on = [
    aws_route53_zone.zones,
    module.networks,
  ]
}

## Associate the hosted zone with the central dns solution if required 
resource "aws_route53_zone_association" "central_dns_association" {
  for_each = local.enable_private_hosted_zone_association ? { for key, zone in var.dns : key => zone if zone.private } : {}

  vpc_id     = local.dns_central_vpc_id
  vpc_region = var.region
  zone_id    = aws_route53_zone.zones[each.key].zone_id

  depends_on = [
    aws_route53_zone.zones,
    aws_route53_vpc_association_authorization.central_dns_authorization,
    module.networks,
  ]

  provider = aws.network
}
