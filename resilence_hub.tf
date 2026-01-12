locals {
  # Indicates if we should enable the resilience hub service
  enable_resilience_hub = try(var.resilience_hub.enable, false)
  # Indicates we should create the resilience hub IAM role
  enable_resilience_hub_iam_role = local.enable_resilience_hub && local.home_region
}

## Provision the resilience hub IAM role
module "resilience_hub_iam_role" {
  count = local.enable_resilience_hub_iam_role ? 1 : 0

  source  = "terraform-aws-modules/iam/aws//modules/iam-role"
  version = "6.3.0"

  name        = "lza-resilience-hub-role"
  description = "Used by the AWS Resilience Hub to assess applications against policy"
  tags        = merge(local.tags, { "Name" = "lza-resilience-hub-role" })

  trust_policy_permissions = {
    "resiliencehub" : {
      sid    = "AllowAssumeRole"
      effect = "Allow"
      actions = [
        "sts:AssumeRole",
        "sts:TagSession"
      ]
      principals = [
        {
          type        = "Service"
          identifiers = ["resiliencehub.amazonaws.com"]
        }
      ]
    }
  }

  policies = {
    "permissions" = "arn:aws:iam::aws:policy/AWSResilienceHubAsssessmentExecutionPolicy"
  }

  providers = {
    aws = aws.tenant
  }
}

## Provision any resilience hub policies
resource "aws_resiliencehub_resiliency_policy" "policies" {
  for_each = var.resilience_hub.policies

  name        = each.value.name != null ? each.value.name : each.key
  description = each.value.description
  tier        = each.value.tier
  tags        = merge(local.tags, { "Name" = each.value.name != null ? each.value.name : each.key })

  policy {
    region {
      rpo = each.value.policy.region.rpo
      rto = each.value.policy.region.rto
    }
    hardware {
      rpo = each.value.policy.hardware.rpo
      rto = each.value.policy.hardware.rto
    }
    software {
      rpo = each.value.policy.software.rpo
      rto = each.value.policy.software.rto
    }
    az {
      rpo = each.value.policy.az.rpo
      rto = each.value.policy.az.rto
    }
  }

  provider = aws.tenant
}
