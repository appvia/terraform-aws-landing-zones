locals {
  ## Indicates if we should enable the cost anomaly detection monitors
  enable_aws_config = var.aws_config.enable && length(var.aws_config.compliance_packs) > 0
  ## Indicates if we should enable the AWS Config rules
  enable_aws_config_rules = var.aws_config.enable && length(var.aws_config.rules) > 0
}

## Provision one of more AWS Config Conformance Packs with in the account
resource "aws_config_conformance_pack" "default" {
  for_each = local.enable_aws_config ? var.aws_config.compliance_packs : {}

  name          = each.key
  template_body = each.value.template_body

  dynamic "input_parameter" {
    for_each = each.value.parameters

    content {
      parameter_name  = input_parameter.key
      parameter_value = input_parameter.value
    }
  }
}

## Provision the AWS Config rules
resource "aws_config_config_rule" "default" {
  for_each = local.enable_aws_config_rules ? var.aws_config.rules : {}

  name                        = coalesce(each.value.name, each.key)
  description                 = each.value.description
  tags                        = local.tags
  maximum_execution_frequency = try(each.value.max_execution_frequency, null)
  input_parameters            = length(each.value.inputs) > 0 ? jsonencode(each.value.inputs) : null

  ## Is the rule scoped to a specific resource type?
  source {
    owner             = try(each.value.owner, "AWS")
    source_identifier = each.value.identifier
  }

  ## Is the rule scoped to a specific resource type?
  dynamic "scope" {
    for_each = each.value.scope != null ? [1] : []

    content {
      compliance_resource_types = try(each.value.scope.compliance_resource_types, null)
      tag_key                   = try(each.value.scope.tag_key, null)
      tag_value                 = try(each.value.scope.tag_value, null)
    }
  }
}
