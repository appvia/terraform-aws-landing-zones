#
## Used to configure the guardduty account settings
#

locals {
  ## Indicates if we should provision a default guardduty detector for the account
  enable_guardduty = var.guardduty != null
  ## A map of guardduty filters or an empty map
  guardduty_filters = try(var.guardduty.filters, {})
  ## A collection of detectors to enable or disable
  guardduty_detectors = {
    for detector in try(var.guardduty.detectors, []) : detector.name => detector
  }
}

## Lookup the detector id for the guardduty detector if provisioned already
data "aws_guardduty_detector" "guardduty" {
  count = local.enable_guardduty ? 1 : 0

  provider = aws.tenant
}

## Provision the guardduty detectors
resource "aws_guardduty_detector_feature" "detectors" {
  for_each = local.enable_guardduty ? local.guardduty_detectors : {}

  detector_id = data.aws_guardduty_detector.guardduty[0].id
  name        = each.key
  status      = each.value.enable ? "ENABLED" : "DISABLED"

  dynamic "additional_configuration" {
    for_each = {
      for key, value in each.value.additional_configuration : key => {
        name   = key
        enable = value
      }
    }

    content {
      name   = additional_configuration.value.name
      status = additional_configuration.value.enable ? "ENABLED" : "DISABLED"
    }
  }

  provider = aws.tenant
}

## Provision the guardduty filters
resource "aws_guardduty_filter" "filters" {
  for_each = local.enable_guardduty ? local.guardduty_filters : {}

  action      = each.value.action
  description = each.value.description
  detector_id = data.aws_guardduty_detector.guardduty[0].id
  name        = each.key
  rank        = each.value.rank
  tags        = merge(local.tags, { "Name" = each.key })

  finding_criteria {
    dynamic "criterion" {
      for_each = each.value.criterion
      content {
        field                 = criterion.value.field
        equals                = criterion.value.equals
        not_equals            = criterion.value.not_equals
        greater_than          = criterion.value.greater_than
        greater_than_or_equal = criterion.value.greater_than_or_equal
        less_than             = criterion.value.less_than
        less_than_or_equal    = criterion.value.less_than_or_equal
      }
    }
  }

  provider = aws.tenant
}
