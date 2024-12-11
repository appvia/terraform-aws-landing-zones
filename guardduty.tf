#
## Used to configure the guardduty account settings
#

locals {
  ## Indicates if we should provision a default guardduty detector for the account
  enable_guardduty = try(var.guardduty.enable, false)
  ## A map of guardduty filters or an empty map
  guardduty_filters = try(var.guardduty.filters, {})
}

## Provision a guardduty detector for this account
resource "aws_guardduty_detector" "guardduty" {
  count = local.enable_guardduty ? 1 : 0

  enable                       = var.guardduty.enable
  finding_publishing_frequency = var.guardduty.finding_publishing_frequency
  tags                         = local.tags

  datasources {
    s3_logs {
      enable = var.guardduty.enable_s3_protection
    }
    kubernetes {
      audit_logs {
        enable = var.guardduty.enable_kubernetes_protection
      }
    }
    malware_protection {
      scan_ec2_instance_with_findings {
        ebs_volumes {
          enable = var.guardduty.enable_malware_protection
        }
      }
    }
  }

  provider = aws.tenant
}

## Provision the guardduty filters
resource "aws_guardduty_filter" "filters" {
  for_each = local.enable_guardduty ? local.guardduty_filters : {}

  action      = each.value.action
  description = each.value.description
  detector_id = aws_guardduty_detector.guardduty[0].id
  name        = each.key
  rank        = each.value.rank
  tags        = local.tags

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
