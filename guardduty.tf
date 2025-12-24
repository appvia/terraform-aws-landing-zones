#
## Used to configure the guardduty account settings
#

locals {
  ## Indicates if we should provision a default guardduty detector for the account
  enable_guardduty = var.guardduty != null
  ## Indicates if we should create a new guardduty detector
  create_guardduty = var.guardduty != null ? try(var.guardduty.create, false) : false
  ## A map of guardduty filters or an empty map
  guardduty_filters = try(var.guardduty.filters, {})
  ## A collection of detectors to enable or disable
  guardduty_detectors = {
    for detector in try(var.guardduty.detectors, []) : detector.name => detector
  }
  ## The guardduty detector id 
  guardduty_detector_id = local.create_guardduty ? try(aws_guardduty_detector.guardduty[0].id, null) : try(data.aws_guardduty_detector.guardduty[0].id, null)
}

## Lookup the detector id for the guardduty detector if provisioned already
data "aws_guardduty_detector" "guardduty" {
  count = local.enable_guardduty && !local.create_guardduty ? 1 : 0

  provider = aws.tenant
}

# Create a new guardduty detector if required
resource "aws_guardduty_detector" "guardduty" {
  count = local.create_guardduty ? 1 : 0

  enable = true
  tags   = merge(local.tags, { "Name" = "guardduty-detector" })

  provider = aws.tenant
}

## Provision the guardduty detectors
resource "aws_guardduty_detector_feature" "detectors" {
  for_each = local.enable_guardduty ? local.guardduty_detectors : {}

  detector_id = local.guardduty_detector_id
  name        = each.key
  status      = each.value.enable ? "ENABLED" : "DISABLED"

  dynamic "additional_configuration" {
    for_each = try(each.value.additional_configuration, [])

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
  detector_id = local.guardduty_detector_id
  name        = each.key
  rank        = each.value.rank
  tags        = merge(local.tags, { "Name" = each.key })

  finding_criteria {
    dynamic "criterion" {
      for_each = each.value.criterion
      content {
        field                 = criterion.value.field
        equals                = criterion.value.equals != null ? [criterion.value.equals] : null
        not_equals            = criterion.value.not_equals != null ? [criterion.value.not_equals] : null
        greater_than          = criterion.value.greater_than
        greater_than_or_equal = criterion.value.greater_than_or_equal
        less_than             = criterion.value.less_than
        less_than_or_equal    = criterion.value.less_than_or_equal
      }
    }
  }

  provider = aws.tenant
}
