locals {
  ## The observability source configuration
  observability_source = try(var.cloudwatch.observability_source, {})
  ## The observability sink configuration
  observability_sink = try(var.cloudwatch.observability_sink, {})
  ## Indicates if the observability sink should be enabled
  enable_observability_sink = try(local.observability_sink.enable, false) && length(try(local.observability_sink.identifiers, [])) > 0
  ## Indicates if cloudwatch cross-account observability should be enabled
  enable_observability_source = try(local.observability_source.enable, false) && try(local.observability_source.account_id, null) != null
  ## The account id for the cloudwatch cross-account observability
  observability_source_account_id = try(local.observability_source.account_id, "")
  ## The OAM sink identifier for the cloudwatch cross-account observability
  observability_source_sink_identifier = try(local.observability_source.sink_identifier, "")
  ## The account root arn for the cloudwatch cross-account observability
  observability_source_account_root_arn = format("arn:aws:iam::%s:root", local.observability_source_account_id)
}

## Provision a sink for the observability
resource "aws_oam_sink" "observability_sink" {
  count = local.enable_observability_sink ? 1 : 0

  name = "observability-sink"
  tags = merge(local.tags, { "Name" = "observability-sink" })

  provider = aws.tenant
}

## Provision a policy for the observability sink
resource "aws_oam_sink_policy" "observability_sink" {
  count = local.enable_observability_sink ? 1 : 0

  sink_identifier = aws_oam_sink.observability_sink[0].arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCreateLink"
        Actions   = ["oam:CreateLink", "oam:UpdateLink"]
        Resources = ["*"]
        Effect    = "Allow"
        Principal = {
          AWS = local.observability_sink.identifiers
        }
        Condition = {
          "ForAllValues:StringEquals" = {
            "oam:ResourceType" = local.observability_sink.resource_types
          }
        }
      }
    ]
  })

  provider = aws.tenant
}

## Provision an IAM role for the cloudwatch cross-account observability
module "observability_source" {
  count   = local.enable_observability_source ? 1 : 0
  source  = "terraform-aws-modules/iam/aws//modules/iam-role"
  version = "6.4.0"

  name            = "cloudwatch-cao-"
  description     = "IAM role used for cross account observability of the cloudwatch service"
  path            = "/"
  tags            = local.tags
  use_name_prefix = true

  trust_policy_permissions = {
    "trust" = {
      sid     = "AllowCloudWatchCaoAssumeRole"
      effect  = "Allow"
      actions = ["sts:AssumeRole"]
      principals = [
        {
          type        = "AWS"
          identifiers = [local.observability_source_account_root_arn]
        }
      ]
    }
  }

  ## Map of policies to attach to the role
  policies = {
    "aws-xray"                 = "arn:aws:iam::aws:policy/AWSXrayReadOnlyAccess",
    "aws-cloudwatch-dashboard" = "arn:aws:iam::aws:policy/CloudWatchAutomaticDashboardsAccess",
    "aws-cloudwatch"           = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess",
  }

  providers = {
    aws = aws.tenant
  }
}

## Provision the OEM for CloudWatch Cross-Account Observability
resource "aws_oam_link" "cloudwatch_cao" {
  count = local.enable_observability_source ? 1 : 0

  label_template  = "$AccountName"
  sink_identifier = local.observability_source_sink_identifier
  resource_types  = local.observability_source.resource_types
  tags            = local.tags

  provider = aws.tenant
}
